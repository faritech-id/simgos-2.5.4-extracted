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

-- Membuang data untuk tabel inacbg.list_procedure: 78 rows
/*!40000 ALTER TABLE `list_procedure` DISABLE KEYS */;
REPLACE INTO `list_procedure` (`ID`, `JENIS`, `PROC`, `CMG`, `GROUP_CODE`) VALUES
	(148, 2, '87.41', 'II01', 'sinvestigation'),
	(149, 2, '88.01', 'II01', 'sinvestigation'),
	(150, 2, '88.38', 'II01', 'sinvestigation'),
	(151, 2, '92.05', 'II02', 'sinvestigation'),
	(152, 2, '92.15', 'II02', 'sinvestigation'),
	(153, 2, '88.92', 'II03', 'sinvestigation'),
	(154, 2, '88.93', 'II03', 'sinvestigation'),
	(155, 2, '88.97', 'II03', 'sinvestigation'),
	(156, 2, '95.12', 'II04', 'sinvestigation'),
	(157, 1, '02.93', 'RR01', 'sprosthesis'),
	(158, 1, '35.81', 'RR02', 'sprosthesis'),
	(159, 1, '76.5', 'RR03', 'sprosthesis'),
	(160, 1, '39.74', 'RR04', 'sprosthesis'),
	(161, 1, '81.51', 'RR05', 'sprosthesis'),
	(162, 1, '81.52', 'RR05', 'sprosthesis'),
	(163, 1, '81.53', 'RR05', 'sprosthesis'),
	(164, 1, '81.54', 'RR05', 'sprosthesis'),
	(165, 1, '81.55', 'RR05', 'sprocedure'),
	(166, 1, '07.13', 'YY01', 'sprocedure'),
	(167, 1, '07.14', 'YY01', 'sprocedure'),
	(168, 1, '07.15', 'YY01', 'sprocedure'),
	(169, 1, '07.17', 'YY01', 'sprocedure'),
	(170, 1, '81.51', 'YY02', 'sprocedure'),
	(171, 1, '81.52', 'YY02', 'sprocedure'),
	(172, 1, '81.53', 'YY02', 'sprocedure'),
	(173, 1, '81.54', 'YY02', 'sprocedure'),
	(174, 1, '81.55', 'YY02', 'sprocedure'),
	(175, 1, '36.06', 'YY03', 'sprocedure'),
	(176, 1, '36.07', 'YY03', 'sprocedure'),
	(177, 1, '36.09', 'YY03', 'sprocedure'),
	(178, 1, '11.60', 'YY04', 'sprocedure'),
	(179, 1, '11.61', 'YY04', 'sprocedure'),
	(180, 1, '11.62', 'YY04', 'sprocedure'),
	(181, 1, '11.63', 'YY04', 'sprocedure'),
	(182, 1, '11.64', 'YY04', 'sprocedure'),
	(183, 1, '11.69', 'YY04', 'sprocedure'),
	(184, 1, '52.51', 'YY05', 'sprocedure'),
	(185, 1, '52.52', 'YY05', 'sprocedure'),
	(186, 1, '52.53', 'YY05', 'sprocedure'),
	(187, 1, '52.69', 'YY05', 'sprocedure'),
	(188, 1, '52.60', 'YY05', 'sprocedure'),
	(189, 1, '35.50', 'YY06', 'sprocedure'),
	(190, 1, '35.51', 'YY06', 'sprocedure'),
	(191, 1, '35.52', 'YY06', 'sprocedure'),
	(192, 1, '35.53', 'YY06', 'sprocedure'),
	(193, 1, '35.55', 'YY06', 'sprocedure'),
	(194, 1, '92.21', 'YY07', 'sprocedure'),
	(195, 1, '92.22', 'YY07', 'sprocedure'),
	(196, 1, '92.23', 'YY07', 'sprocedure'),
	(197, 1, '92.24', 'YY07', 'sprocedure'),
	(198, 1, '92.25', 'YY07', 'sprocedure'),
	(199, 1, '92.26', 'YY07', 'sprocedure'),
	(200, 1, '92.27', 'YY07', 'sprocedure'),
	(201, 1, '92.28', 'YY07', 'sprocedure'),
	(202, 1, '92.29', 'YY07', 'sprocedure'),
	(203, 1, '92.30', 'YY07', 'sprocedure'),
	(204, 1, '92.31', 'YY07', 'sprocedure'),
	(205, 1, '92.32', 'YY07', 'sprocedure'),
	(206, 1, '92.33', 'YY07', 'sprocedure'),
	(207, 1, '92.39', 'YY07', 'sprocedure'),
	(208, 1, '34.02', 'YY08', 'sprocedure'),
	(209, 1, '34.03', 'YY08', 'sprocedure'),
	(210, 1, '32.41', 'YY09', 'sprocedure'),
	(211, 1, '32.49', 'YY09', 'sprocedure'),
	(212, 1, '33.32', 'YY10', 'sprocedure'),
	(213, 1, '07.80', 'YY11', 'sprocedure'),
	(214, 1, '07.81', 'YY11', 'sprocedure'),
	(215, 1, '07.82', 'YY11', 'sprocedure'),
	(216, 1, '14.73', 'YY12', 'sprocedure'),
	(217, 2, '13.41', 'YY13', 'sprocedure'),
	(218, 2, '31.41', 'YY14', 'sprocedure'),
	(219, 2, '31.42', 'YY14', 'sprocedure'),
	(220, 2, '31.44', 'YY14', 'sprocedure'),
	(221, 2, '51.10', 'YY15', 'sprocedure'),
	(222, 2, '51.11', 'YY15', 'sprocedure'),
	(223, 2, '51.14', 'YY15', 'sprocedure'),
	(224, 2, '51.15', 'YY15', 'sprocedure'),
	(225, 2, '52.13', 'YY15', 'sprocedure');
/*!40000 ALTER TABLE `list_procedure` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
