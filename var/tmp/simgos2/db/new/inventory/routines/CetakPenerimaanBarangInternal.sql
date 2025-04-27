-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure inventory.CetakPenerimaanBarangInternal
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
