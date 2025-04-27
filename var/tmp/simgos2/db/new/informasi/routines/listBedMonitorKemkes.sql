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

-- membuang struktur untuk procedure informasi.listBedMonitorKemkes
DROP PROCEDURE IF EXISTS `listBedMonitorKemkes`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `listBedMonitorKemkes`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN

	DECLARE vTanggalAwal DATETIME;
	DECLARE vTanggalAkhir DATETIME;
	      
   SET vTanggalAwal = CONCAT(PTGL_AWAL,' 00:00:00');
   SET vTanggalAkhir = CONCAT(PTGL_AKHIR,' 23:59:59');
   
	SELECT mkls.ID kode_ruang, mtp.ID tipe_pasien
		  , SUM(ttk.TTLAKI)+SUM(ttk.TTPEREMPUAN) total_TT
		  , SUM(IF(ttk.JMLLAKI>=ttk.JMLPEREMPUAN,JMLLAKI+JMLPEREMPUAN,0)) terpakai_male
		  , SUM(IF(ttk.JMLLAKI<ttk.JMLPEREMPUAN, JMLLAKI+JMLPEREMPUAN,0)) terpakai_female
		  , IF(SUM(ttk.TTLAKI) - SUM(IF(ttk.JMLLAKI>=ttk.JMLPEREMPUAN,JMLLAKI+JMLPEREMPUAN,0)) < 0, 0 , SUM(ttk.TTLAKI) - SUM(IF(ttk.JMLLAKI>=ttk.JMLPEREMPUAN,JMLLAKI+JMLPEREMPUAN,0))) kosong_male
		  , IF(SUM(ttk.TTPEREMPUAN) - SUM(IF(ttk.JMLLAKI<ttk.JMLPEREMPUAN, JMLLAKI+JMLPEREMPUAN,0)) < 0, 0, SUM(ttk.TTPEREMPUAN) - SUM(IF(ttk.JMLLAKI<ttk.JMLPEREMPUAN, JMLLAKI+JMLPEREMPUAN,0))) kosong_female
		  , 0 waiting
		  , ttk.LASTUPDATED tgl_update
	FROM informasi.tempat_tidur_kemkes ttk
		, master.ruangan_simrs_kemkes ttrl
		, master.kelas_simrs_kemkes mkr
		, master.kemkes_kelas mkls
		, master.kemkes_ruangan mtp
	WHERE ttk.IDSUBUNIT=ttrl.RUANGAN
	  AND ttk.IDKELAS=mkr.KELAS AND mkr.KEMKES_KELAS=mkls.ID
	  AND ttrl.KEMKES_RUANGAN=mtp.ID AND ttk.LASTUPDATED BETWEEN vTanggalAwal AND vTanggalAkhir
	GROUP BY mtp.ID, mkls.ID;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
