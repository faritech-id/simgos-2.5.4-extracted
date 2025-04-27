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

-- Membuang data untuk tabel master.jenis_laporan: 23 rows
/*!40000 ALTER TABLE `jenis_laporan` DISABLE KEYS */;
REPLACE INTO `jenis_laporan` (`ID`, `DESKRIPSI`, `NAMA_KLAS`, `MODULE`, `LEVEL`) VALUES
	('1001', 'Kementrian Kesehatan', '', '', 2),
	('1002', 'Dinas Kesehatan', '', '', 2),
	('100101', 'RL 1', '', '', 3),
	('11', 'Pengunjung', 'workspace-laporan-pengunjung', '1402', 1),
	('12', 'Kunjungan', 'workspace-laporan-kunjungan', '1403', 1),
	('13', 'Layanan', 'workspace-laporan-layanan', '1404', 1),
	('14', 'Penerimaan Kasir', 'workspace-laporan-penerimaan-kasir', '1405', 1),
	('15', 'Jasa Pelayanan', 'workspace-laporan-jasapelayanan', '1406', 1),
	('18', 'Pendapatan', 'workspace-laporan-pendapatan', '1409', 1),
	('17', 'Rekam Medis', 'workspace-laporan-rekammedis', '1408', 1),
	('16', 'Inventory', 'workspace-laporan-inventory', '1407', 1),
	('10', 'RL', 'workspace-laporan-rl', '1401', 1),
	('19', 'Kegiatan RI dan RD', 'workspace-laporan-kegiatanrird', '1410', 1),
	('20', 'Monitoring Pelayanan', 'workspace-monitoring-pelayanan', '1411', 1),
	('100102', 'RL 2', '', '', 3),
	('100103', 'RL 3', '', '', 3),
	('100104', 'RL 4', '', '', 3),
	('100105', 'RL 5', '', '', 3),
	('100201', 'RL 1', '', '', 3),
	('100202', 'RL 2', '', '', 3),
	('100203', 'RL 3', '', '', 1),
	('100204', 'RL 4', '', '', 1),
	('100205', 'RL 5', '', '', 1);
/*!40000 ALTER TABLE `jenis_laporan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
