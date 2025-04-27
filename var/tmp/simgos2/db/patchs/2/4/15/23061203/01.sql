USE `inventory`;
DROP FUNCTION IF EXISTS `adaItemObatYangTervalidasiStok`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `adaItemObatYangTervalidasiStok`(`PKUNJUNGAN` CHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
	
	IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 66 AND p.VALUE = 'TRUE') THEN	
		IF EXISTS(SELECT 1 FROM (
			SELECT (SELECT inventory.getStokBarangRuangan(f.FARMASI, k.RUANGAN) - (f.JUMLAH - f.BON)) SELISIH
			FROM pendaftaran.kunjungan k, layanan.farmasi f
			where f.KUNJUNGAN = k.NOMOR AND (f.ALASAN_TIDAK_TERLAYANI IS NOT NULL OR f.ALASAN_TIDAK_TERLAYANI !='') AND k.NOMOR = PKUNJUNGAN
		) record WHERE record.SELISIH < 0) THEN
			RETURN 1;
		END IF;
	END IF;
	
	RETURN 0;
	
END//
DELIMITER ;