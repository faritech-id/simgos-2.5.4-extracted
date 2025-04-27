USE `master`;

-- Dumping structure for function master.getDPJP
DROP FUNCTION IF EXISTS `getDPJP`;
DELIMITER //
CREATE FUNCTION `getDPJP`(
	`PNOPEN` CHAR(10),
	`PJENIS` TINYINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT IF(PJENIS=1, d.NIP, `master`.getNamaLengkapPegawai(d.NIP)) INTO HASIL 
		FROM pendaftaran.kunjungan k 
			, master.dokter d 
			, `master`.ruangan r
			, pendaftaran.tujuan_pasien tp
			, `master`.ruangan rg
		WHERE k.NOPEN=PNOPEN AND k.DPJP!=0 AND k.DPJP=d.ID AND k.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=IF(rg.JENIS_KUNJUNGAN=3,3,IF(rg.JENIS_KUNJUNGAN=2,2,1))
		AND d.`STATUS`!=0 AND k.NOPEN=tp.NOPEN AND tp.`STATUS`!=0 AND tp.RUANGAN=rg.ID AND rg.JENIS_KUNJUNGAN IN (1,2,3)
		ORDER BY k.MASUK  DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;