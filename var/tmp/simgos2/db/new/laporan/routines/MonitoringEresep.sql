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

-- membuang struktur untuk procedure laporan.MonitoringEresep
DROP PROCEDURE IF EXISTS `MonitoringEresep`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `MonitoringEresep`(
	IN `PSTATUS` INT,
	IN `RUANGAN` CHAR(10)



,
	IN `TGLAKHIR` DATETIME


,
	IN `TGLAWAL` DATETIME
)
BEGIN
DECLARE VRUANGAN,VSTATUS VARCHAR(11);   
SET VRUANGAN = CONCAT(RUANGAN,'%');
SET VSTATUS = CONCAT(PSTATUS,'%');
SELECT 
	kun.NOPEN, pas.NORM, pas.NAMA, res.NOMOR NORESEP, res.TANGGAL, ru2.DESKRIPSI ASAL, ru.DESKRIPSI TUJUAN, kun.NOMOR KUNJUNGAN, kun.MASUK
	, IF(res.STATUS=1,'Belum Di Diterima',IF(res.STATUS=2,'Sudah Di Terima',IF(res.STATUS=3,'Sudah Terlayani','Batal'))) STATUSLAYANAN
	, IF(RUANGAN='','Semua Ruangan',ru.DESKRIPSI) FILTERRUANGAN
	, IF(RUANGAN='','Semua Ruangan',ru2.DESKRIPSI) FILTERRUANGANASAL
FROM layanan.order_resep res
LEFT JOIN master.ruangan ru ON ru.ID = res.TUJUAN
LEFT JOIN pendaftaran.kunjungan kun ON kun.NOMOR = res.KUNJUNGAN
LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = kun.NOPEN
LEFT JOIN master.pasien pas ON pas.NORM = pen.NORM
LEFT JOIN master.ruangan ru2 ON ru2.ID = kun.RUANGAN
WHERE res.STATUS LIKE VSTATUS AND res.TUJUAN LIKE VRUANGAN AND res.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
