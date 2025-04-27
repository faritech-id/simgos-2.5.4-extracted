USE `inventory`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for function inventory.isValidasiRetriksiPelayananResep
DROP FUNCTION IF EXISTS `isValidasiRetriksiPelayananResep`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `isValidasiRetriksiPelayananResep`(`PKUNJUNGAN` CHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE VTGLFINALKUNJUNGAN DATE;
	DECLARE VNORM INT;
	DECLARE VPASIENPLNG SMALLINT;
	
	SET VTGLFINALKUNJUNGAN = DATE(NOW());
	
	IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 43 AND p.VALUE = 'TRUE') THEN
		SELECT IF(kj.KELUAR IS NULL,NOW(),kj.KELUAR), pnd.NORM, ords.RESEP_PASIEN_PULANG INTO VTGLFINALKUNJUNGAN, VNORM, VPASIENPLNG
		FROM pendaftaran.kunjungan kj, layanan.order_resep ords, pendaftaran.pendaftaran pnd
		WHERE pnd.NOMOR = kj.NOPEN AND ords.NOMOR = kj.REF AND kj.NOMOR = PKUNJUNGAN
		LIMIT 1;
		
		IF VPASIENPLNG > 0 THEN
			IF NOT EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 81 AND p.VALUE = 'TRUE') THEN
				IF EXISTS(
					SELECT 1 FROM layanan.farmasi f, layanan.batas_layanan_obat bts
					WHERE bts.FARMASI = f.FARMASI AND bts.`STATUS` = 1 AND bts.NORM = VNORM AND bts.TANGGAL > VTGLFINALKUNJUNGAN AND f.KUNJUNGAN = PKUNJUNGAN) THEN
					RETURN 1;
				END IF;
			END IF;
		ELSE
			IF EXISTS(
				SELECT 1 FROM layanan.farmasi f, layanan.batas_layanan_obat bts
				WHERE bts.FARMASI = f.FARMASI AND bts.`STATUS` = 1 AND bts.NORM = VNORM AND bts.TANGGAL > VTGLFINALKUNJUNGAN AND f.KUNJUNGAN = PKUNJUNGAN) THEN
				RETURN 1;
			END IF;
		END IF;
		
	END IF;
	
	RETURN 0;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;