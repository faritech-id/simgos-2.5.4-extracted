INSERT INTO pembayaran.pembayaran_tagihan(
	NOMOR, tagihan, JENIS, JENIS_LAYANAN_ID, 
	TANGGAL, NO_ID, NAMA, REF, 
	JENIS_KARTU_ID, BANK_ID,
	TOTAL, OLEH, `STATUS`
)
SELECT generator.generateNoPembayaran(e.TANGGAL), 
		 e.TAGIHAN, 2, 2, 
		 e.TANGGAL, e.NOMOR, e.PEMILIK, e.APRV_CODE, 
		 e.JENIS_KARTU, e.BANK,
		 e.TOTAL, e.OLEH, 2
  FROM pembayaran.edc e
 WHERE e.`STATUS` = 1
   AND NOT EXISTS(
 	SELECT 1 
	  FROM pembayaran.pembayaran_tagihan pt
	 WHERE pt.TAGIHAN = e.TAGIHAN
	   AND pt.JENIS_LAYANAN_ID = 2
	   AND pt.BANK_ID = e.BANK
	   AND pt.JENIS_KARTU_ID = e.JENIS_KARTU
	   AND pt.NO_ID = e.NOMOR
	   AND pt.REF = e.APRV_CODE
	   AND pt.TOTAL = e.TOTAL
	   AND pt.TANGGAL = e.TANGGAL
 );