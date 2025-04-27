UPDATE pendaftaran.penjamin p,
  		 bpjs.kunjungan k,
  		 bpjs.peserta ps
  	SET p.JENIS_PESERTA = ps.kdJenisPeserta
 WHERE p.JENIS = 2
   AND k.noSEP = p.NOMOR
   AND ps.noKartu = k.noKartu;