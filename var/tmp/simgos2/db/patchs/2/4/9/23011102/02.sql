-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.listHasilRad
DROP PROCEDURE IF EXISTS `listHasilRad`;
DELIMITER //
CREATE PROCEDURE `listHasilRad`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, rasal.DESKRIPSI RUANGASAL, po.NOMOR KUNJUNGAN_RAD, rp.DESKRIPSI RUANGPENUNJANG, po.MASUK TGL
	, hs.ID, t.NAMA NAMATINDAKAN, hs.KLINIS, hs.KESAN, hs.USUL, hs.HASIL
	FROM pembayaran.rincian_tagihan rt
		, pembayaran.tagihan_pendaftaran tp
		, layanan.tindakan_medis tm
		LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		, layanan.hasil_rad hs
		, pendaftaran.kunjungan po
	      LEFT JOIN master.ruangan rp ON po.RUANGAN=rp.ID
	   , pendaftaran.kunjungan pk
	      LEFT JOIN master.ruangan rasal ON pk.RUANGAN=rasal.ID
	    , layanan.order_rad od
	WHERE rt.JENIS=3 AND rt.`STATUS`!=0
	  AND rt.TAGIHAN=tp.TAGIHAN AND tp.UTAMA=1 AND tp.`STATUS`!=0
	  AND tp.PENDAFTARAN=PNOPEN 
	  AND rt.REF_ID=tm.ID AND tm.`STATUS`!=0
	  AND tm.ID=hs.TINDAKAN_MEDIS
	  AND po.NOMOR=tm.KUNJUNGAN
	  AND od.NOMOR=po.REF AND po.`STATUS`!=0
	  AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0 AND pk.`STATUS`!=0
#	GROUP BY po.NOMOR
	ORDER BY po.MASUK DESC;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
