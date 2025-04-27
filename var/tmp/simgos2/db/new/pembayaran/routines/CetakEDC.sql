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

-- membuang struktur untuk procedure pembayaran.CetakEDC
DROP PROCEDURE IF EXISTS `CetakEDC`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakEDC`(IN `PTAGIHAN` CHAR(10), IN `PBANK` TINYINT, IN `PJENIS` TINYINT, IN `PNOMOR` CHAR(25))
BEGIN
		 SELECT dp.TAGIHAN, bnk.DESKRIPSI NAMABANK, nkartu.DESKRIPSI NAMAKERTU, dp.NOMOR NOMORKARTU ,dp.TOTAL, dp.PEMILIK, dp.APRV_CODE, dp.TANGGAL TGLEDC,
		 		 INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
				 master.getNamaLengkap(p.NORM) NAMALENGKAP,
				 inst.NAMA NAMAINSTANSI,
				 CONCAT(pembayaran.getInfoTagihanKunjungan(t.ID),' ',inst.NAMA) KET,
				 mp.NIP,
				 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
		 FROM pembayaran.tagihan t
			  	LEFT JOIN `master`.pasien p ON p.NORM = t.REF,
			  	pembayaran.edc dp
			  	LEFT JOIN aplikasi.pengguna us ON us.ID = dp.OLEH
				LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
				LEFT JOIN master.referensi bnk ON dp.BANK=bnk.ID AND bnk.JENIS=16
				LEFT JOIN master.referensi nkartu ON dp.JENIS_KARTU=nkartu.ID AND nkartu.JENIS=17,
			  (SELECT mp.NAMA 
			 	 FROM aplikasi.instansi ai
					, master.ppk mp
				 WHERE ai.PPK=mp.ID) inst
		 WHERE dp.TAGIHAN=PTAGIHAN AND dp.BANK=PBANK AND dp.JENIS_KARTU=PJENIS AND dp.NOMOR=PNOMOR
		 	AND dp.TAGIHAN=t.ID AND dp.`STATUS`=1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
