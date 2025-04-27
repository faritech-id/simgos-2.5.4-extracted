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

-- membuang struktur untuk function lis.createOrderDiKunjungan
DROP FUNCTION IF EXISTS `createOrderDiKunjungan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `createOrderDiKunjungan`(`PKUNJUNGAN` CHAR(25), `PTANGGAL` DATETIME, `PUSER` INT) RETURNS char(25) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE SUCCESS TINYINT DEFAULT TRUE;
	DECLARE VJML_KUNJUNGAN INT;
	DECLARE VKUNJUNGAN CHAR(25);
	DECLARE VPENDAFTARAN INT;
	DECLARE VKELUHAN_MASUK TINYTEXT;
	DECLARE VPASIEN INT;
	DECLARE VPENJAMIN INT;
	DECLARE VTANGGAL DATETIME;	
	DECLARE VNOSEP CHAR(30);
	DECLARE VSTATUS TINYINT;
	DECLARE VRUANGAN_ASAL INT;
	DECLARE VGOLONGAN VARCHAR(10);
	DECLARE VNOKARTU VARCHAR(2);
	DECLARE VNON_CHECKUP INT;
	DECLARE VSMF INT;
	DECLARE VBERAT_BADAN INT;
	DECLARE VPISA CHAR(1);
	DECLARE VBAYI TINYINT;
	DECLARE VTIPE_PERUJUK, VJENIS_PERUJUK VARCHAR(10);
	DECLARE VRS_PERUJUK VARCHAR(500);
	
	SELECT r.noreg, r.norm, r.keluhan_masuk, r.idcarabyr, r.nosjp, r.id_statusreg, idunit, golongan, no_jaminan
			 , non_cekup, smf, beratbadan, pisa, bayi, type_perujuk, jenis_perujuk, rsperujuk
	  INTO VPENDAFTARAN, VPASIEN, VKELUHAN_MASUK, VPENJAMIN, VNOSEP, VSTATUS, VRUANGAN_ASAL, VGOLONGAN, VNOKARTU
	  		 , VNON_CHECKUP, VSMF, VBERAT_BADAN, VPISA, VBAYI, VTIPE_PERUJUK, VJENIS_PERUJUK, VRS_PERUJUK
	  FROM pcc_rsws.register r
	 WHERE r.id_reg_lengkap = PKUNJUNGAN
	 LIMIT 1;

	
	SELECT MAX(SUBSTRING(id_reg_lengkap, 15, 2)) 
	  INTO VJML_KUNJUNGAN
	  FROM pcc_rsws.register 
	 WHERE noreg = VPENDAFTARAN
	   AND idunit = 951001
		AND DATE(tanggal) = DATE(PTANGGAL);

	
	IF VJML_KUNJUNGAN IS NULL THEN
		SET VJML_KUNJUNGAN = 10;
	ELSE
		SET VJML_KUNJUNGAN = VJML_KUNJUNGAN + 1;
	END IF;
	
	SET VKUNJUNGAN = CONCAT(DATE_FORMAT(PTANGGAL, '%Y%m%d'), 951001, VJML_KUNJUNGAN, VPENDAFTARAN);
	
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET SUCCESS = FALSE;
		INSERT INTO pcc_rsws.register(id_reg_lengkap, noreg, idunit, norm, keluhan_masuk, idcarabyr, nosjp, tgl_reg
				 , idoperat, id_statusreg, id_unit_asal, status_layanan, golongan, no_jaminan, status_pengunjung, status_kunjungan
				 , non_cekup, smf, urut_reg, beratbadan, pisa, bayi, dokter_id, type_perujuk, jenis_perujuk, noreg_asal, kirim_rm, terima_rm
				 , petugas_kirim, petugas_terima, rsperujuk, status_cetak, tanggal_reg, cetak_tracert, cetak_barcode_reg
				 , ip, id_reg_lengkapasal, keterangan_batal, cetak_kartu, update_sjp)
		VALUES(VKUNJUNGAN, VPENDAFTARAN, 951001, VPASIEN, VKELUHAN_MASUK, VPENJAMIN, VNOSEP, DATE_FORMAT(PTANGGAL, '%d-%m-%Y %H:%i:%s')
			, PUSER, IF(VSTATUS IN (2,4) , 4, IF(VSTATUS IN (6,7), 7, 3)), VRUANGAN_ASAL, 0, VGOLONGAN, VNOKARTU, 0, 1
			, VNON_CHECKUP, VSMF, 1, VBERAT_BADAN, VPISA, VBAYI, '', VTIPE_PERUJUK, VJENIS_PERUJUK, VPENDAFTARAN, 0, 0
			, 0, 0, VRS_PERUJUK, 0, PTANGGAL, 0, 0, CURRENT_USER(), PKUNJUNGAN, '', 0, 0
		);
	END;
	 
	IF SUCCESS THEN
		RETURN VKUNJUNGAN;
	END IF;
	
	RETURN '';
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
