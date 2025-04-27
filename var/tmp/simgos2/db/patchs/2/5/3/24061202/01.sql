
DROP FUNCTION IF EXISTS `inventory`.`getGolonganPerBarang`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `inventory`.`getGolonganPerBarang`(
	`PID_BARANG` SMALLINT(6)
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TEXT;
   
	SELECT REPLACE(GROUP_CONCAT(gol.DESKRIPSI SEPARATOR ';'),';','\r') INTO HASIL
	FROM inventory.penggolongan_barang pb
	     LEFT JOIN `master`.referensi gol ON pb.PENGGOLONGAN=gol.ID AND gol.JENIS=149
		, inventory.barang br
	WHERE pb.BARANG=br.ID AND br.ID=PID_BARANG
	GROUP BY br.ID;
 
  RETURN HASIL;
END;
//
DROP FUNCTION IF EXISTS `inventory`.`getKeteranganTransaksi`;
//
CREATE DEFINER=`root`@`localhost` FUNCTION `inventory`.`getKeteranganTransaksi`(`PJENIS` INT, `PREF` INT) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VDESC, VDESKRIPSI VARCHAR(250);
	
	SET VDESC = "-";
	IF PJENIS = 23 THEN 
		SELECT CONCAT("Tujuan : ",r.DESKRIPSI) INTO VDESKRIPSI
		FROM inventory.pengiriman_detil p, inventory.pengiriman pn, master.ruangan r
		WHERE r.ID = pn.TUJUAN and pn.NOMOR = p.PENGIRIMAN and p.ID=PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 20 THEN 
		SELECT CONCAT("Asal : ",r.DESKRIPSI) INTO VDESKRIPSI
		FROM inventory.pengiriman_detil p, inventory.pengiriman pn, master.ruangan r
		WHERE r.ID = pn.ASAL and pn.NOMOR = p.PENGIRIMAN and p.ID=PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 53 THEN 
		SELECT CONCAT("Alasan : ", r.DESKRIPSI) INTO VDESKRIPSI
		FROM inventory.transaksi_koreksi t
		LEFT JOIN master.referensi r ON r.ID = t.ALASAN AND r.JENIS = 900601
		, inventory.transaksi_koreksi_detil d
		WHERE d.KOREKSI = t.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 54 THEN 
		SELECT CONCAT("Alasan : ", r.DESKRIPSI) INTO VDESKRIPSI
		FROM inventory.transaksi_koreksi t
		LEFT JOIN master.referensi r ON r.ID = t.ALASAN AND r.JENIS = 900602
		, inventory.transaksi_koreksi_detil d
		WHERE d.KOREKSI = t.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 21 THEN 
		SELECT CONCAT("PBF : ", s.NAMA) INTO VDESKRIPSI
		FROM inventory.penerimaan_barang p
		LEFT JOIN inventory.penyedia s ON s.ID = p.REKANAN
		, inventory.penerimaan_barang_detil d
		WHERE d.PENERIMAAN = p.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 55 THEN 
		SELECT CONCAT("Asal : ", s.NAMA) INTO VDESKRIPSI
		FROM inventory.hibah h
		LEFT JOIN inventory.penyedia s ON s.ID = h.ASAL
		, inventory.hibah_detil d
		WHERE d.HIBAH = h.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 57 THEN 
		SELECT CONCAT("Asal : ", s.NAMA) INTO VDESKRIPSI
		FROM inventory.hibah h
		LEFT JOIN inventory.penyedia s ON s.ID = h.ASAL
		, inventory.hibah_detil d
		WHERE d.HIBAH = h.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;
	END IF;
	
	IF PJENIS = 56 THEN 
		SELECT CONCAT("Tujuan : ", t.NAMA) INTO VDESKRIPSI
		FROM inventory.hibah h
		LEFT JOIN inventory.tujuan_hibah t ON t.ID = h.ASAL
		, inventory.hibah_detil d
		WHERE d.HIBAH = h.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;		
	END IF;
	
	IF PJENIS = 58 THEN 
		SELECT CONCAT("Tujuan : ", t.NAMA) INTO VDESKRIPSI
		FROM inventory.hibah h
		LEFT JOIN inventory.tujuan_hibah t ON t.ID = h.ASAL
		, inventory.hibah_detil d
		WHERE d.HIBAH = h.ID AND d.ID = PREF;
		IF FOUND_ROWS() > 0 THEN
			RETURN VDESKRIPSI;
		END IF;		
	END IF;
	
	RETURN VDESC;
END;
//
DELIMITER ;