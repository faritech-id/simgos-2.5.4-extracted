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

-- membuang struktur untuk procedure inventory.CetakPurchaseOrder
DROP PROCEDURE IF EXISTS `CetakPurchaseOrder`;
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `CetakPurchaseOrder`(IN `PNOPO` VARCHAR(50))
BEGIN
	SELECT po.NO_PO,po.NO_MR,po.SUPPLIER,po.TANGGAL,po.OLEH, pod.JUMLAH AS JML, br.NAMA , s.NAMA AS SATUAN,sphd.HARGA, sphd.DISKON_PERSEN, sphd.DISKON_RUPIAH,(pod.JUMLAH * sphd.HARGA) AS JmlHrg, ((pod.JUMLAH * sphd.HARGA) - sphd.DISKON_RUPIAH) AS TotalHrg, p.NAMA AS NAMA_SUPPLIER,p.ALAMAT,p.TELEPON, p.FAX, usr.NAMA, usr.NIP
	FROM inventory.purchase_order po
		LEFT JOIN inventory.purchase_order_detil pod ON pod.ID_PO = po.NO_PO AND pod.STATUS = 1
		LEFT JOIN inventory.material_request_detil mrd ON mrd.ID = pod.ID_MR_DETIL
		LEFT JOIN inventory.surat_penawaran_harga_detil sphd ON sphd.ID = mrd.ID_SPH
		LEFT JOIN inventory.penyedia p ON p.ID = po.SUPPLIER
		LEFT JOIN inventory.barang_ruangan bru ON bru.ID = pod.BARANG
		LEFT JOIN inventory.barang br ON br.ID = bru.BARANG
		LEFT JOIN inventory.satuan s ON s.ID = br.SATUAN
		LEFT JOIN aplikasi.pengguna usr ON usr.ID = po.OLEH
	WHERE po.NO_PO = PNOPO;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
