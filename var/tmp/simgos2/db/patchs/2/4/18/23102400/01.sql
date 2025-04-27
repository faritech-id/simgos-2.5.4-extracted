USE `layanan`;
DROP PROCEDURE IF EXISTS `batalFinalPelayananFarmasi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `batalFinalPelayananFarmasi`(IN `PKUNJUNGAN` CHAR(19))
BEGIN
	UPDATE layanan.farmasi
	   SET STATUS = 1
	 WHERE KUNJUNGAN = PKUNJUNGAN
	   AND STATUS IN (2,3);
END//
DELIMITER ;