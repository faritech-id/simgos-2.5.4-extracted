-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.30 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk view pembayaran.kasir
DROP VIEW IF EXISTS `kasir`;
-- Menghapus tabel sementara dan menciptakan struktur VIEW terakhir
CREATE ALGORITHM=TEMPTABLE DEFINER=`root`@`127.0.0.1` SQL SECURITY DEFINER VIEW `kasir` AS select distinct `p`.`ID` AS `ID`,`p`.`NAMA` AS `NAMA`,`p`.`NIP` AS `NIP` from ((((`aplikasi`.`pengguna` `p` join `aplikasi`.`pengguna_akses` `pa`) join `aplikasi`.`group_pengguna_akses_module` `gpam`) join `master`.`referensi` `r`) join `aplikasi`.`modules` `m`) where ((`pa`.`PENGGUNA` = `p`.`ID`) and (`gpam`.`ID` = `pa`.`GROUP_PENGGUNA_AKSES_MODULE`) and (`r`.`JENIS` = 43) and (`r`.`ID` = `gpam`.`GROUP_PENGGUNA`) and (`m`.`ID` = `gpam`.`MODUL`) and (`m`.`ID` in ('2102','1201')));

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
