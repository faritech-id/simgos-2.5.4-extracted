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



USE `laporan`;

-- Dumping structure for procedure laporan.LaporanPenggunaanObatAlkesTerbanyak
DROP PROCEDURE IF EXISTS `LaporanPenggunaanObatAlkesTerbanyak`;

DELIMITER //
CREATE PROCEDURE `LaporanPenggunaanObatAlkesTerbanyak`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT,
	IN `JENISINVENTORY` INT,
	IN `JENISKATEGORI` INT,
	IN `KATEGORIBARANG` INT,
	IN `JENISGENERIK` TINYINT,
	IN `JENISFORMULARIUM` INT,
	IN `PENGGOLONGAN` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
	DECLARE vJENISINVENTORY VARCHAR(11);
	DECLARE vKATEGORIBARANG VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vJENISINVENTORY = CONCAT(JENISINVENTORY,'%');
   SET vKATEGORIBARANG = CONCAT(KATEGORIBARANG,'%');
   SET @sqlText = CONCAT('
	SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, CONCAT(''LAPORAN PENGGUNAAN OBAT / ALKES 100 TERBANYAK'') JENISLAPORAN
		, IFNULL(master.getHeaderKategoriBarang(IF(''',KATEGORIBARANG,'''!=''0'',''',KATEGORIBARANG,''',IF(''',KATEGORI,'''!=''0'',''',KATEGORI,''',''',JENISINVENTORY,'''))),''Semua'') KATEGORI
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI	
		, FARMASI, ab.NAMA NMOBAT,JML_OBAT_RT, LEMBAR
	FROM
		 (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
						WHERE ai.PPK=mp.ID) inst
		, (SELECT 
				f.FARMASI, CONCAT( b.NAMA,'' | '', IFNULL(invent.NAMA,''-''), '' | '',IFNULL(ref.DESKRIPSI, ''-''),'' | '',IFNULL(k.NAMA,''-'')) NAMA
				, SUM(f.JUMLAH) JUMLAH_OBAT, SUM(rt.JUMLAH) JML_OBAT_RT
				, COUNT(DISTINCT(f.ID)) LEMBAR
			FROM 
				layanan.farmasi f 
				LEFT JOIN pembayaran.rincian_tagihan rt ON f.ID=rt.REF_ID AND rt.JENIS=4 
				, pendaftaran.kunjungan pk
				LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID
				, inventory.barang b
				LEFT JOIN inventory.kategori k ON k.ID = b.KATEGORI AND k.JENIS = 3
				LEFT JOIN inventory.kategori invent ON invent.ID = LEFT(k.ID,1) AND invent.JENIS = 1
				LEFT JOIN master.referensi ref ON ref.ID=b.MERK AND ref.JENIS=39
				',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID')),'
			WHERE f.FARMASI=b.ID AND f.`STATUS`=2 AND pk.NOMOR=f.KUNJUNGAN
				AND f.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		  		AND pk.RUANGAN LIKE ''',vRUANGAN,'''
		  		AND r.JENIS_KUNJUNGAN=',LAPORAN,'
		  		',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
		  		',IF(JENISINVENTORY=0,'',CONCAT(' AND invent.ID LIKE ''',vJENISINVENTORY,'''')),'
		  		',IF(JENISKATEGORI=0,'',CONCAT(' AND jenkat.ID LIKE ''',vKATEGORI,'''')),'
		  		',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND k.ID LIKE ''',vKATEGORIBARANG,'''')),'
		  		',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
			GROUP BY f.FARMASI
		)ab
	ORDER BY JUMLAH_OBAT DESC 
	LIMIT 100
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
