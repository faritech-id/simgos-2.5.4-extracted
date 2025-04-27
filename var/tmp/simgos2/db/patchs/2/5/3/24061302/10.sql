USE `master`;

-- Dumping structure for function master.getKsmSubspesialis
DROP FUNCTION IF EXISTS `getKsmSubspesialis`;
DELIMITER //
CREATE FUNCTION `getKsmSubspesialis`(
	`PNIP` VARCHAR(30)
) RETURNS varchar(150) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(150);
  
   SELECT CONCAT(UPPER(bp.NMPOLI),' ; ',UPPER(smf.DESKRIPSI)) INTO HASIL
		FROM 
		  master.dokter_smf mds
			LEFT JOIN master.dokter md ON mds.DOKTER=md.ID
			LEFT JOIN master.referensi smf ON mds.SMF=smf.ID AND smf.JENIS=26
		, master.penjamin_sub_spesialistik psb
		, regonline.poli_bpjs  bp						
			WHERE psb.SUB_SPESIALIS_PENJAMIN= bp.KDSUBSPESIALIS
			AND psb.SUB_SPESIALIS_RS=mds.SMF
			AND mds.`STATUS`=1 AND md.`STATUS`=1
			AND psb.`STATUS`=1
			AND md.NIP = PNIP
			LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;