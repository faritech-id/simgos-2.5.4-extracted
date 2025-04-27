USE `inventory`;
DROP FUNCTION IF EXISTS `isValidasiRetriksiPelayananResep`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `isValidasiRetriksiPelayananResep`(`PKUNJUNGAN` CHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE VTGLFINALKUNJUNGAN DATE;
	DECLARE VNORM INT;
	DECLARE VPASIENPLNG SMALLINT;
	
	SET VTGLFINALKUNJUNGAN = DATE(NOW());
	
	IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 43 AND p.VALUE = 'TRUE') THEN
		SELECT IF(kj.KELUAR IS NULL,NOW(),kj.KELUAR), pnd.NORM, ords.RESEP_PASIEN_PULANG INTO VTGLFINALKUNJUNGAN, VNORM, VPASIENPLNG
		FROM pendaftaran.kunjungan kj, layanan.order_resep ords, pendaftaran.pendaftaran pnd
		WHERE pnd.NOMOR = kj.NOPEN AND ords.NOMOR = kj.REF AND kj.NOMOR = PKUNJUNGAN
		LIMIT 1;
		
		IF VPASIENPLNG > 0 THEN
			IF NOT EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 81 AND p.VALUE = 'TRUE') THEN
				IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 84 AND p.VALUE = 'TRUE') THEN
					IF EXISTS(
							SELECT 
							1
							FROM pendaftaran.kunjungan k
							LEFT JOIN master.ruangan r ON r.ID = k.RUANGAN
							, pendaftaran.pendaftaran p, layanan.batas_layanan_obat bts
							LEFT JOIN inventory.barang br ON br.ID = bts.FARMASI
							LEFT JOIN layanan.farmasi f ON f.ID = bts.REF
							LEFT JOIN pendaftaran.kunjungan kf ON kf.NOMOR = f.KUNJUNGAN
							LEFT JOIN master.ruangan r2 ON r2.ID = kf.RUANGAN
							LEFT JOIN layanan.order_resep res ON res.NOMOR = kf.REF
							LEFT JOIN pendaftaran.kunjungan kh ON kh.NOMOR = res.KUNJUNGAN
							LEFT JOIN master.ruangan r3 ON r3.ID = kh.RUANGAN
							WHERE bts.NORM = p.NORM AND bts.STATUS = 1 AND bts.TANGGAL > VTGLFINALKUNJUNGAN  AND p.NOMOR = k.NOPEN AND k.NOMOR = PKUNJUNGAN
							AND r3.JENIS_KUNJUNGAN = r.JENIS_KUNJUNGAN AND (f.ALASAN_TIDAK_TERLAYANI IS NULL OR f.ALASAN_TIDAK_TERLAYANI = '')
						) THEN
						RETURN 1;
					END IF;
				ELSE
					IF EXISTS(
						SELECT 1 FROM layanan.farmasi f, layanan.batas_layanan_obat bts
						WHERE bts.FARMASI = f.FARMASI AND bts.`STATUS` = 1 AND bts.NORM = VNORM AND bts.TANGGAL > VTGLFINALKUNJUNGAN AND f.KUNJUNGAN = PKUNJUNGAN AND (f.ALASAN_TIDAK_TERLAYANI IS NULL OR f.ALASAN_TIDAK_TERLAYANI = '')) THEN
						RETURN 1;
					END IF;
				END IF;
			END IF;
		ELSE
			IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 84 AND p.VALUE = 'TRUE') THEN
				IF EXISTS(
						SELECT 
						1
						FROM pendaftaran.kunjungan k
						LEFT JOIN master.ruangan r ON r.ID = k.RUANGAN
						, pendaftaran.pendaftaran p, layanan.batas_layanan_obat bts
						LEFT JOIN inventory.barang br ON br.ID = bts.FARMASI
						LEFT JOIN layanan.farmasi f ON f.ID = bts.REF
						LEFT JOIN pendaftaran.kunjungan kf ON kf.NOMOR = f.KUNJUNGAN
						LEFT JOIN master.ruangan r2 ON r2.ID = kf.RUANGAN
						LEFT JOIN layanan.order_resep res ON res.NOMOR = kf.REF
						LEFT JOIN pendaftaran.kunjungan kh ON kh.NOMOR = res.KUNJUNGAN
						LEFT JOIN master.ruangan r3 ON r3.ID = kh.RUANGAN
						WHERE bts.NORM = p.NORM AND bts.STATUS = 1 AND bts.TANGGAL > VTGLFINALKUNJUNGAN  AND p.NOMOR = k.NOPEN AND k.NOMOR = PKUNJUNGAN
						AND r3.JENIS_KUNJUNGAN = r.JENIS_KUNJUNGAN AND (f.ALASAN_TIDAK_TERLAYANI IS NULL OR f.ALASAN_TIDAK_TERLAYANI = '')
					) THEN
					RETURN 1;
				END IF;
			ELSE
				IF EXISTS(
					SELECT 1 FROM layanan.farmasi f, layanan.batas_layanan_obat bts
					WHERE bts.FARMASI = f.FARMASI AND bts.`STATUS` = 1 AND bts.NORM = VNORM AND bts.TANGGAL > VTGLFINALKUNJUNGAN AND f.KUNJUNGAN = PKUNJUNGAN AND (f.ALASAN_TIDAK_TERLAYANI IS NULL OR f.ALASAN_TIDAK_TERLAYANI = '')) THEN
					RETURN 1;
				END IF;
			END IF;
		END IF;
		
	END IF;
	
	RETURN 0;
	
END//
DELIMITER ;