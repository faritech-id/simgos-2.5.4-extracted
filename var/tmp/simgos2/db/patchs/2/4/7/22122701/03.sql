-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk trigger layanan.onAfterUpdateFarmasi
DROP TRIGGER IF EXISTS `onAfterUpdateFarmasi`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateFarmasi` AFTER UPDATE ON `farmasi` FOR EACH ROW BEGIN
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTAGIHAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VNORM CHAR(10);
	DECLARE VBATAS DATE;
	DECLARE VJML_ROWBTS INT(3);
	DECLARE VREF CHAR(21);
	DECLARE VPENJAMIN, VPAKET SMALLINT;
	
	IF NEW.STATUS != OLD.STATUS THEN
		SELECT k.NOPEN, k.RUANGAN, k.REF, p.PAKET, pj.JENIS
		  INTO VNOPEN, VRUANGAN, VREF, VPAKET, VPENJAMIN
		  FROM pendaftaran.kunjungan k,
		  	    pendaftaran.pendaftaran p,
		  		 pendaftaran.penjamin pj
		 WHERE k.NOMOR = OLD.KUNJUNGAN
		   AND p.NOMOR = k.NOPEN
		   AND pj.NOPEN = p.NOMOR
		 LIMIT 1;
		
		IF NOT VNOPEN IS NULL THEN
		BEGIN
			DECLARE VJENIS_KUNJUNGAN TINYINT;
			
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			
			IF VPAKET IS NULL OR VPAKET = 0 THEN
				SELECT r.JENIS_KUNJUNGAN
				  INTO VJENIS_KUNJUNGAN
				  FROM layanan.order_resep orp,
				  	    pendaftaran.kunjungan k,
				  	    `master`.ruangan r
				 WHERE orp.NOMOR = VREF
				   AND k.NOMOR = orp.KUNJUNGAN
				   AND r.ID = k.RUANGAN
				 LIMIT 1;
				 
				IF NOT VJENIS_KUNJUNGAN IS NULL THEN
					IF VJENIS_KUNJUNGAN != 3 THEN # Rawat Jalan
						IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
							SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, OLD.KUNJUNGAN);
							IF VTAGIHAN_TERPISAH != '' THEN
								SET VTAGIHAN = VTAGIHAN_TERPISAH;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF OLD.STATUS = 1 AND NEW.STATUS = 2 THEN
					IF OLD.FARMASI > 0 THEN
						IF OLD.ALASAN_TIDAK_TERLAYANI = '' OR OLD.ALASAN_TIDAK_TERLAYANI IS NULL THEN
							BEGIN
								SELECT br.ID 
								  INTO VBARANG_RUANGAN
								  FROM pendaftaran.kunjungan k
								  	   LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
								 WHERE k.NOMOR = NEW.KUNJUNGAN
								 LIMIT 1;
								 
								IF NOT VBARANG_RUANGAN IS NULL THEN
									INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
										 VALUES (VBARANG_RUANGAN, 33, OLD.ID, OLD.TANGGAL, (NEW.JUMLAH - NEW.BON));
								END IF;
								
								SELECT COUNT(*), p.NORM, DATE_FORMAT(ADDDATE(OLD.TANGGAL, NEW.HARI),'%Y-%m-%d') BATAS 
								  INTO VJML_ROWBTS, VNORM, VBATAS
								  FROM pendaftaran.pendaftaran p 
								 WHERE p.NOMOR = VNOPEN;
								
								IF VJML_ROWBTS > 0 THEN
									INSERT INTO layanan.batas_layanan_obat (NORM,FARMASI,TANGGAL,STATUS,REF) 
									     VALUES (VNORM,NEW.FARMASI,VBATAS,1,NEW.ID);
								END IF;
								
								IF NEW.BON > 0 THEN
									INSERT INTO layanan.bon_sisa_farmasi (REF, FARMASI, JUMLAH, SISA, TANGGAL, STATUS) 
									     VALUES (OLD.ID, NEW.FARMASI, OLD.BON, OLD.BON, OLD.TANGGAL, 1);
								END IF;
							END;
							
							IF NEW.TINDAKAN_PAKET = 0 THEN 
								CALL pembayaran.storeFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
							END IF;
						END IF;
					END IF;
				ELSEIF OLD.STATUS = 2 AND NEW.STATUS = 1 THEN
					IF NEW.FARMASI > 0 THEN										
						IF OLD.ALASAN_TIDAK_TERLAYANI = '' OR OLD.ALASAN_TIDAK_TERLAYANI IS NULL THEN
							BEGIN
								SELECT br.ID 
								  INTO VBARANG_RUANGAN
								  FROM pendaftaran.kunjungan k
								  	   LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
								 WHERE k.NOMOR = NEW.KUNJUNGAN
								 LIMIT 1;
								 
								IF NOT VBARANG_RUANGAN IS NULL THEN
									INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
										 VALUES (VBARANG_RUANGAN, 35, OLD.ID, OLD.TANGGAL, (OLD.JUMLAH - OLD.BON));
								END IF;
								
								UPDATE layanan.batas_layanan_obat 
								   SET STATUS = 0 
								 WHERE REF = NEW.ID;
							END;			
							
							CALL pembayaran.batalkanStoreFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
						END IF;
						
						IF OLD.BON > 0 THEN
							UPDATE layanan.bon_sisa_farmasi 
							   SET STATUS = 0 
							 WHERE REF = NEW.ID 
							   AND STATUS = 1;
						END IF;
					END IF;
				END IF;
			END IF;
		END;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger layanan.onAfterUpdateTindakanMedis
DROP TRIGGER IF EXISTS `onAfterUpdateTindakanMedis`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTindakanMedis` AFTER UPDATE ON `tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VTAGIHAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VKELAS TINYINT DEFAULT 0;
	DECLARE VPENJAMIN, VPAKET SMALLINT;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS, p.PAKET, pj.JENIS
		  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS, VPAKET, VPENJAMIN
		  FROM pendaftaran.kunjungan k
		  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
				 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
		  		 master.ruangan r,
		  		 pendaftaran.pendaftaran p,
		  		 pendaftaran.penjamin pj
		 WHERE k.RUANGAN = r.ID
		   AND k.NOMOR = NEW.KUNJUNGAN
		   AND p.NOMOR = k.NOPEN
		   AND pj.NOPEN = p.NOMOR
		 LIMIT 1;
		
		IF NOT VNOPEN IS NULL THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			
			IF VPAKET IS NULL OR VPAKET = 0 THEN
				IF VJENIS_KUNJUNGAN != 3 THEN # Rawat Jalan
					IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
						SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, NEW.KUNJUNGAN);
						IF VTAGIHAN_TERPISAH != '' THEN
							SET VTAGIHAN = VTAGIHAN_TERPISAH;
						END IF;
					END IF;
				END IF;
			END IF;
			
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF VTAGIHAN != '' THEN
					CALL pembayaran.batalRincianTagihan(VTAGIHAN, OLD.ID, 3);
				END IF;
			END IF;
		END IF;
		
		IF EXISTS(SELECT 1 FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'lis') THEN
			UPDATE lis.order_item_log
			   SET STATUS = 1
			WHERE HIS_ID = NEW.ID;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
