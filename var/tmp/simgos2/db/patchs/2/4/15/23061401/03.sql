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

-- Dumping structure for procedure medicalrecord.listHasilRad
DROP PROCEDURE IF EXISTS `listHasilRad`;
DELIMITER //
CREATE PROCEDURE `listHasilRad`(
	IN `PNOPEN` CHAR(10)
)
BEGIN

	 DECLARE VNORM INT(11);
	 DECLARE VTANGGAL DATETIME;
	 DECLARE VNOPEN CHAR(10);
	 
	 SELECT NORM, TANGGAL INTO VNORM, VTANGGAL FROM pendaftaran.pendaftaran WHERE NOMOR=PNOPEN;
	 
	 
	 SELECT `master`.getNopenIRD(VNORM,VTANGGAL) INTO VNOPEN;
	 
	IF (VNOPEN IS NULL) THEN
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
	
		ORDER BY po.MASUK DESC;
ELSE
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
		UNION 
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
		  AND tp.PENDAFTARAN=VNOPEN 
		  AND rt.REF_ID=tm.ID AND tm.`STATUS`!=0
		  AND tm.ID=hs.TINDAKAN_MEDIS
		  AND po.NOMOR=tm.KUNJUNGAN
		  AND od.NOMOR=po.REF AND po.`STATUS`!=0
		  AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0 AND pk.`STATUS`!=0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
