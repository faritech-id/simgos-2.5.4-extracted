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

-- membuang struktur untuk procedure laporan.SensusHarianRuangan
DROP PROCEDURE IF EXISTS `SensusHarianRuangan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `SensusHarianRuangan`(
	IN `RUANGAN` CHAR(10)
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
    
  SET @sqlText = CONCAT('
			SELECT INST.NAMAINST, INST.ALAMATINST, master.getHeaderLaporan(r.ID) INSTALASI, r.DESKRIPSI RUANG, CONCAT(WILAYAH,'', '',DATE_FORMAT(NOW(),''%d %M %Y'')) TGLSKRG
				FROM master.ruangan r,
					  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST, w.DESKRIPSI WILAYAH
							FROM aplikasi.instansi ai
								, master.ppk p
								, master.wilayah w
							WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
				WHERE r.ID=''',RUANGAN,''' AND r.JENIS=5 AND r.JENIS_KUNJUNGAN=3
		
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
