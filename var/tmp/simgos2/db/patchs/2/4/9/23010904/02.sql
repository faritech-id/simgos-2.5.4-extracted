-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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

-- membuang struktur untuk procedure medicalrecord.CetakMR2Obat
DROP PROCEDURE IF EXISTS `CetakMR2Obat`;
DELIMITER //
CREATE PROCEDURE `CetakMR2Obat`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT  pk.NOPEN, ib.NAMA NAMAOBAT, lf.JUMLAH, f.FREKUENSI, lf.DOSIS
		, lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
		FROM layanan.farmasi lf
			  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
			  LEFT JOIN master.frekuensi_aturan_resep f ON lf.FREKUENSI=f.ID AND f.`STATUS`!=0
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
		WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
			AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG=1
			AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'
		ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
