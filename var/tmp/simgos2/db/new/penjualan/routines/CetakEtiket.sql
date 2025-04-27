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

-- membuang struktur untuk procedure penjualan.CetakEtiket
DROP PROCEDURE IF EXISTS `CetakEtiket`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakEtiket`(IN `PPENJUALAN` VARCHAR(50))
BEGIN
	SELECT inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
		   , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER, p.PENGUNJUNG, p.TANGGAL,p.NOMOR, br.NAMA NAMAOBAT, pd.JUMLAH, ref.DESKRIPSI 
		   , jp.DESKRIPSI JENISPENGGUNAAN
			FROM penjualan.penjualan p
			     LEFT JOIN penjualan.penjualan_detil pd ON pd.PENJUALAN_ID = p.NOMOR
			     LEFT JOIN inventory.barang br ON br.ID = pd.BARANG
			     LEFT JOIN master.referensi ref ON ref.ID=pd.ATURAN_PAKAI AND ref.JENIS=41
			     LEFT JOIN master.referensi jp ON br.JENIS_PENGGUNAAN_OBAT=jp.ID AND jp.JENIS=55
			     , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
					, (SELECT ap.NAMA, ap.SIPA
							FROM master.apoteker ap
							WHERE ap.`STATUS`=1) apoteker
	WHERE p.NOMOR = PPENJUALAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
