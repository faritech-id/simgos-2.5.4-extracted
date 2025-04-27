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
-- Dumping structure for procedure laporan.LaporanRekapPenerimaanBarangPerFaktur
DROP PROCEDURE IF EXISTS `LaporanRekapPenerimaanBarangPerFaktur`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapPenerimaanBarangPerFaktur`(
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
			SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, py.NAMA NAMAREKANAN, py.ALAMAT ALAMATREKANAN, py.TELEPON TLPREKANAN, pb.FAKTUR NOFAKTUR, pb.TANGGAL TGLFAKTUR, pb.TANGGAL_DIBUAT
				  , ib.NAMA NAMABARANG, pbd.JUMLAH, s.NAMA NAMASATUAN, pbd.HARGA, ROUND(SUM(pbd.DISKON),2) DISKON, ROUND(SUM(((pbd.JUMLAH * pbd.HARGA) - pbd.DISKON)),2) TOTAL
				  , ROUND(SUM((pbd.JUMLAH * pbd.HARGA)),2) NILAI_JUMLAH
				  , ROUND(SUM(IF(pb.PPN=''Ya'',0, ((pbd.JUMLAH * pbd.HARGA) * 11 / 100))),2) NILAI_PPN
				  , ROUND(SUM((
				  		(pbd.JUMLAH * pbd.HARGA) +
				  			IF(pb.PPN=''Ya'',0, ((pbd.JUMLAH * pbd.HARGA) * 11 / 100)) -
							 pbd.DISKON
						)),2) NILAI_TOTAL
				  , master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
				  , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				  , IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
				  , pb.NO_SP, ra.NAMA ALOKASI_ANGGARAN
				FROM inventory.penerimaan_barang pb
				     LEFT JOIN inventory.penyedia py ON pb.REKANAN=py.ID
				     LEFT JOIN master.ruangan r ON pb.RUANGAN=r.ID
				     LEFT JOIN inventory.ref_anggaran ra ON ra.ID = pb.SUMBER_DANA
					, inventory.penerimaan_barang_detil pbd
					  LEFT JOIN inventory.barang ib ON pbd.BARANG=ib.ID
					  LEFT JOIN inventory.satuan s ON ib.SATUAN=s.ID
					  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
					  ',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang gb ON gb.BARANG=ib.ID AND gb.CHECKED=1')),'
					, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
								FROM aplikasi.instansi ai
									, master.ppk mp
								WHERE ai.PPK=mp.ID) inst
				WHERE pb.ID=pbd.PENERIMAAN AND pb.TANGGAL_DIBUAT BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				  AND pb.RUANGAN LIKE ''',vRUANGAN,''' AND pb.STATUS=2 AND pbd.STATUS=2
				  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
					',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
					',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
					',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
					',IF(KATEGORIBARANG=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
					',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
					',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
					',IF(PENGGOLONGAN=0,'',CONCAT(' AND gb.PENGGOLONGAN=',PENGGOLONGAN)),'
				GROUP BY pb.FAKTUR		
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
