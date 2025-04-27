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
CREATE DATABASE IF NOT EXISTS `layanan`;
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakHasilKepekaan
DROP PROCEDURE IF EXISTS `CetakHasilKepekaan`;
DELIMITER //
CREATE PROCEDURE `CetakHasilKepekaan`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_KEPEKAAN_KIRI;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_KEPEKAAN_KANAN;
	
	SET @brs1:=0;
	SET @brs2:=0;
	SET @brs3:=0;
	SET @brs4:=0;
	SET @id:=0;
	SET @id2:=0;
	SET @id3:=0;
	SET @id4:=0;
	
	CREATE TEMPORARY TABLE TEMP_DATA_KEPEKAAN_KIRI ENGINE=MEMORY
   SELECT IF(CONCAT(IDBAKTERI,BRS) = CONCAT(IDBAKTERI,JUMLAH+1), @brs4:=1, IF(@id2 != IDBAKTERI, @brs4:=1, @brs4:=@brs4+1)) BRS2
			 , @id2:=IDBAKTERI, cd.BRS, cd.KUNJUNGAN, cd.IDBAKTERI, cd.BAKTERI, cd.ANTIBIOTIK, cd.HASIL, cd.JUMLAH
			 , IF(LEFT(UPPER(LTRIM(cd.HASIL)),1) = 'R', 1, 0) STS
	  FROM (SELECT IF(@id != ab.IDBAKTERI, @brs3:=1, @brs3:=@brs3+1) BRS
	  				   , @id:=ab.IDBAKTERI, ab.KUNJUNGAN, ab.IDBAKTERI, ab.BAKTERI, ab.ANTIBIOTIK, ab.HASIL
	   				, JUMLAH JUMLAH
	  		    FROM (SELECT lk.KUNJUNGAN,lk.BAKTERI IDBAKTERI, bk.DESKRIPSI BAKTERI, an.DESKRIPSI ANTIBIOTIK, lk.HASIL
								  , ROUND((SELECT COUNT(*) FROM layanan.hasil_lab_kepekaan lk1 WHERE lk1.KUNJUNGAN=lk.KUNJUNGAN AND lk1.BAKTERI=lk.BAKTERI AND lk.`STATUS`!=0)/2) JUMLAH
						   FROM layanan.hasil_lab_kepekaan lk
		      				  LEFT JOIN master.referensi bk ON lk.BAKTERI=bk.ID AND bk.JENIS=129
			   				  LEFT JOIN master.referensi an ON lk.ANTIBIOTIK=an.ID AND an.JENIS=128
						  WHERE lk.KUNJUNGAN=PKUNJUNGAN AND lk.`STATUS` != 0
						  ORDER BY lk.BAKTERI,lk.ANTIBIOTIK
	  		  ) ab
	  ) cd
	 WHERE BRS <= JUMLAH;
	
   CREATE TEMPORARY TABLE TEMP_DATA_KEPEKAAN_KANAN ENGINE=MEMORY
   SELECT IF(CONCAT(IDBAKTERI,BRS) = CONCAT(IDBAKTERI,JUMLAH+1), @brs2:=1, IF(@id4 != IDBAKTERI, @brs2:=1, @brs2:=@brs2+1)) BRS2
	 		 , @id4:=IDBAKTERI, cd.BRS, cd.KUNJUNGAN, cd.IDBAKTERI, cd.BAKTERI, cd.ANTIBIOTIK, cd.HASIL, cd.JUMLAH
			 , IF(LEFT(UPPER(LTRIM(cd.HASIL)),1) = 'R', 1, 0) STS
	  FROM (SELECT IF(@id3 != ab.IDBAKTERI, @brs1:=1, @brs1:=@brs1+1) BRS
						, @id3:=ab.IDBAKTERI, ab.KUNJUNGAN, ab.IDBAKTERI, ab.BAKTERI, ab.ANTIBIOTIK, ab.HASIL
		   			, JUMLAH JUMLAH
			    FROM (SELECT lk.KUNJUNGAN,lk.BAKTERI IDBAKTERI, bk.DESKRIPSI BAKTERI, an.DESKRIPSI ANTIBIOTIK, lk.HASIL
								  , ROUND((SELECT COUNT(*) FROM layanan.hasil_lab_kepekaan lk1 WHERE lk1.KUNJUNGAN=lk.KUNJUNGAN AND lk1.BAKTERI=lk.BAKTERI AND lk.`STATUS`!=0)/2) JUMLAH
						   FROM layanan.hasil_lab_kepekaan lk
		      				  LEFT JOIN master.referensi bk ON lk.BAKTERI=bk.ID AND bk.JENIS=129
			   				  LEFT JOIN master.referensi an ON lk.ANTIBIOTIK=an.ID AND an.JENIS=128
						  WHERE lk.KUNJUNGAN=PKUNJUNGAN AND lk.`STATUS` != 0
					     ORDER BY lk.BAKTERI,lk.ANTIBIOTIK
	  		    ) ab
	  ) cd
	WHERE BRS > JUMLAH;
	 
  SELECT kr.KUNJUNGAN, kr.BRS, kr.IDBAKTERI, kr.BAKTERI BAKTERI_KR, kr.ANTIBIOTIK ANTIBIOTIK_KR, kr.HASIL HASIL_KR
         , BRS_KN, BAKTERI1, ANTIBIOTIK_KN, HASIL_KN, IFNULL(STS,0) STS_KR, IFNULL(STS_KN,0) STS_KN
    FROM TEMP_DATA_KEPEKAAN_KIRI kr
  		   LEFT JOIN (
				SELECT kn.BRS2, kn.IDBAKTERI, kn.KUNJUNGAN KUNJUNGAN1, kn.BRS BRS_KN, kn.BAKTERI BAKTERI1, kn.ANTIBIOTIK ANTIBIOTIK_KN, kn.HASIL HASIL_KN, STS STS_KN
				  FROM TEMP_DATA_KEPEKAAN_KANAN kn
			) gf ON gf.BRS2=kr.BRS2 AND gf.IDBAKTERI=kr.IDBAKTERI
  ORDER BY kr.IDBAKTERI, kr.BRS;	 	
END//
DELIMITER ;

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
	 
	#SELECT @sqlText;
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure layanan.CetakHasilPa
DROP PROCEDURE IF EXISTS `CetakHasilPa`;
DELIMITER //
CREATE PROCEDURE `CetakHasilPa`(
	IN `PID` INT
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT INST.*, DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s'') TGLSKRG
		    , hp.*, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP, p.ALAMAT, pk.MASUK TGLREG,
		    master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, ref.DESKRIPSI JENISPEMERIKSAAN, rjk.DESKRIPSI JENISKELAMIN,
		    CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),'')'') TGL_LAHIR,
		    rasal.DESKRIPSI RUANGAN_ASAL,
		    master.getNamaLengkapPegawai(dokasal.NIP) NAMA_DOKTER_ASAL
	 FROM layanan.hasil_pa hp
		   LEFT JOIN pendaftaran.kunjungan pk ON hp.KUNJUNGAN = pk.NOMOR
		   LEFT JOIN layanan.order_lab olab ON olab.NOMOR = pk.REF
		   LEFT JOIN pendaftaran.kunjungan pkjgn ON pkjgn.NOMOR = olab.KUNJUNGAN
		   LEFT JOIN master.dokter dokasal ON dokasal.ID = olab.DOKTER_ASAL
		   LEFT JOIN master.ruangan rasal ON rasal.ID = pkjgn.RUANGAN
		   LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN = pp.NOMOR
		   LEFT JOIN master.pasien p ON p.NORM = pp.NORM
		   LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		   LEFT JOIN master.dokter dok ON hp.DOKTER=dok.ID
		   LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
		   LEFT JOIN master.referensi ref ON hp.JENIS_PEMERIKSAAN=ref.ID AND ref.JENIS=66
	 	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST,  CONCAT(''Telp. '',TELEPON, '' Fax. '',FAX) TELP, ai.PPK IDPPK
					 , w.DESKRIPSI KOTA, ai.WEBSITE WEB, ai.DEPARTEMEN, ai.INDUK_INSTANSI 
			  FROM aplikasi.instansi ai
				    , master.ppk p
				    , master.wilayah w
			 WHERE ai.PPK=p.ID 
			   AND p.WILAYAH=w.ID) INST
    WHERE hp.ID =',PID,'');
	 
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
