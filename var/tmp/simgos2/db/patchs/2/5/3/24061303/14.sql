USE `layanan`;

-- Dumping structure for procedure layanan.CetakResep
DROP PROCEDURE IF EXISTS `CetakResep`;
DELIMITER //
CREATE PROCEDURE `CetakResep`(IN `PNOMOR` CHAR(21))
BEGIN
	

	SELECT *
		FROM layanan.order_resep o
			, pendaftaran.kunjungan pk
		     LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID
			, layanan.order_detil_resep od
			, inventory.barang ib
		WHERE o.NOMOR=od.ORDER_ID AND o.`STATUS`=2
			AND od.FARMASI=ib.ID AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND o.NOMOR=PNOMOR
	;
END//
DELIMITER ;