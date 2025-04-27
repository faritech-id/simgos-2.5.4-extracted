-- --------------------------------------------------------
-- Host:                         192.168.5.8
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE medicalrecord;
-- Dumping structure for procedure medicalrecord.CetakCPPT
DROP PROCEDURE IF EXISTS `CetakCPPT`;
DELIMITER //
CREATE PROCEDURE `CetakCPPT`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
  SET @sqlText = CONCAT(
			'SELECT CONCAT(DATE_FORMAT(cp.TANGGAL,''%d-%m-%Y''), '' \r'', TIME(cp.TANGGAL)) TANGGAL
		,CONCAT(''S/: '', cp.SUBYEKTIF,'' \r'',''O/: '',  cp.OBYEKTIF,'' \r'',''A/: '',  cp.ASSESMENT,'' \r'',''P/: '',  cp.PLANNING) CATATAN
		, IF(ref.REF_ID = "4", master.getNamaLengkapPegawai(d.NIP),'''') DOKTER
		, IF(ref.REF_ID = "6", master.getNamaLengkapPegawai(pr.NIP),IF(ref.REF_ID NOT IN ("6","4"), master.getNamaLengkapPegawai(p.NIP),'''')) PERAWAT
		, cp.INSTRUKSI
		, ref.DESKRIPSI JNSPPA
		, IF(ref.REF_ID = "4", master.getNamaLengkapPegawai(d.NIP), IF(ref.REF_ID = "6", master.getNamaLengkapPegawai(pr.NIP), IF(ref.REF_ID NOT IN ("6","4"), master.getNamaLengkapPegawai(p.NIP),""))) PPA
		FROM medicalrecord.cppt cp
		  LEFT JOIN master.referensi ref ON cp.JENIS = ref.ID AND ref.JENIS = 32
		  LEFT JOIN master.pegawai p ON cp.TENAGA_MEDIS=p.ID
		  LEFT JOIN master.dokter d ON cp.TENAGA_MEDIS=d.ID
		  LEFT JOIN master.perawat pr ON cp.TENAGA_MEDIS=pr.ID
	     , pendaftaran.kunjungan pk
		 WHERE cp.KUNJUNGAN=pk.NOMOR AND pk.STATUS!=0 AND cp.`STATUS`!=0	AND pk.NOPEN=''',PNOPEN,'''
		 ',IF(PKUNJUNGAN = 0 OR PKUNJUNGAN = '''','' , CONCAT(' AND cp.KUNJUNGAN =''',PKUNJUNGAN,'''' )),' 
		  ');
			
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
