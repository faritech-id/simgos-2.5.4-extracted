-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

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
