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

-- Dumping structure for procedure laporan.LaporanBarangExpiredDate
DROP PROCEDURE IF EXISTS `LaporanBarangExpiredDate`;
DELIMITER //
CREATE PROCEDURE `LaporanBarangExpiredDate`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT
)
BEGIN

  DECLARE vTGLAWAL DATE;
   DECLARE vTGLAKHIR DATE;
  DECLARE vRUANGAN VARCHAR(11);
  DECLARE vKATEGORI VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vTGLAWAL = DATE(TGLAWAL);
   SET vTGLAKHIR = DATE(TGLAKHIR);
 
  SET @sqlText = CONCAT('
    SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
          , ib.NAMA NAMABARANG, s.NAMA NAMASATUAN, py.NAMA NAMAREKANAN, pb.FAKTUR NOFAKTUR, pb.TANGGAL_PENERIMAAN, pbd.NO_BATCH
			 , pbd.JUMLAH
			 , inventory.getHargaPenerimaanTerakhir(ib.ID) HRG_SATUAN
			 , (pbd.JUMLAH * inventory.getHargaPenerimaanTerakhir(ib.ID)) TOTAL
        , (SELECT pbd1.MASA_BERLAKU
          FROM inventory.penerimaan_barang pb1
               LEFT JOIN inventory.penyedia py1 ON pb1.REKANAN=py1.ID
               LEFT JOIN master.ruangan r1 ON pb1.RUANGAN=r1.ID
            , inventory.penerimaan_barang_detil pbd1
              LEFT JOIN inventory.barang ib1 ON pbd1.BARANG=ib1.ID
              LEFT JOIN inventory.satuan s1 ON ib1.SATUAN=s1.ID
              LEFT JOIN inventory.kategori ik1 ON ib1.KATEGORI=ik1.ID
          WHERE pb1.ID=pbd1.PENERIMAAN AND pbd1.BARANG=pbd.BARANG AND pbd1.STATUS!=0 AND pbd1.MASA_BERLAKU BETWEEN ''',VTGLAWAL,''' AND ''',VTGLAKHIR,'''
              ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND pb1.RUANGAN LIKE ''',vRUANGAN,'''  AND r1.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
             /*  AND pb1.RUANGAN LIKE ''',vRUANGAN,'''  AND r1.JENIS_KUNJUNGAN=''',LAPORAN,''' */
              ',IF(KATEGORI=0,'',CONCAT(' AND ik1.ID LIKE ''',VKATEGORI,'''')),'
              ',IF(BARANG=0,'',CONCAT(' AND ib1.ID=',BARANG)),'
          ORDER BY pbd1.MASA_BERLAKU ASC
          LIMIT 1) MASA_BERLAKU
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
    WHERE pb.ID=pbd.PENERIMAAN AND pbd.STATUS!=0  AND pb.MASA_BERLAKU BETWEEN ''',VTGLAWAL,''' AND ''',VTGLAKHIR,'''
      ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND pb.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
     /*  AND pb.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,''' */
      ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
      ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
    GROUP BY pbd.BARANG
    ORDER BY pbd.BARANG
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
