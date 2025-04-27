/* use invetory */
USE inventory;

DROP PROCEDURE IF EXISTS `CetakPenerimaanBarangInternal`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakPenerimaanBarangInternal`(
	IN `PNOMOR` VARCHAR(50)
)
BEGIN
	SELECT p.NOMOR, p.OLEH,p.ASAL, p.TUJUAN, ra.DESKRIPSI AS RUANGAN_ASAL, rt.DESKRIPSI AS RUANGAN_TUJUAN, p.TANGGAL,p.PERMINTAAN,pd.PERMINTAAN_BARANG_DETIL,pd.JUMLAH,pr_d.BARANG, br.NAMA, usr.NAMA AS PETUGAS, inst.DESKRIPSI_WILAYAH
	FROM inventory.pengiriman p
		LEFT JOIN inventory.pengiriman_detil pd ON pd.PENGIRIMAN = p.NOMOR
		LEFT JOIN inventory.permintaan_detil pr_d ON pr_d.ID = pd.PERMINTAAN_BARANG_DETIL
		LEFT JOIN inventory.barang br ON br.ID = pr_d.BARANG
		LEFT JOIN master.ruangan ra ON ra.ID = p.ASAL
		LEFT JOIN master.ruangan rt ON rt.ID = p.TUJUAN
		LEFT JOIN aplikasi.pengguna usr ON usr.ID = p.OLEH
	,(
		SELECT mp.NAMA, wil.DESKRIPSI DESKRIPSI_WILAYAH
		FROM aplikasi.instansi ai
			, master.ppk mp
		LEFT JOIN master.wilayah wil ON mp.WILAYAH = wil.ID
		WHERE ai.PPK=mp.ID
	) inst
	WHERE p.NOMOR=PNOMOR;
END//
DELIMITER ;