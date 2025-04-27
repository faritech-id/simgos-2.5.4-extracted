-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.MonitoringKegiatanPelayanan
DROP PROCEDURE IF EXISTS `MonitoringKegiatanPelayanan`;
DELIMITER //
CREATE PROCEDURE `MonitoringKegiatanPelayanan`(
	IN `PSTATUS` INT,
	IN `PRUANGAN` CHAR(50),
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME
)
BEGIN
DECLARE VRUANGAN,VSTATUS VARCHAR(11);
DECLARE RUANGANX INT;
SET VRUANGAN = CONCAT(PRUANGAN,'%');
SET VSTATUS = CONCAT(PSTATUS,'%');
IF(PRUANGAN != '') THEN
	SET RUANGANX = 0;
ELSE
	SET RUANGANX = PRUANGAN;
END IF;
	SET @sqlText = CONCAT('
	SELECT datax.*, pj.NOMOR SEP FROM (
		SELECT 
				p.NOMOR NOPEN, p.NORM, p.TANGGAL, k.NOMOR KUNJUNGAN, k.MASUK, psn.NAMA, orders.NOMOR
			, IF(tpa.NOPEN IS NOT NULL , ''Pendaftaran'',ru2.DESKRIPSI) RUASAL
			, IF(tpa.NOPEN IS NOT NULL , tpa.RUANGAN,orders.TUJUAN) TUJUAN
			, IF(tpa.NOPEN IS NOT NULL , ruA.DESKRIPSI,ru.DESKRIPSI) RUTUJUAN
			, IF(tpa.NOPEN IS NOT NULL , ''Kunjungan Awal'',orders.JENIS) JENIS
			, IF(tpa.NOPEN IS NOT NULL , tpa.RUANGAN,orders.TUJUAN) TUJUANLYN
			, IF(tpa.NOPEN IS NOT NULL , p.TANGGAL,orders.TANGGAL) TGLLYN
			, IF(tpa.NOPEN IS NOT NULL, tpa.`STATUS` ,orders.STATUS) STATUSLYN
			
			, IF (orders.JENIS=''Kunjungan Layanan'',
				IF(orders.STATUS=1,''Belum Final Layanan'',IF(orders.STATUS=2,''Sudah Final Layanan'',''-''))
				, IF(orders.STATUS=1,CONCAT(''Belum Terima '',orders.JENIS),IF(orders.STATUS=2,CONCAT(''Sudah Terima '',orders.JENIS)
					, IF(tpa.NOPEN IS NOT NULL,''Belum Terima Kunjungan'',''-'')))
			) STATUSLAYANAN
			, IF(',RUANGANX,'=0,''Semua Ruangan'', IF(tpa.NOPEN IS NOT NULL, ruA.DESKRIPSI, ru.DESKRIPSI)) RUANGANTUJUAN
			, IF(',RUANGANX,'=0,''Semua Ruangan'',IF(tpa.NOPEN IS NOT NULL, ''Pendaftaran'', ru2.DESKRIPSI)) RUANGANASAL
		FROM pendaftaran.pendaftaran p
		LEFT JOIN pendaftaran.tujuan_pasien tpa ON tpa.NOPEN = p.NOMOR AND tpa.STATUS = 1
		LEFT JOIN master.ruangan ruA ON ruA.ID = tpa.RUANGAN
		LEFT JOIN pendaftaran.kunjungan k ON k.NOPEN = p.NOMOR
		LEFT JOIN
		(
			(SELECT res.NOMOR, res.KUNJUNGAN, res.TUJUAN, CONCAT(''Order Resep'') JENIS, res.TANGGAL, res.STATUS FROM layanan.order_resep res WHERE res.STATUS != 0)
			UNION ALL
			(SELECT lab.NOMOR, lab.KUNJUNGAN, lab.TUJUAN, CONCAT(''Order Laboratorium'') JENIS, lab.TANGGAL, lab.STATUS FROM layanan.order_lab lab WHERE lab.STATUS != 0)
			UNION ALL
			(SELECT rad.NOMOR, rad.KUNJUNGAN, rad.TUJUAN, CONCAT(''Order Radiologi'') JENIS, rad.TANGGAL, rad.STATUS FROM layanan.order_rad rad WHERE rad.STATUS != 0)
			UNION ALL
			(SELECT kon.NOMOR, kon.KUNJUNGAN, kon.TUJUAN, CONCAT(''Order Konsul'') JENIS, kon.TANGGAL, kon.STATUS FROM pendaftaran.konsul kon WHERE kon.STATUS != 0)
			UNION ALL
			(SELECT mut.NOMOR, mut.KUNJUNGAN, mut.TUJUAN, CONCAT(''Order Radiologi'') JENIS, mut.TANGGAL, mut.STATUS FROM pendaftaran.mutasi mut WHERE mut.STATUS != 0)
			UNION ALL
			(SELECT kun.NOMOR, kun.NOMOR KUNJUNGAN, kun.RUANGAN TUJUAN, CONCAT(''Kunjungan Layanan'') JENIS, kun.MASUK TANGGAL, kun.STATUS FROM pendaftaran.kunjungan kun WHERE kun.STATUS != 0)
		) orders ON orders.KUNJUNGAN = k.NOMOR
		LEFT JOIN master.ruangan ru ON ru.ID = orders.TUJUAN
		LEFT JOIN master.ruangan ru2 ON ru2.ID = k.RUANGAN
		LEFT JOIN master.pasien psn ON psn.NORM = p.NORM
		WHERE p.STATUS !=0 AND p.NOMOR IS NOT NULL
	) datax 
	LEFT JOIN pendaftaran.penjamin pj ON datax.NOPEN=pj.NOPEN AND pj.JENIS
	WHERE datax.TGLLYN BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND datax.TUJUANLYN LIKE ''',VRUANGAN,''' AND datax.STATUSLYN LIKE ''',VSTATUS,'''
');
PREPARE stmt FROM @sqlText;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
