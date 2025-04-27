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

-- Dumping structure for procedure laporan.LaporanObatStagnan
DELIMITER //
CREATE PROCEDURE `LaporanObatStagnan`(
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
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');     
	SET vTGLAWAL = DATE(TGLAWAL);
	SET vTGLAKHIR = DATE(TGLAKHIR);

 SET @sqlText = CONCAT('
 	SELECT * FROM (SELECT inst.*, 
	     CONCAT (''LAPORAN OBAT STAGNAN '',UPPER(ref.DESKRIPSI)) JENISLAPORAN,
	         master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
        master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORIBRG,
        IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
        IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER,
      ib.ID, ib.NAMA NAMAOBAT, pbd.MASA_BERLAKU, k.NAMA NMKATEGORI, st.NAMA NMSATUAN, ref.DESKRIPSI NMMERK
     , SUM(br.STOK) STOK
     , inventory.getHargaPenerimaanTerakhirBySo(ib.ID, so.ID) HARGAPENERIMAANTERAKHIR
	  ,(SUM(br.STOK) * inventory.getHargaPenerimaanTerakhirBySo(ib.ID, so.ID)) JMLHARGA
	  ,(SELECT IF(SUM(sod1.BARANG_MASUK+sod1.BARANG_KELUAR)=0,1,0)
        FROM inventory.stok_opname so1
		  ,inventory.stok_opname_detil sod1
		  ,inventory.barang_ruangan br1
		  ,inventory.barang ib1
		  WHERE sod1.BARANG_RUANGAN=br1.ID AND br1.BARANG=ib1.ID
          AND sod1.STOK_OPNAME=so1.ID AND so1.STATUS!=0
          AND so1.TANGGAL BETWEEN CONCAT(DATE_FORMAT(DATE_SUB(so.TANGGAL, INTERVAL 2 MONTH),''%Y-%m''),''-01'') AND LAST_DAY(so.TANGGAL)
          AND ib1.ID=ib.ID) STATUSSTAGNAN
  FROM inventory.stok_opname so
   , inventory.stok_opname_detil sod
   , inventory.barang_ruangan br
   , inventory.barang ib
    LEFT JOIN inventory.kategori k ON k.ID = ib.KATEGORI
    LEFT JOIN inventory.satuan st ON st.ID = ib.SATUAN
    LEFT JOIN inventory.penerimaan_barang_detil pbd ON ib.ID= pbd.BARANG
    LEFT JOIN master.referensi ref ON ref.ID = ib.MERK AND ref.JENIS = 39
   , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
            FROM aplikasi.instansi ai
              , master.ppk mp
            WHERE ai.PPK=mp.ID) inst
  WHERE sod.BARANG_RUANGAN=br.ID AND br.BARANG=ib.ID
    AND sod.STOK_OPNAME=so.ID AND so.STATUS!=0 AND br.RUANGAN LIKE ''',vRUANGAN,'''
    AND so.TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''' 
  GROUP BY ib.ID
) ab
WHERE STATUSSTAGNAN=1 AND STOK > 0
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
