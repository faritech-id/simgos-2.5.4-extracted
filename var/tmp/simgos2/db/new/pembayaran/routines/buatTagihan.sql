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

-- membuang struktur untuk function pembayaran.buatTagihan
DROP FUNCTION IF EXISTS `buatTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `buatTagihan`(`PNORM` INT, `PPENDAFTARAN` VARCHAR(150)) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VID CHAR(10) DEFAULT '';
	DECLARE VTANGGAL DATETIME;
	
	IF PPENDAFTARAN != '' THEN	
		SET VID = pembayaran.getIdTagihan(PPENDAFTARAN);
	END IF;
	
	IF VID = '' THEN
		SET VTANGGAL = NOW();
		SET VID = generator.generateNoTagihan(DATE(VTANGGAL));
		
		INSERT INTO pembayaran.tagihan(ID, REF, TANGGAL, JENIS)
		VALUES(VID, PNORM, VTANGGAL, 1);
		
		IF PPENDAFTARAN != '' THEN
			INSERT INTO pembayaran.tagihan_pendaftaran(TAGIHAN, PENDAFTARAN)
			VALUES(VID, PPENDAFTARAN);
		END IF;
	ELSE
		IF NOT EXISTS(SELECT 1 FROM pembayaran.tagihan_pendaftaran WHERE TAGIHAN = VID AND PENDAFTARAN = PPENDAFTARAN AND STATUS = 1) THEN
			INSERT INTO pembayaran.tagihan_pendaftaran(TAGIHAN, PENDAFTARAN)
			VALUES(VID, PPENDAFTARAN);
		END IF;
	END IF;
		
	RETURN VID;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
