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

-- Dumping structure for procedure medicalrecord.listDiagnosaFarmasi
DROP PROCEDURE IF EXISTS `listDiagnosaFarmasi`;
DELIMITER //
CREATE PROCEDURE `listDiagnosaFarmasi`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT lf.ID, ib.NAMA 
	FROM layanan.farmasi lf
		  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
		, pendaftaran.kunjungan pk
	     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
	     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
		  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
		  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
		  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
	   , pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		, inventory.barang ib
		
	WHERE  lf.`STATUS` IN (2,3) AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
		AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
		AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG!=1
		AND LEFT(ib.KATEGORI,3)='101';
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
