-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.26 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk informasi
#CREATE DATABASE IF NOT EXISTS `informasi` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `informasi`;

-- membuang struktur untuk procedure informasi.listRuangKamarTidur
DROP PROCEDURE IF EXISTS `listRuangKamarTidur`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `listRuangKamarTidur`(
	IN `PRUANGAN` CHAR(10),
	IN `PKAMAR` SMALLINT,
	IN `PSTATUS` INT,
	IN `PPASIEN` VARCHAR(50)
)
BEGIN
	DECLARE VNORM INT;
	
	SET VNORM = CAST(PPASIEN AS UNSIGNED);
	
	SET @sqlText = CONCAT('
		SELECT rkt.ID, rgn.ID RUANGAN_ID, rgn.DESKRIPSI RUANGAN, rk.ID KAMAR_ID, rk.KAMAR, rkls.DESKRIPSI KELAS, rkt.TEMPAT_TIDUR, rkt.NORM, rkt.NAMA, rkt.NOPEN
					 , rkt.RESERVASI_NO, rkt.RESERVASI_TANGGAL, rkt.RESERVASI_ATAS_NAMA, rkt.RESERVASI_KONTAK_INFO
					 , rkt.STATUS_ID, rs.DESKRIPSI STATUS, tgh.TOTAL AS TOTAL_TAGIHAN
			  FROM (
			SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, NULL NAMA, NULL NOPEN, NULL RESERVASI_NO, NULL RESERVASI_TANGGAL, NULL RESERVASI_ATAS_NAMA, NULL RESERVASI_KONTAK_INFO, rkt.`STATUS` STATUS_ID
			  FROM master.ruang_kamar_tidur rkt
			 WHERE NOT rkt.`STATUS` IN (0)
			   AND rkt.`STATUS` = 1	 
			UNION	
			SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, NULL NAMA, NULL NOPEN, r.NOMOR RESERVASI_NO, r.TANGGAL RESERVASI_TANGGAL, r.ATAS_NAMA RESERVASI_ATAS_NAMA, r.KONTAK_INFO RESERVASI_KONTAK_INFO, rkt.`STATUS` STATUS_ID
			  FROM master.ruang_kamar_tidur rkt
			  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.`STATUS` = 1
			 WHERE NOT rkt.`STATUS` IN (0)
			   AND rkt.`STATUS` = 2
			UNION		 
			SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, ps.NORM, CONCAT(IF(ps.GELAR_DEPAN = '''' OR ps.GELAR_DEPAN IS NULL, '''', CONCAT(ps.GELAR_DEPAN, ''. '')),UPPER(ps.NAMA), IF(ps.GELAR_BELAKANG = '''' OR ps.GELAR_BELAKANG IS NULL, '''', CONCAT('', '', ps.GELAR_BELAKANG))) NAMA, k.NOPEN, NULL RESERVASI_NO, NULL RESERVASI_TANGGAL, NULL RESERVASI_ATAS_NAMA, NULL RESERVASI_KONTAK_INFO, rkt.`STATUS` STATUS_ID
			  FROM master.ruang_kamar_tidur rkt
			  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
			  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM  		 
			 WHERE NOT rkt.`STATUS` IN (0)
			   AND rkt.`STATUS` = 3
			   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
				AND NOT EXISTS(
					SELECT 1 
					  FROM pembatalan.pembatalan_kunjungan pk 
					 WHERE pk.KUNJUNGAN = k.NOMOR AND pk.JENIS = 1
					   AND NOT EXISTS(
							SELECT 1 
							  FROM pembatalan.pembatalan_kunjungan pk2 
							 WHERE pk2.KUNJUNGAN = pk.KUNJUNGAN 
							   AND pk2.JENIS = 2 
								AND pk2.TANGGAL > pk.TANGGAL
						)
					ORDER BY pk.TANGGAL DESC LIMIT 1
				)
			 ) rkt
				LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
				LEFT JOIN master.referensi rkls ON rk.KELAS = rkls.ID AND rkls.JENIS = 19
				LEFT JOIN master.ruangan rgn On rgn.ID = rk.RUANGAN
				LEFT JOIN master.referensi rs ON rs.JENIS = 20 AND rs.ID = rkt.STATUS_ID 
				LEFT JOIN pembayaran.tagihan_pendaftaran tghp ON tghp.PENDAFTARAN = rkt.NOPEN
				LEFT JOIN pembayaran.tagihan tgh ON tgh.ID = tghp.TAGIHAN
		WHERE NOT rkt.STATUS_ID IN (0) 
		  AND rgn.STATUS = 1 
		  AND rk.STATUS = 1
		  AND rgn.JENIS_KUNJUNGAN = 3',
	 IF(PRUANGAN = '', '', CONCAT(' AND rgn.ID = ''', PRUANGAN, '''')),
	 IF(PKAMAR = 0, '', CONCAT(' AND rk.ID = ', PKAMAR)),
	 IF(NOT PSTATUS IN (1,2,3), '', CONCAT(' AND rkt.STATUS_ID = ', PSTATUS)),
	 IF(VNORM = 0, IF(PPASIEN = '', '', CONCAT(' AND rkt.NAMA LIKE ''%', PPASIEN, '%''')), CONCAT(' AND rkt.NORM = ', VNORM)),
	 ' ORDER BY rgn.ID, rk.ID, rkt.ID, rkls.DESKRIPSI');
	
	
	 
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
