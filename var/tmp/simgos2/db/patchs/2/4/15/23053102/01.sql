-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.listHasilLabDetil
DROP PROCEDURE IF EXISTS `listHasilLabDetil`;
DELIMITER //
CREATE PROCEDURE `listHasilLabDetil`(
	IN `PKUNJUNGANLAB` VARCHAR(19)
)
BEGIN
	SELECT pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, po.NOMOR KUNJUNGAN_LAB, po.MASUK, hs.ID IDHASIL, t.NAMA NAMATINDAKAN
	     , ptl.PARAMETER, hs.TINDAKAN_MEDIS, hs.PARAMETER_TINDAKAN, hs.TANGGAL TGLHASILLAB, hs.HASIL, 
		  IFNULL(hs.NILAI_NORMAL, ptl.NILAI_RUJUKAN) NILAI_NORMAL
		  , IFNULL(hs.SATUAN, sl.DESKRIPSI) SATUAN
	 FROM pendaftaran.kunjungan pk
	    , layanan.order_lab od
	    , pendaftaran.kunjungan po
	    , layanan.tindakan_medis tm
	      LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
	    , layanan.hasil_lab hs
	      LEFT JOIN master.parameter_tindakan_lab ptl ON hs.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
	      LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
	 WHERE pk.`STATUS`!=0 AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0
	   AND od.NOMOR=po.REF AND po.`STATUS`!=0
	   AND po.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
	   AND tm.ID=hs.TINDAKAN_MEDIS
	   AND po.NOMOR=PKUNJUNGANLAB;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
