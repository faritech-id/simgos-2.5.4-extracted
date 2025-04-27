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


-- Membuang struktur basisdata untuk lis
USE `lis`;

-- membuang struktur untuk trigger lis.hasil_log_before_insert
DROP TRIGGER IF EXISTS `hasil_log_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_before_insert` BEFORE INSERT ON `hasil_log` FOR EACH ROW BEGIN
	# Vendor Tanpa Order
	IF NEW.VENDOR_LIS = 2 THEN
	BEGIN
		DECLARE VPENDAFTARAN CHAR(10);
		DECLARE VKUNJUNGAN, VHIS_NO_LAB CHAR(19);
		DECLARE VHIS_KODE_TEST INT;
		DECLARE VTINDAKAN_MEDIS CHAR(11);
		DECLARE VGDS TINYINT DEFAULT 0;
		
		# jika status = 1
		IF NEW.STATUS = 1 THEN
			# Hasil tanpa order
			IF NEW.LIS_HASIL != '' THEN # jika hasil valid
				# jika vendor novanet (bioconnect)
				IF NEW.VENDOR_LIS = 2 THEN
					# Jika pemeriksaan gds
					IF NEW.LIS_NAMA_INSTRUMENT = 'Novanet' THEN
					BEGIN
						DECLARE VPREFIX CHAR(1);
						DECLARE VPASIEN INT;
						SET VPREFIX = UPPER(LEFT(NEW.REF, 1));
						SET VPASIEN = CAST(SUBSTRING(NEW.REF, 2) AS UNSIGNED);
						
						SET VGDS = 1;
						
						IF EXISTS(
							SELECT 1 
							  FROM lis.prefix_parameter_lis p 
							 WHERE p.VENDOR_ID = NEW.VENDOR_LIS 
							   AND p.KODE = VPREFIX 
								AND p.LIS_KODE_TEST = NEW.LIS_KODE_TEST
						) THEN
							SET NEW.REF = VPASIEN;
							SET NEW.PREFIX_KODE = VPREFIX;
						END IF;
					END;
					END IF;
				END IF;
				
				IF lis.pasienIsValid(NEW.REF) = 1 THEN # jika pasien valid
					# jika vendor novanet (bioconnect)
					IF NEW.VENDOR_LIS = 2 THEN
						# jika his kode test belum di set
						IF NEW.HIS_KODE_TEST = 0 THEN
						BEGIN
							DECLARE VPARAMETER_TINDAKAN_LAB INT;
							
							SELECT mh.HIS_KODE_TEST, mh.PARAMETER_TINDAKAN_LAB
							  INTO VHIS_KODE_TEST, VPARAMETER_TINDAKAN_LAB
							  FROM lis.mapping_hasil mh
							 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
							   AND mh.LIS_KODE_TEST = NEW.LIS_KODE_TEST
							   AND mh.PREFIX_KODE = NEW.PREFIX_KODE
							 LIMIT 1;
							 
							SET NEW.HIS_KODE_TEST = IFNULL(VHIS_KODE_TEST,0);
							SET VPARAMETER_TINDAKAN_LAB = IFNULL(VPARAMETER_TINDAKAN_LAB, 0);
							IF NEW.HIS_KODE_TEST = 0 OR VPARAMETER_TINDAKAN_LAB = 0 THEN
								SET NEW.STATUS = 3;
							END IF;
						END;
						END IF;
						
						# jika his no lab belum di set
						IF NEW.HIS_NO_LAB = '' THEN
							# ambil jika ada his no lab yg di set sebelumnya dimana lis no sama
							SELECT hl.HIS_NO_LAB
							  INTO VHIS_NO_LAB
							  FROM lis.hasil_log hl
							 WHERE hl.LIS_NO = NEW.LIS_NO
							   AND hl.HIS_NO_LAB != ''
							 LIMIT 1;
							 
							IF VHIS_NO_LAB IS NOT NULL THEN # jika ada
								SET NEW.HIS_NO_LAB = VHIS_NO_LAB;
							ELSE # jika belum di set
								SET VPENDAFTARAN = lis.getPendaftaranTerakhir(NEW.REF);
								# jika pendafaran terakhir valid
								IF VPENDAFTARAN != '' THEN
									# Ambil kunjungan terakhir
									SET VKUNJUNGAN = lis.getKunjunganTerakhir(VPENDAFTARAN);
									IF VKUNJUNGAN != '' THEN
										SET NEW.HIS_NO_LAB = lis.createKunjunganLab(VKUNJUNGAN, VPENDAFTARAN, NEW.LIS_TANGGAL, NEW.LIS_USER, VGDS);
									ELSE
										SET NEW.STATUS = 8;
									END IF;
								ELSE
									SET NEW.STATUS = 5;
								END IF;
							END IF;
						END IF;
						
						# jika his no lab and his kode test valid 
						IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
							SET VTINDAKAN_MEDIS = lis.createTindakanMedis(NEW.HIS_NO_LAB, NEW.HIS_KODE_TEST, NEW.LIS_TANGGAL, NEW.LIS_USER);
						END IF;
					END IF;
				ELSE
					IF LENGTH(NEW.REF) != 10 AND INSTR(NEW.REF, 'QC') = 0 THEN
						SET NEW.STATUS = 4;
					ELSE
						SET NEW.STATUS = 10;
					END IF;
				END IF;
			ELSE 
				SET NEW.STATUS = 9;
			END IF;
		END IF;
	END;
	ELSE
		IF TRIM(NEW.HIS_NO_LAB) = '' OR NEW.HIS_NO_LAB IS NULL THEN
			SET NEW.STATUS = 8;
		END IF;
		
		IF NEW.HIS_KODE_TEST = 0 THEN
			SET NEW.STATUS = 3;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.hasil_log_before_update
DROP TRIGGER IF EXISTS `hasil_log_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_before_update` BEFORE UPDATE ON `hasil_log` FOR EACH ROW BEGIN
	IF OLD.VENDOR_LIS != 2 THEN
		IF TRIM(NEW.HIS_NO_LAB) = '' OR NEW.HIS_NO_LAB IS NULL THEN
			SET NEW.STATUS = 8;
		END IF;
		
		IF OLD.HIS_KODE_TEST = 0 AND NEW.HIS_KODE_TEST = 0 THEN
			SET NEW.STATUS = 3;
		END IF;
	ELSE
	BEGIN
		DECLARE VPENDAFTARAN CHAR(10);
		DECLARE VKUNJUNGAN, VHIS_NO_LAB CHAR(19);
		DECLARE VHIS_KODE_TEST INT;
		DECLARE VTINDAKAN_MEDIS CHAR(11);
		DECLARE VGDS TINYINT DEFAULT 0;
		
		# jika status = 1
		IF NEW.STATUS = 1 THEN
			# Hasil tanpa order
			IF NEW.LIS_HASIL != '' THEN # jika hasil valid
				# jika vendor novanet (bioconnect)
				IF NEW.VENDOR_LIS = 2 THEN
					# Jika pemeriksaan gds
					IF NEW.LIS_NAMA_INSTRUMENT = 'Novanet' THEN
					BEGIN
						DECLARE VPREFIX CHAR(1);
						DECLARE VPASIEN INT;
						SET VPREFIX = UPPER(LEFT(NEW.REF, 1));
						SET VPASIEN = CAST(SUBSTRING(NEW.REF, 2) AS UNSIGNED);
						
						SET VGDS = 1;
						
						IF EXISTS(
							SELECT 1 
							  FROM lis.prefix_parameter_lis p 
							 WHERE p.VENDOR_ID = NEW.VENDOR_LIS 
							   AND p.KODE = VPREFIX 
								AND p.LIS_KODE_TEST = NEW.LIS_KODE_TEST
						) THEN
							SET NEW.REF = VPASIEN;
							SET NEW.PREFIX_KODE = VPREFIX;
						END IF;
					END;
					END IF;
				END IF;
				
				IF lis.pasienIsValid(NEW.REF) = 1 THEN # jika pasien valid
					# jika vendor novanet (bioconnect)
					IF NEW.VENDOR_LIS = 2 THEN
						# jika his kode test belum di set
						IF OLD.HIS_KODE_TEST = 0 AND NEW.HIS_KODE_TEST = 0 THEN
						BEGIN
							DECLARE VPARAMETER_TINDAKAN_LAB INT;
							
							SELECT mh.HIS_KODE_TEST, mh.PARAMETER_TINDAKAN_LAB
							  INTO VHIS_KODE_TEST, VPARAMETER_TINDAKAN_LAB
							  FROM lis.mapping_hasil mh
							 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
							   AND mh.LIS_KODE_TEST = NEW.LIS_KODE_TEST
							   AND mh.PREFIX_KODE = NEW.PREFIX_KODE
							 LIMIT 1;
							 
							SET NEW.HIS_KODE_TEST = IFNULL(VHIS_KODE_TEST,0);
							SET VPARAMETER_TINDAKAN_LAB = IFNULL(VPARAMETER_TINDAKAN_LAB, 0);
							IF NEW.HIS_KODE_TEST = 0 OR VPARAMETER_TINDAKAN_LAB = 0 THEN
								SET NEW.STATUS = 3;
							END IF;
						END;
						END IF;
						
						# jika his no lab belum di set
						IF OLD.HIS_NO_LAB = '' AND NEW.HIS_NO_LAB = '' THEN
							# ambil jika ada his no lab yg di set sebelumnya dimana lis no sama
							SELECT hl.HIS_NO_LAB
							  INTO VHIS_NO_LAB
							  FROM lis.hasil_log hl
							 WHERE hl.LIS_NO = OLD.LIS_NO
							   AND hl.HIS_NO_LAB != ''
							 LIMIT 1;
							 
							IF VHIS_NO_LAB IS NOT NULL THEN # jika ada
								SET NEW.HIS_NO_LAB = VHIS_NO_LAB;
							ELSE # jika belum di set
								SET VPENDAFTARAN = lis.getPendaftaranTerakhir(NEW.REF);
								# jika pendafaran terakhir valid
								IF VPENDAFTARAN != '' THEN
									# Ambil kunjungan terakhir
									SET VKUNJUNGAN = lis.getKunjunganTerakhir(VPENDAFTARAN);
									IF VKUNJUNGAN != '' THEN
										SET NEW.HIS_NO_LAB = lis.createKunjunganLab(VKUNJUNGAN, VPENDAFTARAN, NEW.LIS_TANGGAL, NEW.LIS_USER, VGDS);
									ELSE
										SET NEW.STATUS = 8;
									END IF;
								ELSE
									SET NEW.STATUS = 5;
								END IF;
							END IF;
						END IF;
						
						# jika his no lab and his kode test valid 
						IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
							SET VTINDAKAN_MEDIS = lis.createTindakanMedis(NEW.HIS_NO_LAB, NEW.HIS_KODE_TEST, NEW.LIS_TANGGAL, NEW.LIS_USER);
						END IF;
					END IF;
				ELSE
					IF LENGTH(NEW.REF) != 10 AND INSTR(NEW.REF, 'QC') = 0 THEN
						SET NEW.STATUS = 4;
					ELSE
						SET NEW.STATUS = 10;
					END IF;
				END IF;
			ELSE 
				SET NEW.STATUS = 9;
			END IF;
		END IF;
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
