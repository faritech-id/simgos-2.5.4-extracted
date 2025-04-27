UPDATE pendaftaran.tujuan_pasien tp,
  		 `master`.dokter d,
  		 `master`.pegawai p
  	SET tp.SMF = p.SMF
 WHERE tp.SMF = 0
   AND d.ID = tp.DOKTER
   AND p.NIP = d.NIP;