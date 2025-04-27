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

-- Membuang data untuk tabel inventory.jenis_transaksi_stok: ~14 rows (lebih kurang)
/*!40000 ALTER TABLE `jenis_transaksi_stok` DISABLE KEYS */;
REPLACE INTO `jenis_transaksi_stok` (`ID`, `DESKRIPSI`, `TAMBAH_ATAU_KURANG`) VALUES
	(10, 'Stok Opname', ''),
	(11, 'Stok Opname Balance', ''),
	(12, 'Stok Opname', ''),
	(20, 'Penerimaan Barang dari Ruangan', '+'),
	(21, 'Penerimaan Barang dari Rekanan', '+'),
	(22, 'Pengembalian Barang ke Rekanan', '-'),
	(23, 'Pengiriman Barang ke Ruangan', '-'),
	(24, 'Pembatalan Final Penerimaan Barang dari Rekanan', '-'),
	(30, 'Penjualan', '-'),
	(31, 'Retur Penjualan', '+'),
	(32, 'Pembatalan Penjualan', '+'),
	(33, 'Pelayanan', '-'),
	(34, 'Retur Pelayanan', '+'),
	(35, 'Pembatalan Pelayanan', '+');
/*!40000 ALTER TABLE `jenis_transaksi_stok` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
