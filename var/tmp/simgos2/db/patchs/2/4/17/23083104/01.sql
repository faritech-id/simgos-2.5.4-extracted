-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.34 - MySQL Community Server - GPL
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


-- Dumping database structure for laporan
USE `laporan`;

-- Dumping structure for procedure laporan.LaporanRekapKoreksiPerAlasan
DROP PROCEDURE IF EXISTS `LaporanRekapKoreksiPerAlasan`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapKoreksiPerAlasan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT
)
BEGIN

	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   
	SET @sqlText = CONCAT('
		SELECT 
		CONCAT(''REKAP LAPORAN TRANSAKSI KOREKSI PER ALASAN'') JENISLAPORAN, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, IF(t.JENIS=1,''Masuk'',''Keluar'') JENIS, t.TANGGAL, t.KET, IF(t.JENIS = 1, ra1.DESKRIPSI, ra2.DESKRIPSI) NMALASAN, b.NAMA NMBARANG, SUM(d.JUMLAH) JUMLAH
		,inventory.getHargaPenerimaanTerakhir(b.ID) HPT, (inventory.getHargaPenerimaanTerakhir(b.ID)* (SUM(d.JUMLAH))) HRG_TOT
		FROM inventory.transaksi_koreksi t
		LEFT JOIN master.ruangan rg ON t.RUANGAN=rg.ID AND rg.JENIS=5
		LEFT JOIN master.referensi ra1 ON t.ALASAN = ra1.ID AND ra1.JENIS = 900601
		LEFT JOIN master.referensi ra2 ON t.ALASAN = ra2.ID AND ra2.JENIS = 900602
		, inventory.transaksi_koreksi_detil d
		, inventory.barang b
		LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
		WHERE b.ID = d.BARANG AND d.KOREKSI = t.ID AND t.`STATUS` = 2
		AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		',IF(RUANGAN='0','',CONCAT(' AND t.RUANGAN LIKE ''',vRUANGAN,'''')),'
		',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
		',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
		GROUP BY t.JENIS, t.ALASAN, b.ID
		ORDER BY t.JENIS,t.ALASAN, b.NAMA
	');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
