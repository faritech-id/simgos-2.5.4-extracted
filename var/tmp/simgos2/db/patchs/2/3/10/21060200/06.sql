USE pembayaran;

DROP PROCEDURE IF EXISTS `getTotalPiutangPerorangan`;
DELIMITER //
CREATE PROCEDURE `getTotalPiutangPerorangan`(
	IN `PNORM` INT
)
BEGIN
   DECLARE VTOTAL DECIMAL(10, 2);
   
   SELECT
		IF(bpp.TOTAL IS NULL, 0, SUM(bpp.TOTAL)) INTO VTOTAL
	FROM pembayaran.piutang_pasien bpp
	LEFT JOIN pembayaran.tagihan bt ON bt.ID = bpp.TAGIHAN
	WHERE bt.REF = PNORM 
	AND bt.JENIS = 1 
	AND bt.`STATUS` = 2
	AND bpp.`STATUS` = 1;
   
	SELECT
		PNORM NORM, 
		VTOTAL TOTAL,
		@totalbyr:= IF(bppp.TOTAL_BAYAR IS NULL, 0, SUM(bppp.TOTAL_BAYAR)) TOTAL_BAYAR,
		@sisa := VTOTAL - @totalbyr  SISA_BAYAR,
		IF(@sisa > 0, @sisa ,0) SISA_HARUS_BAYAR
	FROM pembayaran.piutang_pasien bpp
	LEFT JOIN pembayaran.pelunasan_piutang_pasien bppp ON bppp.TAGIHAN_PIUTANG = bpp.TAGIHAN AND bppp.`STATUS` = 2
	LEFT JOIN pembayaran.tagihan bt ON bt.ID = bpp.TAGIHAN
	WHERE bt.REF = PNORM 
	AND bt.JENIS = 1 
	AND bt.`STATUS` = 2
	AND bpp.`STATUS` = 1;
END//
DELIMITER ;
