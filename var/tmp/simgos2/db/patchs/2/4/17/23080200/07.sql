USE `medicalrecord`;

DROP TRIGGER IF EXISTS `rekonsiliasi_admisi_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rekonsiliasi_admisi_after_update` AFTER UPDATE ON `rekonsiliasi_admisi` FOR EACH ROW BEGIN

	IF NEW.STATUS = 2 THEN
 		UPDATE medicalrecord.rekonsiliasi_admisi_detil rad
			SET rad.STATUS = 2
		WHERE rad.REKONSILIASI_ADMISI = OLD.ID AND rad.STATUS=1;
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
