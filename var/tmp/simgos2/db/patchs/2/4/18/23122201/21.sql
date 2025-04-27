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
-- Dumping structure for procedure laporan.LaporanStokOpname
DROP PROCEDURE IF EXISTS `LaporanStokOpname`;
DELIMITER //
CREATE PROCEDURE `LaporanStokOpname`(
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
   
	SET KATEGORI = IF(KATEGORI = '100', '10', KATEGORI);   
   SET RUANGAN = IF(RUANGAN = '0', '', RUANGAN);  
   
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vJENISINVENTORY = CONCAT(JENISINVENTORY,'%');
   SET vKATEGORIBARANG = CONCAT(KATEGORIBARANG,'%');
   
	SET @sqlText = CONCAT('
		SELECT
			rec.PPK, rec.NAMAINST, rec.ALAMATINST, rec.INSTALASI, rec.JENISLAPORAN,
			rec.KATEGORIBRG, rec.ID, rec.KATEGORI, 
			#rec.KODE_BARANG, 
			rec.BARANG, 
			rec.PABRIK, rec.SATUAN, rec.EXD, rec.ADM, rec.FISIK, rec.HRGPOKOK, 
			(rec.FISIK * rec.HRGPOKOK) NILAI_FISIK, rec.SELISIH, 
			(rec.SELISIH * rec.HRGPOKOK) NILAI_SELISIH
		FROM
		(
			SELECT 
				inst.PPK,
				inst.NAMA NAMAINST,
				inst.ALAMAT ALAMATINST,
				(CONCAT (''LAPORAN STOK OPNAME '' , UPPER(jk.DESKRIPSI))) JENISLAPORAN,
				(master.getHeaderLaporan(''',RUANGAN,''')) INSTALASI,
				(master.getHeaderKategoriBarang(''',KATEGORI,''')) KATEGORIBRG,
				IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
				IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER,
				b.ID, k.NAMA KATEGORI, 
				#b.KODE_BARANG, 
				b.NAMA BARANG, r.DESKRIPSI PABRIK, s.DESKRIPSI satuan, MIN(sd.EXD) EXD,
				SUM(IF (sd.SISTEM IS NULL, 0, sd.SISTEM)) ADM,
				SUM(IF (sd.MANUAL IS NULL, 0, sd.MANUAL)) FISIK,
				(SUM(IF (sd.SISTEM IS NULL, 0, sd.SISTEM)) - SUM(IF (sd.MANUAL IS NULL, 0, sd.MANUAL))) SELISIH,
				(SELECT inventory.getHargaBeli(b.ID, DATE_FORMAT(so.TANGGAL, ''%y-%m-%d 23:59:59''))) HRGPOKOK,
				so.TANGGAL 
			FROM 
				inventory.stok_opname so
					LEFT JOIN master.ruangan ru ON so.RUANGAN=ru.ID
					LEFT JOIN master.referensi jk ON ru.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
				, inventory.stok_opname_detil sd
				, inventory.barang_ruangan br
				, inventory.barang b 
					LEFT JOIN master.referensi r ON r.ID = b.MERK AND r.JENIS = 39
					LEFT JOIN inventory.satuan s ON s.ID = b.SATUAN
					LEFT JOIN inventory.kategori k ON k.ID = b.KATEGORI
					',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
				,	(	SELECT 
							mp.NAMA, 
							ai.PPK, 
							mp.ALAMAT
					 	FROM 
					 		aplikasi.instansi ai
							, master.ppk mp
						WHERE ai.PPK=mp.ID
					) inst
				WHERE
					b.ID = br.BARANG AND br.ID = sd.BARANG_RUANGAN AND
					sd.STOK_OPNAME = so.ID									
					AND so.STATUS=''Final'' 
					AND sd.STATUS=2
			  		AND so.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			  		AND so.RUANGAN LIKE ''',vRUANGAN,'''
					  ',IF(KATEGORI=0,'',CONCAT(' AND b.KATEGORI LIKE ''',VKATEGORI,'''')),'
					  ',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
					  ',IF(JENISINVENTORY=0,'',CONCAT(' AND k.ID LIKE ''',vJENISINVENTORY,'''')),'
					  ',IF(JENISKATEGORI=0,'',CONCAT(' AND k.ID LIKE ''',vKATEGORI,'''')),'
					  ',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND k.ID LIKE ''',vKATEGORIBARANG,'''')),'
					  ',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
					  ',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
					  ',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
			  		GROUP BY b.ID
			) rec
			ORDER BY rec.KATEGORI');

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
