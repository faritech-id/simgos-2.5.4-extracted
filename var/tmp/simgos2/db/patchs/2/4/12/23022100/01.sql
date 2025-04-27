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

-- Dumping structure for trigger layanan.onAfterUpdateFarmasi
DROP TRIGGER IF EXISTS `onAfterUpdateFarmasi`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateFarmasi` AFTER UPDATE ON `farmasi` FOR EACH ROW BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTAGIHAN CHAR(10);
	
	DECLARE VNORM CHAR(10);
	DECLARE VBATAS DATE;
	DECLARE VJML_ROWBTS INT(3);
	DECLARE VHARI INT(5);
	DECLARE VSTATUS_VALIDASI_HARI INT(5);
	
	IF NEW.STATUS != OLD.STATUS THEN
		SELECT k.NOPEN
		  INTO VNOPEN
		  FROM pendaftaran.kunjungan k
		 WHERE k.NOMOR = OLD.KUNJUNGAN
		 LIMIT 1;
		
		IF FOUND_ROWS() > 0 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				#IF OLD.STATUS = 1 AND NEW.STATUS = 2 THEN
				IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 2 THEN
					IF NEW.FARMASI > 0 THEN
						IF NEW.ALASAN_TIDAK_TERLAYANI = "" OR NEW.ALASAN_TIDAK_TERLAYANI IS NULL THEN
							BEGIN
								IF OLD.ALASAN_TIDAK_TERLAYANI = "" THEN
									INSERT temp.trace_farmasi(REF_ID) VALUES(NEW.ID);
								END IF;
								
								SELECT br.ID INTO VBARANG_RUANGAN
								  FROM pendaftaran.kunjungan k
								  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
								 WHERE k.NOMOR = NEW.KUNJUNGAN
								 LIMIT 1;
								 
								IF FOUND_ROWS() > 0 THEN
									INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
										  VALUES(VBARANG_RUANGAN, 33, NEW.ID, NEW.TANGGAL, (NEW.JUMLAH - NEW.BON));
								END IF;
								
								
								SELECT ID INTO VSTATUS_VALIDASI_HARI FROM aplikasi.properti_config WHERE ID = 53 AND VALUE = 'TRUE';
								IF VSTATUS_VALIDASI_HARI > 0 THEN
								
									SET VHARI = IF(NEW.HARI > 0,NEW.HARI,1);
									SELECT COUNT(*), p.NORM, DATE_FORMAT(ADDDATE(OLD.TANGGAL, VHARI),'%Y-%m-%d') BATAS INTO VJML_ROWBTS, VNORM, VBATAS
									FROM pendaftaran.pendaftaran p WHERE p.NOMOR = VNOPEN;
									
									IF VJML_ROWBTS > 0 THEN
										INSERT INTO layanan.batas_layanan_obat (NORM,FARMASI,TANGGAL,STATUS,REF) VALUES (VNORM,NEW.FARMASI,VBATAS,1,NEW.ID);
									END IF;
									
								END IF;						
								
								
								IF NEW.BON > 0 THEN
									INSERT INTO layanan.bon_sisa_farmasi (REF, FARMASI, JUMLAH, SISA, TANGGAL, STATUS) VALUES (OLD.ID, NEW.FARMASI, OLD.BON, OLD.BON, OLD.TANGGAL, 1);
								END IF;
								
							END;
							
							IF NEW.TINDAKAN_PAKET = 0 THEN 
								CALL pembayaran.storeFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
							END IF;
						END IF;
					END IF;
				ELSEIF OLD.STATUS = 2 AND NEW.STATUS = 1 THEN
					IF NEW.FARMASI > 0 THEN										
						IF OLD.ALASAN_TIDAK_TERLAYANI = "" OR OLD.ALASAN_TIDAK_TERLAYANI IS NULL THEN
							BEGIN
								SELECT br.ID INTO VBARANG_RUANGAN
								  FROM pendaftaran.kunjungan k
								  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
								 WHERE k.NOMOR = NEW.KUNJUNGAN
								 LIMIT 1;
								 
								IF FOUND_ROWS() > 0 THEN
									INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
										  VALUES(VBARANG_RUANGAN, 35, OLD.ID, OLD.TANGGAL, (OLD.JUMLAH - OLD.BON));
								END IF;
								
								SELECT ID INTO VSTATUS_VALIDASI_HARI FROM aplikasi.properti_config WHERE ID = 53 AND VALUE = 'TRUE';
								IF VSTATUS_VALIDASI_HARI > 0 THEN
									UPDATE layanan.batas_layanan_obat SET STATUS = 0 WHERE REF = NEW.ID;
								END IF;
								
							END;			
							
							CALL pembayaran.batalkanStoreFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
						END IF;
						
						
						IF OLD.BON > 0 THEN
							UPDATE layanan.bon_sisa_farmasi SET STATUS = 0 WHERE REF = NEW.ID AND STATUS = 1;
						END IF;
						
						
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;