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
USE laporan;
-- Dumping structure for procedure laporan.LaporanPergerakanBarang
DROP PROCEDURE IF EXISTS `LaporanPergerakanBarang`;
DELIMITER //
CREATE PROCEDURE `LaporanPergerakanBarang`(
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
   
	SET @VAWAL:=DATE_ADD(DATE_FORMAT(LAST_DAY(TGLAKHIR),'%Y-%m-01 00:00:00'), INTERVAL -2 MONTH);
	SET @VAKHIR:=DATE_FORMAT(LAST_DAY(TGLAKHIR),'%Y-%m-%d 23:59:59');
	
	SET @sqlText = CONCAT('
					SELECT
						br.BARANG,
						b.NAMA NAMABARANG
						, IF((IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(''',@VAKHIR,'''),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
							  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -1 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
							  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -2 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0)
							  	)=1,''Slow Moving'', 
										IF((IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(''',@VAKHIR,'''),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
									  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -1 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
									  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -2 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0)
									  	)=2,''Slow Moving'', 
												IF((IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(''',@VAKHIR,'''),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
											  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -1 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0) +
											  		IF(SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -2 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) > 0, 1, 0)
											  	)=3,''Fast Moving'', 
														''Death Moving''
												)
										)
								) STATUS_MOVING
						, SUM(IF(MONTH(tr.TANGGAL)=MONTH(''',@VAKHIR,'''),IF(tr.JUMLAH > 0,1,0),0)) BLN1
					  	, SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -1 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) BLN2
					  	, SUM(IF(MONTH(tr.TANGGAL)=MONTH(DATE_ADD(''',@VAKHIR,''', INTERVAL -2 MONTH)),IF(tr.JUMLAH > 0,1,0),0)) BLN3
						, DATE_FORMAT(''',@VAKHIR,''',''%M'') NM_BLN1
					  	, DATE_FORMAT((DATE_ADD(''',@VAKHIR,''', INTERVAL -1 MONTH)),''%M'') NM_BLN2
					  	, DATE_FORMAT((DATE_ADD(''',@VAKHIR,''', INTERVAL -2 MONTH)),''%M'') NM_BLN3
						, LOCALTIME TARIKDATA
						, ''',@VAWAL,''' PAWAL
						, ''',@VAKHIR,''' PAKHIR
						, MONTH(tr.TANGGAL) BLNTRANSAKSI, kat.NAMA KATEGORI
						, b.ID KATALOG
						, '' - '' STATUS_MOVING
              FROM 
						inventory.barang b
						LEFT JOIN inventory.kategori kat ON kat.ID = b.KATEGORI
						LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG= b.ID
						',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
						,inventory.barang_ruangan br 
						LEFT JOIN inventory.transaksi_stok_ruangan tr ON tr.BARANG_RUANGAN = br.ID
					WHERE
						br.BARANG = b.ID
					AND tr.TANGGAL BETWEEN ''',@VAWAL,''' AND ''',@VAKHIR,'''
					',IF(RUANGAN=0,'',CONCAT(' AND br.RUANGAN LIKE ''',vRUANGAN,'''')),'
					',IF(BARANG=0,'',CONCAT(' AND br.BARANG = ',BARANG,'')),'
					',IF(KATEGORI=0,'',CONCAT(' AND b.KATEGORI LIKE ''',vKATEGORI,'''')),'
					',IF(JENISKATEGORI IN (0,10100),'',CONCAT(' AND kat.ID LIKE ''',vKATEGORI,'''')),'
					',IF(JENISINVENTORY=0,'',CONCAT(' AND kat.ID LIKE ''',vJENISINVENTORY,'''')),'
					',IF(KATEGORIBARANG=0,'',CONCAT(' AND kat.ID LIKE ''',vKATEGORIBARANG,'''')),'
					',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
					',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
					',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
					GROUP BY b.ID
					ORDER BY b.NAMA, b.ID
				
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
