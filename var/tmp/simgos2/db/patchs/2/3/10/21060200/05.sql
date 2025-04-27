USE pembayaran;

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
		-- update status pelunasana piutang pasien	   
		ELSEIF OLD.JENIS = 2 THEN
			UPDATE pembayaran.pelunasan_piutang_pasien
			   SET STATUS = 2
			 WHERE ID = OLD.REF;
		-- update status pelunasana piutang perusahaan
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
		IF EXISTS(SELECT 1 FROM pembayaran.pembatalan_tagihan WHERE TAGIHAN = OLD.ID AND STATUS = 1) THEN
			UPDATE pembayaran.pembayaran_tagihan SET STATUS = 0 WHERE TAGIHAN = OLD.ID;
			
			IF OLD.JENIS = 1 THEN				
				UPDATE pendaftaran.pendaftaran p, pembayaran.tagihan_pendaftaran tp
				   SET p.STATUS = 1
				 WHERE tp.PENDAFTARAN = p.NOMOR
				   AND tp.`STATUS` = 1
					AND tp.TAGIHAN = OLD.ID;
			END IF;
			-- update status pelunasana piutang pasien
			IF OLD.JENIS = 2 THEN
				UPDATE pembayaran.pelunasan_piutang_pasien
				   SET STATUS = 1
				 WHERE ID = OLD.REF;
			END IF;
			-- update status pelunasana piutang perusahaan
			IF OLD.JENIS = 3 THEN
				UPDATE pembayaran.pelunasan_piutang_perusahaan
				  SET STATUS = 1
				WHERE ID = OLD.REF;
			END IF;
			
		END IF;							
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
