USE pendaftaran;

DROP TRIGGER IF EXISTS `onAfterUpdateReservasi`;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateReservasi` AFTER UPDATE ON `reservasi` FOR EACH ROW BEGIN

 IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 0 THEN
  UPDATE master.ruang_kamar_tidur SET STATUS = 1 WHERE ID = OLD.RUANG_KAMAR_TIDUR;
 END IF;
 
  IF NEW.STATUS = 2 THEN
  	UPDATE pendaftaran.antrian_tempat_tidur SET STATUS = 3 WHERE STATUS = 2 AND RESERVASI_NOMOR = OLD.NOMOR;
 END IF;
 
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
