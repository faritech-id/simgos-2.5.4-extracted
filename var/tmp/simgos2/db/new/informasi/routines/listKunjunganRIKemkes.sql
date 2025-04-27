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

-- membuang struktur untuk procedure informasi.listKunjunganRIKemkes
DROP PROCEDURE IF EXISTS `listKunjunganRIKemkes`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `listKunjunganRIKemkes`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE

)
BEGIN
		DECLARE vTanggalAwal DATETIME;
	   DECLARE vTanggalAkhir DATETIME;
	      
	   SET vTanggalAwal = CONCAT(PTGL_AWAL,' 00:00:00');
	   SET vTanggalAkhir = CONCAT(PTGL_AKHIR,' 23:59:59');
   
		SET @sqlText = CONCAT('
			SELECT kls.DESKRIPSI CONTENT, COUNT(1) JLH
			  FROM pendaftaran.kunjungan k,
			  		 master.ruangan r,
			  		 master.ruang_kamar_tidur rkt,
			  		 master.ruang_kamar rk,
			  		 master.referensi kls
			 WHERE k.`STATUS` IN (1, 2)
			   AND k.REF IS NULL
			   AND k.MASUK BETWEEN ''',vTanggalAwal,''' AND ''',vTanggalAkhir,'''
			 	AND r.ID = k.RUANGAN
			   AND r.JENIS_KUNJUNGAN = 3
			   AND rkt.ID = k.RUANG_KAMAR_TIDUR
			   AND rk.ID = rkt.RUANG_KAMAR
			   AND kls.JENIS = 19
			   AND kls.ID = rk.KELAS
			 GROUP BY kls.ID');
			 
	 	
		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
