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

-- membuang struktur untuk procedure informasi.infoRuangKamarTidur
DROP PROCEDURE IF EXISTS `infoRuangKamarTidur`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `infoRuangKamarTidur`(
	IN `PRUANGAN` LONGTEXT
)
BEGIN
	
	SET @sqlText = CONCAT('SELECT rkt.ID, rk.ID KAMAR_ID, rkls.DESKRIPSI KAMAR
	, SUM(IF(rkt.STATUS_ID=1,1,0)) KOSONG, SUM(IF(rkt.STATUS_ID=1,0,1)) TERISI
	, (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) TOTAL
	, ROUND((SUM(IF(rkt.STATUS_ID=1,1,0)) / (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) * 100),0) PERC_KOSONG
	, ROUND((SUM(IF(rkt.STATUS_ID=1,0,1)) / (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) * 100),0) PERC_TERISI
	,rs.DESKRIPSI STATUS
		  FROM (
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 1	 
		UNION	
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.STATUS = 1
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 2
		UNION		 
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 3
	) rkt
	LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR AND rk.RUANGAN IN (',PRUANGAN,')
	LEFT JOIN master.referensi rkls ON rk.KELAS = rkls.ID AND rkls.JENIS = 19
	LEFT JOIN master.ruangan rgn On rgn.ID = rk.RUANGAN
	LEFT JOIN master.referensi rs ON rs.JENIS = 20 AND rs.ID = rkt.STATUS_ID 
	WHERE NOT rkt.STATUS_ID IN (0)
	  AND rgn.STATUS = 1 AND rkls.ID IS NOT NULL
	GROUP BY rk.KELAS
	ORDER BY rkls.DESKRIPSI ASC');
	
	
	 PREPARE stmt FROM @sqlText;
	 EXECUTE stmt;
	 DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
