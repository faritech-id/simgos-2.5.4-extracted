-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.24 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk pendaftaran
#CREATE DATABASE IF NOT EXISTS `pendaftaran` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pendaftaran`;

-- membuang struktur untuk function pendaftaran.getLamaDirawat
DROP FUNCTION IF EXISTS `getLamaDirawat`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawat`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VATURAN VARCHAR(50);
	
	SELECT pc.VALUE INTO VATURAN
	  FROM aplikasi.properti_config pc
	 WHERE pc.ID = 14;
	 
	IF FOUND_ROWS() = 0 THEN
		SET VATURAN = '1';
	END IF;
	
	IF VATURAN = '1' THEN
		RETURN pendaftaran.getLamaDirawatAturan1(PMASUK, PKELUAR, PNOPEN, PKUNJUNGAN, PREF);
	END IF;
	
	IF VATURAN = '2' THEN
		RETURN pendaftaran.getLamaDirawatAturan2(PMASUK, PKELUAR, PNOPEN, PKUNJUNGAN, PREF);
	END IF;
	
	RETURN 0;
END//
DELIMITER ;

-- membuang struktur untuk function pendaftaran.getLamaDirawatAturan1
DROP FUNCTION IF EXISTS `getLamaDirawatAturan1`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawatAturan1`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	RETURN DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK);
END//
DELIMITER ;

-- membuang struktur untuk function pendaftaran.getLamaDirawatAturan2
DROP FUNCTION IF EXISTS `getLamaDirawatAturan2`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawatAturan2`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VJML SMALLINT DEFAULT 0;
	
	IF PREF IS NULL THEN
		SET VJML = DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK) + 1;
	ELSE
		RETURN DATEDIFF(IF(PKELUAR IS NULL, NOW(), PKELUAR), PMASUK);
	END IF;
	
	RETURN VJML;
END//
DELIMITER ;

-- membuang struktur untuk function pendaftaran.getLamaDirawatSebelumnya
DROP FUNCTION IF EXISTS `getLamaDirawatSebelumnya`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawatSebelumnya`(
	`PMUTASI` CHAR(21),
	`PPAKET` SMALLINT
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VMUTASI CHAR(21);
	DECLARE VMASUK, VKELUAR DATETIME;
	DECLARE VLAMA_DIRAWAT SMALLINT;
	DECLARE VREF CHAR(21);
	DECLARE VNOPEN CHAR(10);
	DECLARE VKUNJUNGAN CHAR(19);
	
	SELECT k.NOPEN, k.NOMOR, k.REF, k.MASUK, k.KELUAR INTO VMUTASI, VMASUK, VKELUAR, VNOPEN, VKUNJUNGAN
	  FROM pendaftaran.mutasi m,
	  		 pendaftaran.kunjungan k,
	       pendaftaran.pendaftaran p,
	       master.paket pkt,
	       master.ruang_kamar_tidur rkt,
	       master.ruang_kamar rk
	 WHERE m.NOMOR = PMUTASI
	   AND k.NOMOR = m.KUNJUNGAN
	 	AND p.NOMOR = k.NOPEN
	   AND p.PAKET = PPAKET
		AND pkt.ID = p.PAKET
		AND rkt.ID = k.RUANG_KAMAR_TIDUR
		AND rk.ID = rkt.RUANG_KAMAR
		AND rk.KELAS = pkt.KELAS;
		
	IF FOUND_ROWS() > 0 THEN
		SET VLAMA_DIRAWAT = pendaftaran.getLamaDirawat(VMASUK, VKELUAR, VNOPEN, VKUNJUNGAN, VMUTASI);
		IF NOT VREF IS NULL OR VREF != '' THEN
			SET VLAMA_DIRAWAT = VLAMA_DIRAWAT + pendaftaran.getLamaDirawatSebelumnya(VREF, PPAKET);
		END IF;
		
		RETURN VLAMA_DIRAWAT;
	ELSE
		RETURN 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
