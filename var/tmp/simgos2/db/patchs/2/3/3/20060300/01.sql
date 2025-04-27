-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `master`;

-- membuang struktur untuk procedure master.CetakBarcodeRM
DROP PROCEDURE IF EXISTS `CetakBarcodeRM`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakBarcodeRM`(
	IN `PNORM` VARCHAR(8)
)
BEGIN
	SELECT LPAD(p.NORM,8,'0') NORM
			#INSERT(INSERT(INSERT(INSERT(INSERT(LPAD(p.NORM,6,'0'),2,0,' '),4,0,' '),6,0,' '),8,0,' '),10,0,' ') NORM
			, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM2
			, @NAMALGKP:=master.getNamaLengkap(p.NORM) NAMALENGKAP, LPAD(p.NORM,8,'0') NORMLABEL
			, IF(LENGTH(@NAMALGKP)<=25,'OK',IF(LENGTH(@NAMALGKP) > 25 AND LENGTH(@NAMALGKP)<=30 ,'OK2','TIDAK')) KARAKTER
			, IF(gol.ID=13 OR gol.ID IS NULL ,'',REPLACE(REPLACE(gol.DESKRIPSI,'+',''),'-','')) GOLDARAH
			, IF(RIGHT(gol.DESKRIPSI,1)='+','Positif',IF(RIGHT(gol.DESKRIPSI,1)='-','Negatif','')) RHESUS
			, IF(ktp.NOMOR IS NULL,'', ktp.NOMOR) NOKTP
			, IF(kap.NOMOR IS NULL,'',kap.NOMOR) NOJKN
	FROM master.pasien p
	     LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
	     LEFT JOIN master.kartu_identitas_pasien ktp ON p.NORM=ktp.NORM AND ktp.JENIS=1
	     LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
	WHERE p.NORM=PNORM;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
