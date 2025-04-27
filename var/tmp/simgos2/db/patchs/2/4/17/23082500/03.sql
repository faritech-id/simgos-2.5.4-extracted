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

-- Dumping structure for procedure laporan.LaporanPermintaanBarangInternal
DROP PROCEDURE IF EXISTS `LaporanPermintaanBarangInternal`;
DELIMITER //
CREATE PROCEDURE `LaporanPermintaanBarangInternal`(
	IN `TGLAWAL` DATE,
	IN `TGLAKHIR` DATE,
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
							p.NOMOR, 
							p.OLEH,
							p.ASAL, 
							p.TUJUAN, 
							ra.DESKRIPSI AS RUANGAN_ASAL, 
							rt.DESKRIPSI AS RUANGAN_TUJUAN, 
							p.TANGGAL,
							pd.JUMLAH JUMLAH_PENGIRIMAN,
							pr_d.BARANG, 
							pr_d.JUMLAH JUMLAH_PERMINTAAN,
							br.NAMA, brk.NAMA BARANG_KIRIM,
							inventory.getHargaPenerimaanTerakhir(br.ID) HPT, (inventory.getHargaPenerimaanTerakhir(br.ID)* (pr_d.JUMLAH)) HRG_TOT,
							usr.NAMA AS PETUGAS,
							inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST,
							master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI,
							master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
							IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
					FROM inventory.permintaan p
							LEFT JOIN inventory.permintaan_detil pr_d ON pr_d.PERMINTAAN = p.NOMOR
							LEFT JOIN inventory.pengiriman_detil pd ON pd.PERMINTAAN_BARANG_DETIL = pr_d.ID AND pd.`STATUS` = 2
							LEFT JOIN inventory.barang br ON br.ID = pr_d.BARANG
							LEFT JOIN inventory.barang brk ON brk.ID = pd.BARANG
							LEFT JOIN inventory.kategori ik ON br.KATEGORI=ik.ID
							LEFT JOIN master.ruangan ra ON ra.ID = p.ASAL
							LEFT JOIN master.ruangan rt ON rt.ID = p.TUJUAN
							LEFT JOIN aplikasi.pengguna usr ON usr.ID = p.OLEH
							, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
								FROM aplikasi.instansi ai
									, master.ppk mp
								WHERE ai.PPK=mp.ID) inst
						WHERE p.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  ',IF(RUANGAN=0,'',CONCAT(' AND p.TUJUAN LIKE ''',vRUANGAN,'''')),'
						   ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
							',IF(BARANG=0,'',CONCAT(' AND br.ID=',BARANG)),'
						ORDER BY p.ASAL, p.TUJUAN, p.TANGGAL, br.NAMA
				
		
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
