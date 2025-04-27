-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanResponTimeLabPA
DROP PROCEDURE IF EXISTS `LaporanResponTimeLabPA`;
DELIMITER //
CREATE PROCEDURE `LaporanResponTimeLabPA`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN


	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
					SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, IFNULL(ra.DESKRIPSI,''Langsung ke Loket'') RUANGAN_AWAL
						, pa.TANGGAL TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(pa.TANGGAL,k.MASUK) SELISIH2
						, TIMEDIFF(pa.TANGGAL,olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, p.TANGGAL_LAHIR TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
						, pa.NOMOR_PA
						, pa.LOKASI
						, pa.DIAGNOSA_KLINIK
						, pa.KESIMPULAN
					
						, (SELECT CONCAT(DATEDIFF(pa.TANGGAL,k.MASUK) - (
								(SELECT COUNT(*)
								FROM `master`.tanggal tgl WHERE tgl.TANGGAL BETWEEN k.MASUK AND pa.TANGGAL AND tgl.NAMAHARI IN (''Saturday'',''Sunday'')) +
								(SELECT COUNT(*) FROM pegawai.libur_nasional lns WHERE lns.TANGGAL_LIBUR BETWEEN k.MASUK AND pa.TANGGAL AND lns.`STATUS`=1)
								) ,'' hari \r * libur: '',
								((SELECT COUNT(*)
								FROM `master`.tanggal tgl WHERE tgl.TANGGAL BETWEEN k.MASUK AND pa.TANGGAL AND tgl.NAMAHARI IN (''Saturday'',''Sunday'')) +
								(SELECT COUNT(*) FROM pegawai.libur_nasional lns WHERE lns.TANGGAL_LIBUR BETWEEN k.MASUK AND pa.TANGGAL AND lns.`STATUS`=1)),'' hari'')) LAMA_PELAYANAN
						, IF(pa.JENIS_PEMERIKSAAN=1,''Histopatologi'',	IF(pa.JENIS_PEMERIKSAAN=2,	''Sitologi'', IF(pa.JENIS_PEMERIKSAAN=3, ''IHC'',''''))) KET
					FROM pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						  LEFT JOIN layanan.hasil_pa pa ON k.NOMOR=pa.KUNJUNGAN AND pa.`STATUS`!=0
						  LEFT JOIN master.dokter drh ON pa.DOKTER =drh.ID
						  LEFT JOIN layanan.order_lab olb ON olb.NOMOR=k.REF AND olb.`STATUS`!=0
						  LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE k.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND k.RUANGAN=r.ID AND k.`STATUS`!=0 
					 
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				GROUP BY k.NOMOR
				
		');
	

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
