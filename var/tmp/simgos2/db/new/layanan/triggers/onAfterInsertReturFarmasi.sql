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

-- membuang struktur untuk trigger layanan.onAfterInsertReturFarmasi
DROP TRIGGER IF EXISTS `onAfterInsertReturFarmasi`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onAfterInsertReturFarmasi` AFTER INSERT ON `retur_farmasi` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJUMLAH, VSISA DECIMAL(10, 2);
	DECLARE VBARANG_RUANGAN BIGINT;
	
	SELECT TAGIHAN, JUMLAH INTO VTAGIHAN, VJUMLAH
	  FROM pembayaran.rincian_tagihan rt
	 WHERE rt.REF_ID = NEW.ID_FARMASI
	   AND rt.JENIS = 4;
	   
	IF FOUND_ROWS() > 0 THEN
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			SET VSISA = VJUMLAH - NEW.JUMLAH; 
			IF VSISA = 0 THEN
				CALL pembayaran.batalRincianTagihan(VTAGIHAN, NEW.ID_FARMASI, 4);
			ELSE
				UPDATE pembayaran.rincian_tagihan
				   SET JUMLAH = JUMLAH - NEW.JUMLAH
				 WHERE TAGIHAN = VTAGIHAN
				   AND REF_ID = NEW.ID_FARMASI
				   AND JENIS = 4;
			END IF;
						
			SELECT br.ID INTO VBARANG_RUANGAN
			  FROM layanan.farmasi f
			  		 LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = f.KUNJUNGAN
			  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = f.FARMASI
			 WHERE f.ID = NEW.ID_FARMASI;
			
			IF FOUND_ROWS() > 0 THEN
				INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
			  	     VALUES(VBARANG_RUANGAN, 34, NEW.ID, NEW.TANGGAL, NEW.JUMLAH);
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
