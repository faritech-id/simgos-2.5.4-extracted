-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
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

-- membuang struktur untuk procedure medicalrecord.getResumeTindakanMedis
DROP PROCEDURE IF EXISTS `getResumeTindakanMedis`;
DELIMITER //
CREATE PROCEDURE `getResumeTindakanMedis`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT tm.ID, t.NAMA, tm.RESUMEMEDIS
	 FROM pembayaran.rincian_tagihan rt
	  , pembayaran.tagihan_pendaftaran tp
	  , layanan.tindakan_medis tm
	  , master.tindakan t
	  , pendaftaran.kunjungan pk
	  , master.ruangan r
	 WHERE rt.JENIS=3 AND rt.`STATUS`!=0 AND rt.TAGIHAN=tp.TAGIHAN AND tp.UTAMA=1 AND tp.`STATUS`!=0
	  AND tp.PENDAFTARAN=PNOPEN
	  AND rt.REF_ID=tm.ID AND tm.`STATUS`!=0
	  AND tm.TINDAKAN=t.ID AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
	  AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN!=4
	GROUP BY t.ID
	ORDER BY t.NAMA;
END//
DELIMITER ;

-- membuang struktur untuk procedure medicalrecord.listDiagnosaFarmasi
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
		, pembayaran.rincian_tagihan rt
	WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
		AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
		AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG!=1
		AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101';
END//
DELIMITER ;

-- membuang struktur untuk procedure medicalrecord.listHasilLab
DROP PROCEDURE IF EXISTS `listHasilLab`;
DELIMITER //
CREATE PROCEDURE `listHasilLab`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	 SELECT pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, rasal.DESKRIPSI RUANGASAL, po.NOMOR KUNJUNGAN_LAB, rp.DESKRIPSI RUANGPENUNJANG, po.MASUK TGL
		FROM pembayaran.rincian_tagihan rt
			, pembayaran.tagihan_pendaftaran tp
			, layanan.tindakan_medis tm
			, layanan.hasil_lab hs
			, pendaftaran.kunjungan po
		     LEFT JOIN master.ruangan rp ON po.RUANGAN=rp.ID
		   , pendaftaran.kunjungan pk
		     LEFT JOIN master.ruangan rasal ON pk.RUANGAN=rasal.ID
		   , layanan.order_lab od
		WHERE rt.JENIS=3 AND rt.`STATUS`!=0
		  AND rt.TAGIHAN=tp.TAGIHAN AND tp.UTAMA=1 AND tp.`STATUS`!=0
		  AND tp.PENDAFTARAN=PNOPEN 
		  AND rt.REF_ID=tm.ID AND tm.`STATUS`!=0
		  AND tm.ID=hs.TINDAKAN_MEDIS
		  AND po.NOMOR=tm.KUNJUNGAN
		  AND od.NOMOR=po.REF AND po.`STATUS`!=0
		  AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0 AND pk.`STATUS`!=0
		GROUP BY po.NOMOR
		ORDER BY po.MASUK DESC;
END//
DELIMITER ;

-- membuang struktur untuk procedure medicalrecord.listHasilLabDetil
DROP PROCEDURE IF EXISTS `listHasilLabDetil`;
DELIMITER //
CREATE PROCEDURE `listHasilLabDetil`(
	IN `PKUNJUNGANLAB` VARCHAR(19)
)
BEGIN
	SELECT pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, po.NOMOR KUNJUNGAN_LAB, po.MASUK, hs.ID IDHASIL, t.NAMA NAMATINDAKAN
	     , ptl.PARAMETER, hs.TINDAKAN_MEDIS, hs.PARAMETER_TINDAKAN, hs.TANGGAL TGLHASILLAB, hs.HASIL, hs.NILAI_NORMAL, hs.SATUAN
	 FROM pendaftaran.kunjungan pk
	    , layanan.order_lab od
	    , pendaftaran.kunjungan po
	    , layanan.tindakan_medis tm
	      LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
	    , layanan.hasil_lab hs
	      LEFT JOIN master.parameter_tindakan_lab ptl ON hs.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
	 WHERE pk.`STATUS`!=0 AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0
	   AND od.NOMOR=po.REF AND po.`STATUS`!=0
	   AND po.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
	   AND tm.ID=hs.TINDAKAN_MEDIS
	   AND po.NOMOR=PKUNJUNGANLAB;

END//
DELIMITER ;

-- membuang struktur untuk procedure medicalrecord.listHasilRad
DROP PROCEDURE IF EXISTS `listHasilRad`;
DELIMITER //
CREATE PROCEDURE `listHasilRad`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, rasal.DESKRIPSI RUANGASAL, po.NOMOR KUNJUNGAN_RAD, rp.DESKRIPSI RUANGPENUNJANG, po.MASUK TGL
	FROM pembayaran.rincian_tagihan rt
		, pembayaran.tagihan_pendaftaran tp
		, layanan.tindakan_medis tm
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
	GROUP BY po.NOMOR
	ORDER BY po.MASUK DESC;
END//
DELIMITER ;

-- membuang struktur untuk procedure medicalrecord.listHasilRadDetil
DROP PROCEDURE IF EXISTS `listHasilRadDetil`;
DELIMITER //
CREATE PROCEDURE `listHasilRadDetil`(
	IN `PKUNJUNGANRAD` VARCHAR(19)
)
BEGIN
	SELECT hs.ID, pk.NOPEN, pk.NOMOR KUNJUNGAN_ASAL, po.NOMOR KUNJUNGAN_RAD, po.MASUK, hs.TINDAKAN_MEDIS IDHASIL, hs.TANGGAL TGLHASILRAD, t.NAMA NAMATINDAKAN
	     , hs.KLINIS, hs.KESAN, hs.USUL, hs.HASIL
	 FROM pendaftaran.kunjungan pk
	    , layanan.order_rad od
	    , pendaftaran.kunjungan po
	    , layanan.tindakan_medis tm
	      LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
	    , layanan.hasil_rad hs
	 WHERE pk.`STATUS`!=0 AND pk.NOMOR=od.KUNJUNGAN AND od.`STATUS`!=0
	   AND od.NOMOR=po.REF AND po.`STATUS`!=0
	   AND po.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
	   AND tm.ID=hs.TINDAKAN_MEDIS
	   AND po.NOMOR=PKUNJUNGANRAD;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
