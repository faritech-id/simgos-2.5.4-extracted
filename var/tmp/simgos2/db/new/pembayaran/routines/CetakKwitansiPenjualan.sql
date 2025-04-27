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

-- membuang struktur untuk procedure pembayaran.CetakKwitansiPenjualan
DROP PROCEDURE IF EXISTS `CetakKwitansiPenjualan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakKwitansiPenjualan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
	SELECT t.ID, t.TANGGAL, t.TOTAL,
			 pt.TANGGAL TANGGALBAYAR,
			 pp.PENGUNJUNG NAMALENGKAP,
			 inst.NAMA NAMAINSTANSI, inst.PPK IDPPK, inst.ALAMAT,
			 pp.KETERANGAN KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, 
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 ROUND(t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalEDC(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))), 0) TAGIHAN
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 8 AND pt.`STATUS` = 1
	  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP,
			 penjualan.penjualan pp,
			 (SELECT mp.NAMA,mp.ALAMAT, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	 WHERE t.ID = PTAGIHAN AND t.ID = pp.NOMOR
	   AND t.JENIS = PJENIS
	   AND t.`STATUS` = 2;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
