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

-- membuang struktur untuk procedure inventory.CetakMaterialRequest
DROP PROCEDURE IF EXISTS `CetakMaterialRequest`;
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `CetakMaterialRequest`(IN `PNOMR` VARCHAR(50))
BEGIN
	SELECT mr.NO_MR, p.NAMA AS SUPPLIER, mr.RUANGAN, mr.TANGGAL,mrd.BARANG, br.ID, br.NAMA, s.NAMA AS Satuan, mrd.JUMLAH, mrd.SISA_STOK, sphd.HARGA, sphd.DISKON_RUPIAH, sphd.DISKON_PERSEN
	FROM inventory.material_request mr
		LEFT JOIN inventory.material_request_detil mrd ON mrd.NO_MR = mr.NO_MR
		LEFT JOIN inventory.surat_penawaran_harga_detil sphd ON sphd.ID = mrd.ID_SPH
		LEFT JOIN inventory.surat_penawaran_harga sph ON sph.NOMOR = sphd.ID_PENAWARAN
		LEFT JOIN inventory.penyedia p ON p.ID = sph.SUPPLIER
		LEFT JOIN inventory.barang_ruangan bru ON bru.ID = mrd.BARANG
		LEFT JOIN inventory.barang br ON br.ID = bru.BARANG
		LEFT JOIN inventory.satuan s ON s.ID = br.SATUAN
		LEFT JOIN aplikasi.pengguna usr ON usr.ID = mr.OLEH
	WHERE mr.NO_MR = PNOMR;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
