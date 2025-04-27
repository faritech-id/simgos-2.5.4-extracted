USE `layanan`;
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

-- Dumping structure for trigger layanan.layanan_bon_sisa_farmasi_after_insert
DROP TRIGGER IF EXISTS `layanan_bon_sisa_farmasi_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `layanan_bon_sisa_farmasi_after_insert` AFTER INSERT ON `layanan_bon_sisa_farmasi` FOR EACH ROW BEGIN
	DECLARE VJMLROW INT(11);
	DECLARE VBARANG_RUANGAN INT(11);
	
	SELECT COUNT(*) JML_ROW, br.ID 
	  INTO VJMLROW, VBARANG_RUANGAN
	  FROM layanan.bon_sisa_farmasi b, layanan.farmasi f, pendaftaran.kunjungan k
		   LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
	 WHERE k.NOMOR = f.KUNJUNGAN 
	   AND f.ID = b.REF 
	   AND b.ID = NEW.REF 
	 LIMIT 1;
	 
	IF VJMLROW > 0 THEN
		INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
			 VALUES (VBARANG_RUANGAN, 64, NEW.ID, NEW.TANGGAL, NEW.JUMLAH);
	END IF;
	
	UPDATE layanan.bon_sisa_farmasi 
	   SET SISA = (SISA - NEW.JUMLAH) 
	 WHERE ID = NEW.REF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;