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

-- Dumping structure for procedure laporan.LaporanPenerimaanBarangExternal
DROP PROCEDURE IF EXISTS `LaporanPenerimaanBarangExternal`;
DELIMITER //
CREATE PROCEDURE `LaporanPenerimaanBarangExternal`(
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
      SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, py.NAMA NAMAREKANAN, py.ALAMAT ALAMATREKANAN, py.TELEPON TLPREKANAN, pb.FAKTUR NOFAKTUR, pb.TANGGAL TGLFAKTUR, pb.TANGGAL_DIBUAT
          , ib.ID, ib.NAMA NAMABARANG, ib.ID REF_ID, ik.NAMA KTG, ib.ID
			    , pbd.JUMLAH, s.NAMA NAMASATUAN, pbd.HARGA, pbd.DISKON, ((pbd.JUMLAH * pbd.HARGA) - pbd.DISKON) TOTAL
          , master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI, inventory.getGolonganPerBarang(ib.ID) GOLONGAN
          , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
          , IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
          , pb.NO_SP, '''' ALOKASI_ANGGARAN
        FROM inventory.penerimaan_barang pb
             LEFT JOIN inventory.penyedia py ON pb.REKANAN=py.ID
             LEFT JOIN master.ruangan r ON pb.RUANGAN=r.ID
          , inventory.penerimaan_barang_detil pbd
            LEFT JOIN inventory.barang ib ON pbd.BARANG=ib.ID
            LEFT JOIN inventory.satuan s ON ib.SATUAN=s.ID
            LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
          , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
                FROM aplikasi.instansi ai
                  , master.ppk mp
                WHERE ai.PPK=mp.ID) inst
        WHERE pb.ID=pbd.PENERIMAAN AND pb.TANGGAL_DIBUAT BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
          AND pb.RUANGAN LIKE ''',vRUANGAN,''' AND pb.STATUS=2 AND pbd.STATUS=2
          ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
          ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'    
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
