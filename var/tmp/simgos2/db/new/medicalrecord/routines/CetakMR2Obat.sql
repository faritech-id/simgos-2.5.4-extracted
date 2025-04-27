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

-- membuang struktur untuk procedure medicalrecord.CetakMR2Obat
DROP PROCEDURE IF EXISTS `CetakMR2Obat`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakMR2Obat`(IN `PNOPEN` CHAR(10))
BEGIN
	SELECT  pk.NOPEN, ib.NAMA NAMAOBAT, lf.JUMLAH, IF(ref.DESKRIPSI IS NULL, lf.ATURAN_PAKAI, ref.DESKRIPSI) ATURANPAKAI
		, lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
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
		WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
			AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG=1
			AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'
		ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
