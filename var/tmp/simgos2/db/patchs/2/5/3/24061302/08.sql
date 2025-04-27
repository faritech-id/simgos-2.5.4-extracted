USE `master`;

-- Dumping structure for function master.getJenisKunjunganSebelumnya
DROP FUNCTION IF EXISTS `getJenisKunjunganSebelumnya`;
DELIMITER //
CREATE FUNCTION `getJenisKunjunganSebelumnya`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TINYINT;
   
   SELECT r.JENIS_KUNJUNGAN INTO HASIL 
    FROM pendaftaran.pendaftaran pd
      , pendaftaran.tujuan_pasien tp
      , master.ruangan r
      , pendaftaran.kunjungan k
    WHERE pd.NORM=PNORM AND pd.TANGGAL < PTANGGAL
	 AND pd.STATUS!=0 AND pd.NOMOR=tp.NOPEN
      AND tp.RUANGAN=r.ID 
      AND pd.NOMOR=k.NOPEN AND k.REF IS NULL AND k.STATUS!=0
   ORDER BY pd.TANGGAL DESC
   LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;