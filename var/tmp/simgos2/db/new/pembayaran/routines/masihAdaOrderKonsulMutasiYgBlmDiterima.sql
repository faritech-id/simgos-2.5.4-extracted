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

-- membuang struktur untuk procedure pembayaran.masihAdaOrderKonsulMutasiYgBlmDiterima
DROP PROCEDURE IF EXISTS `masihAdaOrderKonsulMutasiYgBlmDiterima`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `masihAdaOrderKonsulMutasiYgBlmDiterima`(IN `PTAGIHAN` CHAR(10))
BEGIN
	SELECT CONCAT(r1.DESKRIPSI, ' melakukan',
		IF(r.JENIS_KUNJUNGAN = 3, ' Mutasi ', 
			IF(r.JENIS_KUNJUNGAN = 1, ' Konsul ', ' Order ')
		), 'ke ', r.DESKRIPSI) DESKRIPSI
	  FROM (
	SELECT k.RUANGAN,
			 IF(NOT ks.KUNJUNGAN IS NULL, ks.TUJUAN,
			 	IF(NOT mt.KUNJUNGAN IS NULL, mt.TUJUAN,
				 	IF(NOT olab.KUNJUNGAN IS NULL, olab.TUJUAN,
					 	IF(NOT orad.KUNJUNGAN IS NULL, orad.TUJUAN, 
						 	IF(NOT orep.KUNJUNGAN IS NULL, orep.TUJUAN, NULL)
						)
					)
				)
			 ) TUJUAN,
			 k.MASUK
	  FROM pembayaran.tagihan t,
	  		 pembayaran.tagihan_pendaftaran tp,
	  		 pendaftaran.kunjungan k
			 LEFT JOIN pendaftaran.konsul ks ON ks.KUNJUNGAN = k.NOMOR AND ks.`STATUS` = 1
			 LEFT JOIN pendaftaran.mutasi mt ON mt.KUNJUNGAN = k.NOMOR AND mt.`STATUS` = 1
			 LEFT JOIN layanan.order_lab olab ON olab.KUNJUNGAN = k.NOMOR AND olab.`STATUS` = 1
			 LEFT JOIN layanan.order_rad orad ON orad.KUNJUNGAN = k.NOMOR AND orad.`STATUS` = 1
			 LEFT JOIN layanan.order_resep orep ON orep.KUNJUNGAN = k.NOMOR AND orep.`STATUS` = 1,
	  		 master.ruangan r
	 WHERE t.ID = PTAGIHAN
	 	AND t.`STATUS` = 1
	   AND tp.TAGIHAN = t.ID
	   AND k.NOPEN = tp.PENDAFTARAN
	   AND r.ID = k.RUANGAN
	   AND k.`STATUS` = 2
	 ) k LEFT JOIN master.ruangan r1 ON r1.ID = k.RUANGAN
	 	  LEFT JOIN master.ruangan r ON r.ID = k.TUJUAN
	 WHERE NOT k.TUJUAN IS NULL
	 ORDER BY k.MASUK;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
