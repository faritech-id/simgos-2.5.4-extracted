-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6557
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping database structure for pendaftaran
USE `pendaftaran`;

-- Dumping structure for procedure pendaftaran.CetakBarcodeReg
DROP PROCEDURE IF EXISTS `CetakBarcodeReg`;
DELIMITER //
CREATE PROCEDURE `CetakBarcodeReg`(
	IN `PNOPEN` CHAR(10)
)
BEGIN	
	DECLARE a INT Default 0 ;
DECLARE b TEXT ;	
SET b = '';
   WHILE a < 4 DO
    SET a = a + 1;
    	SET b = CONCAT(b,'SELECT inst.NAMA NAMAINSTANSI, LPAD(p.NORM,8,"0") NORM
		 , CONCAT(master.getNamaLengkap(p.NORM),'' ('',IF(p.JENIS_KELAMIN=1,''L)'',''P)'')) NAMALENGKAP
	   , DATE_FORMAT(p.TANGGAL_LAHIR,"%d-%m-%Y") TGL_LAHIR
		, CONCAT("RM : ",LPAD(p.NORM,8,"0")," Tgl Lhr ",DATE_FORMAT(p.TANGGAL_LAHIR,"%d-%m-%Y")) RMTGL_LAHIR
		, pd.NOMOR NOPEN, IF(p.JENIS_KELAMIN=1,"LAKI-LAKI","PEREMPUAN") JK
		, p.ALAMAT, kip.NOMOR NIK
		, master.getNamaLengkapPegawai(dr.NIP) DOKTER
		, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLMSK
	FROM master.pasien p
		  LEFT JOIN master.kartu_identitas_pasien kip ON p.NORM=kip.NORM
		, pendaftaran.pendaftaran pd
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.dokter dr ON tp.DOKTER=dr.ID
		, (SELECT ai.PPK ID, mp.NAMA, mp.KODE, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR="',PNOPEN,'" AND pd.NOMOR=tp.NOPEN UNION ALL ');	   
  	END WHILE;				
   
   SET @sqlText = CONCAT(b,'SELECT inst.NAMA NAMAINSTANSI, LPAD(p.NORM,8,"0") NORM
		 , CONCAT(master.getNamaLengkap(p.NORM),'' ('',IF(p.JENIS_KELAMIN=1,''L)'',''P)'')) NAMALENGKAP
	   , DATE_FORMAT(p.TANGGAL_LAHIR,"%d-%m-%Y") TGL_LAHIR
		, CONCAT("RM : ",LPAD(p.NORM,8,"0")," Tgl Lhr ",DATE_FORMAT(p.TANGGAL_LAHIR,"%d-%m-%Y")) RMTGL_LAHIR
		, pd.NOMOR NOPEN, IF(p.JENIS_KELAMIN=1,"LAKI-LAKI","PEREMPUAN") JK
		, p.ALAMAT, kip.NOMOR NIK
		, master.getNamaLengkapPegawai(dr.NIP) DOKTER
		, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLMSK
	FROM master.pasien p
		  LEFT JOIN master.kartu_identitas_pasien kip ON p.NORM=kip.NORM
		, pendaftaran.pendaftaran pd
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.dokter dr ON tp.DOKTER=dr.ID
		, (SELECT ai.PPK ID, mp.NAMA, mp.KODE, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR="',PNOPEN,'" AND pd.NOMOR=tp.NOPEN');	
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
