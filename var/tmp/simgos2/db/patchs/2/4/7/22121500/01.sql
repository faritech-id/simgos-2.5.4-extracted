-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
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


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakMR17
DROP PROCEDURE IF EXISTS `CetakMR17`;
DELIMITER //
CREATE PROCEDURE `CetakMR17`(
	IN `PNORM` INT(11)
)
BEGIN 	
	SELECT *
		FROM (SELECT PNORM ID, mp.NAMA NAMAINSTANSI, ai.PPK, CONCAT(mp.ALAMAT,', Kode Pos ', IFNULL(mp.KODEPOS,' '),', Telp. ', IFNULL(mp.TELEPON,' '),', Fax. ',IF(mp.FAX IS NULL OR mp.FAX='','',mp.FAX)) ALAMATINSTANSI, IFNULL(w.DESKRIPSI, mp.DESWILAYAH) KOTA, DATE_FORMAT(SYSDATE(),'%d') TGL, `master`.getBulanIndo(SYSDATE()) BULAN, DATE_FORMAT(SYSDATE(),'%Y') TAHUN
						FROM aplikasi.instansi ai
							, master.ppk mp
							  LEFT JOIN master.wilayah w ON mp.WILAYAH=w.ID AND w.JENIS=2
						WHERE ai.PPK=mp.ID) inst
				LEFT JOIN ( SELECT p.NORM, `master`.getFormatNorm(p.NORM, '-') FORMAT_NORM , `master`.getNamaLengkap(p.NORM) NAMA
							 		, IF(p.JENIS_KELAMIN=1,1,0) LAKI, IF(p.JENIS_KELAMIN=2,1,0) PEREMPUAN
									, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TTL
							 		, p.ALAMAT
								FROM master.pasien p
								WHERE p.NORM=PNORM) ab ON ab.NORM=inst.ID;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
