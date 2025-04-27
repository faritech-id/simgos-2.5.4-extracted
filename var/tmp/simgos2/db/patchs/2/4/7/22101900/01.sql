-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakHasilKultur
DROP PROCEDURE IF EXISTS `CetakHasilKultur`;
DELIMITER //
CREATE PROCEDURE `CetakHasilKultur`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
	   SELECT ol.NOMOR NO_LAB, pd.NORM  
			    , master.getNamaLengkap(pd.NORM) NAMA_PASIEN, master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR, rasal.DESKRIPSI RUANG_ASAL
			    , CONCAT(master.getNamaLengkap(pd.NORM),'' / '', master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) ,'' / '', rasal.DESKRIPSI) NAMALENGKAP
			    , IF(kp.NOMOR IS NULL,master.getNamaLengkapPegawai(ds.NIP), CONCAT(master.getNamaLengkapPegawai(ds.NIP),'' / '',kp.NOMOR)) DOKTER_PENGIRIM, ol.ALASAN DIAGNOSA
			    , kj.MASUK TGLTERIMA, kj.KELUAR TGL_HASIL
			    , lk.BAHAN, lk.GRAM, lk.AEROB, lk.KESIMPULAN, lk.ANJURAN, lk.CATATAN
			    , master.getNamaLengkapPegawai(dlab.NIP) DOKTER_LAB
			    , dlab.NIP
			    , INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
			    #, lm.TERAPI_ANTIBIOTIK TERAPI_ANTIBIOTIK
			    , '''' TERAPI_ANTIBIOTIK
				 , '''' KEPALA_INSTALASI
		  FROM layanan.hasil_lab_kultur lk
		       LEFT JOIN master.dokter dlab ON lk.DOKTER=dlab.ID
		       #LEFT JOIN layanan.hasil_lab_mikroskopik lm ON lk.KUNJUNGAN=lm.KUNJUNGAN AND lm.`STATUS`!=0
		  	  , pendaftaran.kunjungan kj
			  , layanan.order_lab ol
				 LEFT JOIN pendaftaran.kunjungan asal ON ol.KUNJUNGAN=asal.NOMOR AND asal.`STATUS`!=0
				 LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
				 LEFT JOIN master.dokter ds ON ol.DOKTER_ASAL=ds.ID
				 LEFT JOIN pegawai.kontak_pegawai kp ON ds.NIP=kp.NIP AND kp.JENIS=3 AND kp.`STATUS`!=0
			  , pendaftaran.pendaftaran pd
			  , master.pasien p
			  	, (SELECT w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		 WHERE lk.KUNJUNGAN=''',PKUNJUNGAN, ''' AND lk.`STATUS`!=0
		   AND lk.KUNJUNGAN=kj.NOMOR AND kj.`STATUS`!=0
			AND kj.REF=ol.NOMOR AND ol.`STATUS`!=0
			AND kj.NOPEN=pd.NOMOR AND pd.`STATUS`!=0
			AND pd.NORM=p.NORM 
		');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure layanan.CetakHasilMikroskopik
DROP PROCEDURE IF EXISTS `CetakHasilMikroskopik`;
DELIMITER //
CREATE PROCEDURE `CetakHasilMikroskopik`(
	IN `P_KUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
				 , hlm.ID, hlm.KUNJUNGAN, hlm.BAHAN, hlm.DIAGNOSA, hlm.TERAPI_ANTIBIOTIK
				 , hlmd.HASIL
				 , ref_p.DESKRIPSI
				 , master.getNamaLengkapPegawai(d.NIP) AS DOKTER
				 , d.NIP
				 , ps.NORM, master.getNamaLengkap(ps.NORM) AS PASIEN
				 , master.getNamaLengkapPegawai(da.NIP) AS DOKTER_ASAL
				 , DATE_FORMAT(k.MASUK, ''%d-%m-%Y %H:%i:%s'') AS TGL_TERIMA
				 , DATE_FORMAT(k.KELUAR, ''%d-%m-%Y %H:%i:%s'') AS TGL_SELESAI
				 , ol.NOMOR AS NOMOR_LAB, k.NOMOR
				 , '''' PEMERIKSA
		  FROM pendaftaran.kunjungan k
				 , pendaftaran.pendaftaran p
				 , layanan.hasil_lab_mikroskopik hlm
				 , layanan.hasil_lab_mikroskopik_detail hlmd
				 , layanan.order_lab ol
				 , master.referensi ref_p
				 , master.dokter d
				 , master.dokter da
				 , master.pegawai pa
				 , master.pasien ps
				 , (SELECT w.DESKRIPSI KOTA
					   FROM aplikasi.instansi ai
						     , master.ppk p
							  , master.wilayah w
					  WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		 WHERE hlm.KUNJUNGAN = hlmd.KUNJUNGAN
			AND ref_p.JENIS = 134
			AND hlmd.PEMERIKSAAN = ref_p.ID
			AND hlmd.STATUS = 1
			AND hlm.DOKTER = d.ID
			AND k.NOMOR =  hlm.KUNJUNGAN
			AND k.NOPEN = p.NOMOR
			AND p.NORM = ps.NORM
			AND k.REF = ol.NOMOR
			AND ol.DOKTER_ASAL = da.ID
			AND da.NIP = pa.NIP
			AND k.NOMOR = "',P_KUNJUNGAN, '"');
	 
	#SELECT @sqlText;
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure layanan.CetakHasilPCR
DROP PROCEDURE IF EXISTS `CetakHasilPCR`;
DELIMITER //
CREATE PROCEDURE `CetakHasilPCR`(
	IN `P_KUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
				 , hlm.*				 
				 , master.getNamaLengkapPegawai(d.NIP) AS NAMA_DOKTER
				 , d.NIP
				 , ps.NORM, master.getNamaLengkap(ps.NORM) AS PASIEN
				 , master.getNamaLengkapPegawai(da.NIP) AS DOKTER_ASAL				
				 , DATE_FORMAT(k.MASUK, ''%d-%m-%Y %H:%i:%s'') AS TGL_TERIMA
				 , DATE_FORMAT(k.KELUAR, ''%d-%m-%Y %H:%i:%s'') AS TGL_SELESAI
				 , ol.NOMOR AS NOMOR_LAB, k.NOMOR
		  FROM pendaftaran.kunjungan k
				 , pendaftaran.pendaftaran p
				 , layanan.hasil_lab_pcr hlm
				 , layanan.order_lab ol
				 , master.dokter d
				 , master.dokter da
				 , master.pegawai pa
				 , master.pasien ps
				 , (SELECT w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							  , master.ppk p
							  , master.wilayah w
					  WHERE ai.PPK = p.ID AND p.WILAYAH = w.ID) INST
		 WHERE k.NOMOR = ''',P_KUNJUNGAN, '''
		   AND hlm.DOKTER = d.ID
		   AND k.NOMOR =  hlm.KUNJUNGAN
		   AND k.NOPEN = p.NOMOR
		   AND p.NORM = ps.NORM
		   AND k.REF = ol.NOMOR
		   AND ol.DOKTER_ASAL = da.ID
		   AND da.NIP = pa.NIP');
   	 
   	#SELECT @sqlText;
   	PREPARE stmt FROM @sqlText;
   	EXECUTE stmt;
   	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
