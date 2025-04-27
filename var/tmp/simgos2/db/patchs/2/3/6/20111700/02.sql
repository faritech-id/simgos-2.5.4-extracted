-- --------------------------------------------------------
-- Host:                         192.168.56.2
-- Server version:               8.0.21 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
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
		, IF(cp.JENIS IN (1,2), master.getNamaLengkapPegawai(d.NIP),'''') DOKTER
		, IF(cp.JENIS=3, master.getNamaLengkapPegawai(pr.NIP),IF(cp.JENIS IN (6,7), master.getNamaLengkapPegawai(p.NIP),'''')) PERAWAT
		, "" INSTRUKSI
		, ref.DESKRIPSI JNSPPA
		, IF(cp.JENIS IN (1,2), master.getNamaLengkapPegawai(d.NIP), IF(cp.JENIS=3, master.getNamaLengkapPegawai(pr.NIP), IF(cp.JENIS IN (6,7), master.getNamaLengkapPegawai(p.NIP),""))) PPA
		FROM medicalrecord.cppt cp
		  LEFT JOIN master.referensi ref ON cp.JENIS = ref.ID AND ref.JENIS = 32
		  LEFT JOIN master.pegawai p ON cp.TENAGA_MEDIS=p.ID
		  LEFT JOIN master.dokter d ON cp.TENAGA_MEDIS=d.ID
		  LEFT JOIN master.perawat pr ON cp.TENAGA_MEDIS=pr.ID
	     , pendaftaran.kunjungan pk
		 WHERE cp.KUNJUNGAN=pk.NOMOR AND pk.STATUS!=0 AND cp.`STATUS`!=0	AND pk.NOPEN=''',PNOPEN,'''
		 ',IF(PKUNJUNGAN = 0 OR PKUNJUNGAN = '''','' , CONCAT(' AND cp.KUNJUNGAN =''',PKUNJUNGAN,'''' )),' 
		  ');
			
	-- SELECT @sqlText;
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
