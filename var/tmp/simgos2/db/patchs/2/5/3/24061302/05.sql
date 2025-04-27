USE `master`;

-- Dumping structure for function master.getDokterTindakan
DROP FUNCTION IF EXISTS `getDokterTindakan`;
DELIMITER //
CREATE FUNCTION `getDokterTindakan`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(DOKTER SEPARATOR ';'),';',' ; ')  
	  INTO HASIL
	  FROM (
		SELECT DISTINCT(CONCAT('- ',master.getNamaLengkapPegawai(md.NIP))) DOKTER, md.ID
		  FROM master.dokter md,
			    layanan.petugas_tindakan_medis ptm,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k,
			    master.ruangan r 
		 WHERE md.ID = ptm.MEDIS 
		   AND ptm.JENIS IN (1,2) 
			AND ptm.`STATUS` = 1 
			AND ptm.TINDAKAN_MEDIS = tm.ID 
			AND tm.`STATUS` = 1
		   AND tm.KUNJUNGAN = k.NOMOR 
			AND k.`STATUS` != 0 
			AND k.RUANGAN = r.ID 
			AND r.JENIS = 5 
			AND r.JENIS_KUNJUNGAN NOT IN (0,4,5,11,13,14)
		   AND NOT EXISTS (SELECT 1 FROM layanan.pasien_pulang pp WHERE pp.NOPEN = k.NOPEN AND pp.DOKTER = ptm.MEDIS AND pp.`STATUS` != 0 LIMIT 1)
		   AND k.NOPEN = PNOPEN
     ) a
   ORDER BY DOKTER;

	RETURN HASIL;
END//
DELIMITER ;