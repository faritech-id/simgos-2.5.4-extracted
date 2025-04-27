UPDATE `master`.dokter_smf ds, `master`.dokter d, `master`.pegawai p
   SET ds.`STATUS` = 1
 WHERE ds.`STATUS` = 0
   AND d.ID = ds.DOKTER
   AND d.STATUS = 1
	AND p.NIP = d.NIP
	AND p.SMF = ds.SMF
	AND p.PROFESI = 4
	AND p.`STATUS` = 1;