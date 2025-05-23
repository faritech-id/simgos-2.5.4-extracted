USE `layanan`;
-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure layanan.executeRecalculateMutasiBarang
DROP PROCEDURE IF EXISTS `executeRecalculateMutasiBarang`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `executeRecalculateMutasiBarang`(IN `PKUNJUNGAN` CHAR(50), IN `PTANGGAL` DATETIME, IN `PFARMASI` INT, IN `PJUMLAH` DECIMAL(10,2), IN `PBON` DECIMAL(10,2), IN `PHARI` INT, IN `PID` CHAR(50), IN `PTINDAKAN_PAKET` INT, IN `PJENIS_MUTASI` INT)
BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTAGIHAN CHAR(10);
	
	DECLARE VNORM CHAR(10);
	DECLARE VBATAS DATE;
	DECLARE VJML_ROWBTS INT(3);
	DECLARE VHARI INT(5);
	DECLARE VSTATUS_VALIDASI_HARI INT(5);
	
	DECLARE VTGLFINALKUNJUNGAN DATETIME;
	
	IF PJENIS_MUTASI = 1 THEN /* Mutasi Pelayanan */
		
			SELECT br.ID, IF(k.KELUAR IS NULL, PTANGGAL, k.KELUAR) INTO VBARANG_RUANGAN, VTGLFINALKUNJUNGAN
			  FROM pendaftaran.kunjungan k
			  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = PFARMASI
			 WHERE k.NOMOR = PKUNJUNGAN
			 LIMIT 1;
			 
			IF FOUND_ROWS() > 0 THEN
				INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
					  VALUES(VBARANG_RUANGAN, 33, PID, VTGLFINALKUNJUNGAN, (PJUMLAH - PBON));
			END IF;
			
			
			SELECT ID INTO VSTATUS_VALIDASI_HARI FROM aplikasi.properti_config WHERE ID = 53 AND VALUE = 'TRUE';
			IF VSTATUS_VALIDASI_HARI > 0 THEN
				SET VHARI = PHARI;
			ELSE
				SET VHARI = IF(PHARI > 0,PHARI,1);
			END IF;
			
			SELECT COUNT(*), p.NORM, DATE_FORMAT(ADDDATE(VTGLFINALKUNJUNGAN, VHARI),'%Y-%m-%d') BATAS INTO VJML_ROWBTS, VNORM, VBATAS
			FROM pendaftaran.pendaftaran p WHERE p.NOMOR = VNOPEN;
			
			IF VJML_ROWBTS > 0 THEN
				INSERT INTO layanan.batas_layanan_obat (NORM,FARMASI,TANGGAL,STATUS,REF) VALUES (VNORM,PFARMASI,VBATAS,1,PID);
			END IF;
			
			
			
			IF PBON > 0 THEN
				INSERT INTO layanan.bon_sisa_farmasi (REF, FARMASI, JUMLAH, SISA, TANGGAL, STATUS) VALUES (PID, PFARMASI, PBON, PBON, PTANGGAL, 1);
			END IF;
			
			IF PTINDAKAN_PAKET = 0 THEN 
				CALL pembayaran.storeFarmasi(PKUNJUNGAN, PID, PFARMASI, PJUMLAH);
			END IF;
	END IF;
	
	IF PJENIS_MUTASI = 99 THEN
	
		SELECT br.ID, k.KELUAR INTO VBARANG_RUANGAN, VTGLFINALKUNJUNGAN
		  FROM pendaftaran.kunjungan k
		  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = PFARMASI
		 WHERE k.NOMOR = PKUNJUNGAN
		 LIMIT 1;
		 
		IF FOUND_ROWS() > 0 THEN
			INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
				  VALUES(VBARANG_RUANGAN, 35, PID, VTGLFINALKUNJUNGAN, (PJUMLAH - PBON));
		END IF;
		
		UPDATE layanan.batas_layanan_obat SET STATUS = 0 WHERE REF = PID;
		
		CALL pembayaran.batalkanStoreFarmasi(PKUNJUNGAN, PID, PFARMASI, PJUMLAH);
		
		
		IF PBON > 0 THEN
			UPDATE layanan.bon_sisa_farmasi SET STATUS = 0 WHERE REF = PID AND STATUS = 1;
		END IF;
		
	END IF;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;