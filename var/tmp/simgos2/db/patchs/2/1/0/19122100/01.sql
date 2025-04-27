
/* use db inventory */
USE inventory;

DROP PROCEDURE IF EXISTS `CetakBuktiPermintaanBarangInternal`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakBuktiPermintaanBarangInternal`(
	IN `PNOMOR` VARCHAR(50)
)
BEGIN
	SELECT p.NOMOR, p.OLEH,p.ASAL, p.TUJUAN, ra.DESKRIPSI AS RUANGAN_ASAL, rt.DESKRIPSI AS RUANGAN_TUJUAN, p.TANGGAL,pd.JUMLAH,pd.BARANG, br.NAMA, usr.NAMA AS PETUGAS, inst.DESKRIPSI_WILAYAH
	FROM inventory.permintaan p
		LEFT JOIN inventory.permintaan_detil pd ON pd.PERMINTAAN = p.NOMOR
		LEFT JOIN inventory.barang br ON br.ID = pd.BARANG
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