-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk function pembayaran.getTotalTagihan
DROP FUNCTION IF EXISTS `getTotalTagihan`;
DELIMITER //
CREATE FUNCTION `getTotalTagihan`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60, 2);
	
	SELECT p.JENIS, pt.NAIK_KELAS, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.TARIF_INACBG_KELAS1, pt.SELISIH_MINIMAL
	  INTO @VJENIS, @VNAIK_KELAS, @VTOTAL_NAIK_KELAS, @VNAIK_KELAS_VIP, @VTARIF_INACBG_KELAS1, @VSELISIH_MINIMAL
	  FROM pembayaran.penjamin_tagihan pt,
	  		 pembayaran.tagihan_pendaftaran tp,
	  		 pendaftaran.penjamin p
	 WHERE pt.TAGIHAN = PTAGIHAN
	   AND tp.TAGIHAN = pt.TAGIHAN
	   AND tp.UTAMA = 1
	   AND tp.`STATUS` = 1
	   AND p.NOPEN = tp.PENDAFTARAN;
	   
	SELECT TOTAL INTO VTOTAL
	  FROM pembayaran.tagihan
	 WHERE ID = PTAGIHAN
	   AND STATUS != 0;

	IF VTOTAL IS NULL THEN
		SET VTOTAL = 0;
	ELSE
		IF NOT @VJENIS IS NULL THEN
			SET VTOTAL = IF(@VJENIS = 2 AND @VNAIK_KELAS = 1,
				@VTOTAL_NAIK_KELAS, 
				IF(@VJENIS = 2 AND @VNAIK_KELAS_VIP = 1, @VTARIF_INACBG_KELAS1, VTOTAL)
				) + IFNULL(@VSELISIH_MINIMAL, 0);
		END IF;
	END IF;
	
	RETURN VTOTAL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
