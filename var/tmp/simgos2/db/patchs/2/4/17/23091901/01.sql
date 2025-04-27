-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.storeTindakanMedis
DROP PROCEDURE IF EXISTS `storeTindakanMedis`;
DELIMITER //
CREATE PROCEDURE `storeTindakanMedis`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PTINDAKAN_MEDIS` CHAR(11),
	IN `PTINDAKAN` SMALLINT
)
BEGIN
	DECLARE VNOPEN, VTAGIHAN, VRUANGAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID, VTARIF_HAK_ID INT;
	DECLARE VTARIF, VTARIF_HAK INT;
	DECLARE VKELAS, VKELAS_RAWAT, VKELAS_HAK SMALLINT DEFAULT 0;
	DECLARE VPAKET, VPENJAMIN SMALLINT DEFAULT FALSE;
	DECLARE VQTY, VPERSENTASE DECIMAL(60,2) DEFAULT 0.0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VJUMLAH DECIMAL(60,2) DEFAULT 1.0;
	DECLARE VREF CHAR(21);
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN, VTANGGAL DATETIME;
	
	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(r.JENIS_KUNJUNGAN = 3, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS))
			 , IF(rkls.KELAS IS NULL, 0, rkls.KELAS)) KELAS
			 , p.PAKET, k.REF, p.TANGGAL, tm.TANGGAL, k.RUANGAN, pj.JENIS, grk.KELAS
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS
	       , VPAKET, VREF, VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN, VRUANGAN, VPENJAMIN, VKELAS_HAK
	  FROM layanan.tindakan_medis tm,
	  		 pendaftaran.kunjungan k
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r
			 LEFT JOIN master.ruangan_kelas rkls ON rkls.RUANGAN = r.ID AND rkls.`STATUS` = 1,
	  		 pendaftaran.pendaftaran p,
	  		 pendaftaran.penjamin pj
	  		 LEFT JOIN master.group_referensi_kelas grk ON grk.REFERENSI_KELAS = pj.KELAS
	 WHERE tm.ID = PTINDAKAN_MEDIS
	   AND k.NOMOR = PKUNJUNGAN
	 	AND k.NOMOR = tm.KUNJUNGAN	 	
	 	AND k.RUANGAN = r.ID
		AND p.NOMOR = k.NOPEN
		AND pj.NOPEN = p.NOMOR
	 LIMIT 1;
	
	IF NOT VNOPEN IS NULL THEN
		SET VTANGGAL = VTANGGAL_TINDAKAN;
		
		SELECT grk.KELAS INTO VKELAS_RAWAT
		  FROM master.group_referensi_kelas grk
		 WHERE grk.REFERENSI_KELAS = VKELAS;
		
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 6
			   AND VALUE = 'TRUE') THEN
			SET VTANGGAL = VTANGGAL_PENDAFTARAN;
		END IF;
									
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		SET VJUMLAH = pembayaran.getJumlahItemRincianPaket(VTAGIHAN, PTINDAKAN, 1) + 1;
		
		IF VPAKET IS NULL OR VPAKET = 0 THEN
			IF VJENIS_KUNJUNGAN != 3 AND NOT VREF IS NULL THEN
				IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
					SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, PKUNJUNGAN);
					IF VTAGIHAN_TERPISAH != '' THEN
						SET VTAGIHAN = VTAGIHAN_TERPISAH;
					END IF;
				END IF;
			END IF;
		END IF;
		
		IF NOT (VJENIS_KUNJUNGAN = 3 AND NOT VREF IS NULL) THEN
			BEGIN
				DECLARE VKUNJUNGAN CHAR(19);
				DECLARE VKELAS_SBLM TINYINT;
				
				SELECT r.KUNJUNGAN INTO VKUNJUNGAN
				  FROM (
					SELECT k.KUNJUNGAN
					  FROM pendaftaran.konsul k
					 WHERE k.NOMOR = VREF
					 UNION
					SELECT ol.KUNJUNGAN
					  FROM layanan.order_lab ol
					 WHERE ol.NOMOR = VREF
					 UNION
					SELECT ora.KUNJUNGAN
					  FROM layanan.order_rad ora
					 WHERE ora.NOMOR = VREF
					) r;
					
				IF VJENIS_KUNJUNGAN = 2 THEN
					SET VKUNJUNGAN = PKUNJUNGAN;
				END IF;
				
				IF NOT VKUNJUNGAN IS NULL OR VJENIS_KUNJUNGAN = 2 THEN
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 7
						   AND VALUE = 'TRUE') THEN
						SELECT IF(r.JENIS_KUNJUNGAN = 3, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS))
			 				    , IF(rkls.KELAS IS NULL, 0, rkls.KELAS)) KELAS
						  INTO VKELAS_SBLM
						  FROM pendaftaran.kunjungan k
						  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
								 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 					 master.ruangan r
	  		 					 LEFT JOIN master.ruangan_kelas rkls ON rkls.RUANGAN = r.ID AND rkls.`STATUS` = 1
						 WHERE k.NOMOR = VKUNJUNGAN
							AND k.RUANG_KAMAR_TIDUR > 0
							AND k.RUANGAN = r.ID
							AND NOT k.`STATUS` = 0;
							
						IF NOT VKELAS_SBLM IS NULL THEN
							IF VKELAS_SBLM > 0 THEN
								SET VKELAS = VKELAS_SBLM;
							END IF;
						END IF;
					END IF;
					
					SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, VKUNJUNGAN);
					IF VKELAS_SBLM > 0 THEN
						SET VKELAS = VKELAS_SBLM;
					END IF;
				END IF;
			END;
		END IF;		
				
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 1, PTINDAKAN, VRUANGAN, VQTY, VPAKET_DETIL);
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VJUMLAH <= VQTY THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PTINDAKAN_MEDIS, VTANGGAL, 1, 1);
				END IF;
			END IF;
			
			IF VTAGIHAN != '' AND (VPAKET_DETIL = 0 OR VJUMLAH > VQTY) THEN			
				CALL master.getTarifTindakan(PTINDAKAN, VKELAS, VTANGGAL, VTARIF_ID, VTARIF);
				
				IF VKELAS_RAWAT > VKELAS_HAK THEN
		      	CALL master.getTarifTindakan(PTINDAKAN, VKELAS_HAK, VTANGGAL, VTARIF_HAK_ID, VTARIF_HAK);
		      ELSE
		      	SET VTARIF_HAK_ID = VTARIF_ID;
		      	SET VTARIF_HAK = VTARIF;
		      END IF;
				
				SET VPERSENTASE = penjamin_rs.getKenaikanTarif(VPENJAMIN, 3, VTANGGAL);
				IF VPERSENTASE > 0 THEN
					SET VTARIF = VTARIF + (VTARIF * VPERSENTASE);
				END IF;
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PTINDAKAN_MEDIS, 3, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0, 
					JSON_OBJECT(
						'TARIF_HAK', JSON_OBJECT('ID', VTARIF_HAK_ID, 'TOTAL', VTARIF_HAK, 'JUMLAH', 1)
					)
				);
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getIdTagihan
DROP FUNCTION IF EXISTS `getIdTagihan`;
DELIMITER //
CREATE FUNCTION `getIdTagihan`(
	`PPENDAFTARAN` VARCHAR(150)
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VID CHAR(10);
	
	SELECT tp.TAGIHAN INTO VID 
	  FROM pembayaran.tagihan_pendaftaran tp,
	  		 pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.gabung_tagihan gt ON gt.KE = t.ID
	 WHERE tp.PENDAFTARAN = PPENDAFTARAN
	   AND tp.REF = ''
	   AND tp.STATUS = 1
		AND t.ID = tp.TAGIHAN
	 ORDER BY IFNULL(gt.TANGGAL, t.TANGGAL) DESC LIMIT 1;
	
	IF VID IS NULL THEN
		RETURN '';
	END IF;
	
	RETURN VID;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getIdTagihanTerpisah
DROP FUNCTION IF EXISTS `getIdTagihanTerpisah`;
DELIMITER //
CREATE FUNCTION `getIdTagihanTerpisah`(
	`PPENDAFTARAN` VARCHAR(150),
	`PREF` VARCHAR(25)
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VID CHAR(10);
	
	SELECT tp.TAGIHAN INTO VID 
	  FROM pembayaran.tagihan_pendaftaran tp,
	  		 pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.gabung_tagihan gt ON gt.KE = t.ID
	 WHERE tp.PENDAFTARAN = PPENDAFTARAN
	   AND tp.REF = PREF
	   AND tp.STATUS = 1
		AND t.ID = tp.TAGIHAN
	 ORDER BY IFNULL(gt.TANGGAL, t.TANGGAL) DESC LIMIT 1;
	
	IF VID IS NULL THEN
		RETURN '';
	END IF;
	
	RETURN VID;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getInfoTagihanKunjungan
DROP FUNCTION IF EXISTS `getInfoTagihanKunjungan`;
DELIMITER //
CREATE FUNCTION `getInfoTagihanKunjungan`(
	`PTAGIHAN` CHAR(10)
) RETURNS varchar(100) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VKUNJUNGANS VARCHAR(100);
	
	SELECT GROUP_CONCAT(DISTINCT ref.DESKRIPSI) INTO VKUNJUNGANS
	  FROM pembayaran.tagihan_pendaftaran tp
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = tp.PENDAFTARAN
	  		 LEFT JOIN pendaftaran.tujuan_pasien tpsn ON tpsn.NOPEN = p.NOMOR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = tpsn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 15 AND ref.ID = r.JENIS_KUNJUNGAN
	 WHERE tp.STATUS = 1
	   AND tp.TAGIHAN = PTAGIHAN;
	
	IF VKUNJUNGANS IS NULL THEN
		SET VKUNJUNGANS = '';
	END IF;
	   
	RETURN VKUNJUNGANS;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getKelasRJMengikutiKelasRIYgPertama
DROP FUNCTION IF EXISTS `getKelasRJMengikutiKelasRIYgPertama`;
DELIMITER //
CREATE FUNCTION `getKelasRJMengikutiKelasRIYgPertama`(
	`PTAGIHAN` CHAR(10),
	`PKUNJUNGAN` CHAR(19)
) RETURNS smallint
    DETERMINISTIC
BEGIN
	DECLARE VKELAS SMALLINT;
	
	IF EXISTS(SELECT 1
		  FROM aplikasi.properti_config pc
		 WHERE pc.ID = 8
		   AND VALUE = 'TRUE') THEN				
		IF EXISTS(
				SELECT 1
				  FROM pendaftaran.kunjungan k
				 WHERE k.NOMOR = PKUNJUNGAN
				   AND k.RUANG_KAMAR_TIDUR = 0
					AND NOT k.`STATUS` = 0
		   	) THEN
			SELECT IF(r.JENIS_KUNJUNGAN = 3, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS))
			 		 , IF(rkls.KELAS IS NULL, 0, rkls.KELAS)) KELAS
			  INTO VKELAS
			  FROM pembayaran.tagihan_pendaftaran tp,
			  		 pendaftaran.kunjungan k
			  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
					 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
 					 master.ruangan r
 					 LEFT JOIN master.ruangan_kelas rkls ON rkls.RUANGAN = r.ID AND rkls.`STATUS` = 1
			 WHERE tp.TAGIHAN = PTAGIHAN			   
			   AND tp.STATUS = 1
			   AND k.NOPEN = tp.PENDAFTARAN
				AND k.RUANG_KAMAR_TIDUR > 0
				AND k.REF IS NULL
				AND k.RUANGAN = r.ID
				AND NOT k.`STATUS` = 0
			 LIMIT 1;
				
			IF NOT VKELAS IS NULL THEN
				RETURN VKELAS;
			END IF;
		END IF;
	END IF;
	
	RETURN -1;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDeposit
DROP FUNCTION IF EXISTS `getTotalDeposit`;
DELIMITER //
CREATE FUNCTION `getTotalDeposit`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60, 2);
	
	SELECT SUM(IF(JENIS = 1, TOTAL, 0 - TOTAL)) INTO VTOTAL
	  FROM pembayaran.deposit
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	 
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskon
DROP FUNCTION IF EXISTS `getTotalDiskon`;
DELIMITER //
CREATE FUNCTION `getTotalDiskon`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(ADMINISTRASI+AKOMODASI+SARANA_NON_AKOMODASI+PARAMEDIS) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonAdministrasi
DROP FUNCTION IF EXISTS `getTotalDiskonAdministrasi`;
DELIMITER //
CREATE FUNCTION `getTotalDiskonAdministrasi`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(ADMINISTRASI) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonDokter
DROP FUNCTION IF EXISTS `getTotalDiskonDokter`;
DELIMITER //
CREATE FUNCTION `getTotalDiskonDokter`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.diskon_dokter 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonParamedis
DROP FUNCTION IF EXISTS `getTotalDiskonParamedis`;
DELIMITER //
CREATE FUNCTION `getTotalDiskonParamedis`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(PARAMEDIS) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonSarana
DROP FUNCTION IF EXISTS `getTotalDiskonSarana`;
DELIMITER //
CREATE FUNCTION `getTotalDiskonSarana`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(AKOMODASI+SARANA_NON_AKOMODASI) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalEDC
DROP FUNCTION IF EXISTS `getTotalEDC`;
DELIMITER //
CREATE FUNCTION `getTotalEDC`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.edc 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalPembayaran
DROP FUNCTION IF EXISTS `getTotalPembayaran`;
DELIMITER //
CREATE FUNCTION `getTotalPembayaran`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60, 2);
	
	SELECT SUM(TOTAL) INTO VTOTAL
	  FROM pembayaran.pembayaran_tagihan
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	 
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalPengembalianDeposit
DROP FUNCTION IF EXISTS `getTotalPengembalianDeposit`;
DELIMITER //
CREATE FUNCTION `getTotalPengembalianDeposit`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	
	DECLARE VTOTAL DECIMAL(60, 2);
	
	SELECT SUM(TOTAL) INTO VTOTAL
	  FROM pembayaran.pengembalian_deposit
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	 
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalPenjaminTagihan
DROP FUNCTION IF EXISTS `getTotalPenjaminTagihan`;
DELIMITER //
CREATE FUNCTION `getTotalPenjaminTagihan`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.penjamin_tagihan 
	 WHERE TAGIHAN = PTAGIHAN;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalPiutangPasien
DROP FUNCTION IF EXISTS `getTotalPiutangPasien`;
DELIMITER //
CREATE FUNCTION `getTotalPiutangPasien`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.piutang_pasien
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalPiutangPerusahaan
DROP FUNCTION IF EXISTS `getTotalPiutangPerusahaan`;
DELIMITER //
CREATE FUNCTION `getTotalPiutangPerusahaan`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.piutang_perusahaan
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalSubsidiTagihan
DROP FUNCTION IF EXISTS `getTotalSubsidiTagihan`;
DELIMITER //
CREATE FUNCTION `getTotalSubsidiTagihan`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(TOTAL) INTO VTOTAL 
	  FROM pembayaran.subsidi_tagihan
	 WHERE TAGIHAN = PTAGIHAN;
	
	RETURN IFNULL(VTOTAL, 0);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
