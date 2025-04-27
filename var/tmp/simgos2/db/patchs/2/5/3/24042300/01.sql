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


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganTotalTagihanPerkelas
DROP PROCEDURE IF EXISTS `prosesPerhitunganTotalTagihanPerkelas`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganTotalTagihanPerkelas`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT,
	IN `PDATA` JSON
)
BEGIN
	IF NOT PDATA IS NULL THEN
	BEGIN
		DECLARE VID INT;
		DECLARE VTOTAL DECIMAL(60,2);
		DECLARE VJML DECIMAL(10,2);
		DECLARE VJENIS TINYINT;
		
		SET VTOTAL = PDATA->>'$.TARIF_HAK.TOTAL';
		SET VJML = PDATA->>'$.TARIF_HAK.JUMLAH';
		
		SELECT r.JENIS_KUNJUNGAN INTO VJENIS
		FROM pembayaran.tagihan_pendaftaran pt
			, pendaftaran.tujuan_pasien tp
			, `master`.ruangan 	r
		WHERE pt.TAGIHAN=PTAGIHAN AND pt.PENDAFTARAN=tp.NOPEN AND pt.UTAMA=1 AND pt.`STATUS`!=0
		  AND tp.SMF!=0 AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3;
		
		IF NOT VJENIS IS NULL THEN
			UPDATE pembayaran.penjamin_tagihan
			   SET TOTAL = TOTAL + IF(PJENIS=2, VTOTAL, (VTOTAL * VJML))
			 WHERE TAGIHAN = PTAGIHAN
			   AND KE = 1;
		ELSE 
			UPDATE pembayaran.penjamin_tagihan
		   SET TOTAL = pembayaran.getTotalTagihan(PTAGIHAN)
		 WHERE TAGIHAN = PTAGIHAN
		   AND KE = 1;
		END IF;
	END;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
