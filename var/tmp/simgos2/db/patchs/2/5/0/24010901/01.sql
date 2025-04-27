USE `pembayaran`;

DROP TRIGGER IF EXISTS `onAfterUpdateTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTagihan` AFTER UPDATE ON `tagihan` FOR EACH ROW BEGIN
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
		IF OLD.JENIS = 1 THEN
			UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
			   SET p.STATUS = 2
			 WHERE tp.PENDAFTARAN = p.NOMOR
			   AND tp.`STATUS` = 1
				AND tp.TAGIHAN = OLD.ID;
				
			UPDATE pembayaran.pembatalan_tagihan
			   SET STATUS = 2
			 WHERE TAGIHAN = OLD.ID
			   AND STATUS = 1;
		
		ELSEIF OLD.JENIS = 2 THEN
			UPDATE pembayaran.pelunasan_piutang_pasien
			   SET STATUS = 2
			 WHERE ID = OLD.REF;
		
		ELSEIF OLD.JENIS = 3 THEN
			UPDATE pembayaran.pelunasan_piutang_perusahaan
			   SET STATUS = 2
			 WHERE ID = OLD.REF;
			 
		ELSEIF OLD.JENIS = 4 THEN
			UPDATE penjualan.penjualan
			   SET STATUS = 2
			 WHERE NOMOR = OLD.ID;
		END IF;
	END IF;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 AND OLD.STATUS = 2 THEN
	BEGIN
		DECLARE VJENIS TINYINT DEFAULT 1;
		DECLARE VSTATUS TINYINT DEFAULT 1;
		
		SELECT pt.JENIS
		  INTO VJENIS
		  FROM pembayaran.pembatalan_tagihan pt 
		 WHERE pt.TAGIHAN = OLD.ID 
		   AND pt.STATUS = 1
		 LIMIT 1;
		 
		IF NOT VJENIS IS NULL THEN
			SET VSTATUS = IF(VJENIS = 1, 1, 0);
			UPDATE pembayaran.pembayaran_tagihan 
			   SET STATUS = VSTATUS 
			 WHERE TAGIHAN = OLD.ID
			   AND JENIS IN (1, 8)
			   AND STATUS = 2;
			
			IF OLD.JENIS = 1 THEN				
				UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
				   SET p.STATUS = 1
				 WHERE tp.PENDAFTARAN = p.NOMOR
				   AND tp.`STATUS` = 1
					AND tp.TAGIHAN = OLD.ID;
			END IF;
			
			IF OLD.JENIS = 2 THEN
				UPDATE pembayaran.pelunasan_piutang_pasien
				   SET STATUS = 1
				 WHERE ID = OLD.REF;
			END IF;
			
			IF OLD.JENIS = 3 THEN
				UPDATE pembayaran.pelunasan_piutang_perusahaan
				   SET STATUS = 1
				 WHERE ID = OLD.REF;
			END IF;
		END IF;
	END;
	END IF;
	
	IF NEW.STATUS != OLD.STATUS AND OLD.STATUS = 1 AND NEW.STATUS = 0 THEN
		IF OLD.JENIS = 4 THEN
			UPDATE penjualan.penjualan
			   SET STATUS = 0
			 WHERE NOMOR = OLD.ID;
		END IF;
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;