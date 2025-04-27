DROP TRIGGER IF EXISTS pembayaran.onAfterInsertPembayaranTagihan;
USE pembayaran;

DELIMITER $$
$$
CREATE DEFINER=`root`@`127.0.0.1` TRIGGER `onAfterInsertPembayaranTagihan` AFTER INSERT ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.JENIS IN (1, 4, 8) AND NEW.STATUS = 2 THEN 
		UPDATE pembayaran.tagihan
		   SET STATUS = 2
		 WHERE ID = NEW.TAGIHAN
		   AND STATUS = 1;
		   
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		VALUES(CONCAT("CALL pembayaran.procStoreTagihanKlaim('", DATE(NEW.TANGGAL), "', '", DATE(NEW.TANGGAL), "')"), 1);
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS pembayaran.pembayaran_tagihan_after_update;
USE pembayaran;

DELIMITER $$
$$
CREATE DEFINER=`root`@`127.0.0.1` TRIGGER `pembayaran_tagihan_after_update` AFTER UPDATE ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
	   IF NEW.JENIS IN (1, 4, 8) THEN  
			UPDATE pembayaran.tagihan
			   SET STATUS = 2
			 WHERE ID = NEW.TAGIHAN
			   AND STATUS = 1;
			
			INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
			VALUES(CONCAT("CALL pembayaran.procStoreTagihanKlaim('", DATE(NEW.TANGGAL), "', '", DATE(NEW.TANGGAL), "')"), 1);
		END IF;
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END$$
DELIMITER ;