USE pembayaran;

DROP TRIGGER IF EXISTS `penjamin_tagihan_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `penjamin_tagihan_before_insert` BEFORE INSERT ON `penjamin_tagihan` FOR EACH ROW BEGIN
	DECLARE VKE TINYINT DEFAULT 1;
	
	SELECT MAX(KE) INTO VKE
	  FROM pembayaran.penjamin_tagihan pt
	 WHERE pt.TAGIHAN = NEW.TAGIHAN;
	   
	IF FOUND_ROWS() = 0 THEN
		SET VKE = 1;
		
		IF EXISTS(SELECT 1
			  FROM pembayaran.tagihan_pendaftaran tp
			  		 , pendaftaran.penjamin p
			 WHERE tp.TAGIHAN = NEW.TAGIHAN
			   AND tp.UTAMA = 1
			   AND p.NOPEN = tp.PENDAFTARAN
				AND p.JENIS = 1) THEN
				SET VKE = VKE + 1;
		END IF;
	ELSE 
		SET VKE = IFNULL(VKE, 0) + 1;
	END IF;
	
	SET NEW.KE = VKE;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
