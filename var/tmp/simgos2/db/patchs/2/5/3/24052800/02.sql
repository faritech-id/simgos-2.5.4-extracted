-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `inventory`;

-- Dumping structure for procedure inventory.CetakPenerimaanBarangInternal
DROP PROCEDURE IF EXISTS `CetakPenerimaanBarangInternal`;
DELIMITER //
CREATE PROCEDURE `CetakPenerimaanBarangInternal`(
	IN `PNOMOR` VARCHAR(50)
)
BEGIN
		SELECT p.NOMOR, p.OLEH,p.ASAL, p.TUJUAN, ra.DESKRIPSI AS RUANGAN_ASAL, rt.DESKRIPSI AS RUANGAN_TUJUAN, p.TANGGAL,p.PERMINTAAN,pd.PERMINTAAN_BARANG_DETIL,pd.JUMLAH,pr_d.BARANG, br.NAMA BRG_MINTA, brk.NAMA BARANG_KIRIM
			, usr.NAMA AS PETUGAS,usr_m.NAMA AS USERMEMINTA, usr_t.NAMA AS USERTERIMA, inst.DESKRIPSI_WILAYAH
			, ins.DESKRIPSI INSTALASI_TUJUAN
	FROM inventory.pengiriman p
		LEFT JOIN inventory.pengiriman_detil pd ON pd.PENGIRIMAN = p.NOMOR
		LEFT JOIN inventory.permintaan_detil pr_d ON pr_d.ID = pd.PERMINTAAN_BARANG_DETIL
		LEFT JOIN inventory.permintaan pr ON pr.NOMOR = pr_d.PERMINTAAN
		LEFT JOIN inventory.penerimaan pnr ON pnr.REF = p.NOMOR AND pnr.JENIS=2 AND pnr.`STATUS`=1
		LEFT JOIN inventory.barang br ON br.ID = pr_d.BARANG
		LEFT JOIN inventory.barang brk ON brk.ID = pd.BARANG
		LEFT JOIN master.ruangan ra ON ra.ID = p.ASAL
		LEFT JOIN master.ruangan rt ON rt.ID = p.TUJUAN
		LEFT JOIN aplikasi.pengguna usr ON usr.ID = p.OLEH
		LEFT JOIN aplikasi.pengguna usr_m ON usr_m.ID = pr.OLEH
		LEFT JOIN aplikasi.pengguna usr_t ON usr_t.ID = pnr.OLEH
		LEFT JOIN `master`.ruangan ins ON ins.ID=LEFT (rt.ID,5) AND ins.JENIS=3
	,(
		SELECT mp.NAMA, wil.DESKRIPSI DESKRIPSI_WILAYAH
		FROM aplikasi.instansi ai
			, master.ppk mp
		LEFT JOIN master.wilayah wil ON mp.WILAYAH = wil.ID
		WHERE ai.PPK=mp.ID
	) inst
	WHERE p.NOMOR=PNOMOR;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
