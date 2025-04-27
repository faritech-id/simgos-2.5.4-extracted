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
-- Dumping structure for procedure laporan.LaporanPengirimanInternalFarmasi
DROP PROCEDURE IF EXISTS `LaporanPengirimanInternalFarmasi`;
DELIMITER //
CREATE PROCEDURE `LaporanPengirimanInternalFarmasi`(
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
	
   SET RUANGAN = IF(RUANGAN = '0', '', RUANGAN);  
   
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vJENISINVENTORY = CONCAT(JENISINVENTORY,'%');
   SET vKATEGORIBARANG = CONCAT(KATEGORIBARANG,'%');

	SET @sqlText = CONCAT('
				SELECT 
							p.NOMOR, p.TANGGAL TGL_KRM, pd.BARANG ID_BRG_KIRIM, b.NAMA BRG_KIRIM , pd.JUMLAH JML_KRM
							, inventory.getHargaPenerimaanTerakhir(pd.BARANG) HPT
							, p2.TANGGAL TGL_MINTA, p2.NOMOR NMR_MINTA, pd2.BARANG ID_BRG_MINTA, minta.NAMA BRG_MINTA, pd2.JUMLAH JML_MINTA 
							, p.TUJUAN KD_TUJUAN, r.DESKRIPSI RUANGAN_TUJUAN
							, p.ASAL KD_ASAL, r2.DESKRIPSI RUANGAN_ASAL
							, usr.NAMA AS PETUGAS
							, inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST,
							master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI,
							master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
							IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
					FROM
							inventory.pengiriman p
							LEFT JOIN inventory.pengiriman_detil pd ON p.NOMOR=pd.PENGIRIMAN
							LEFT JOIN inventory.barang b ON pd.BARANG=b.ID
							LEFT JOIN `master`.ruangan r ON p.TUJUAN=r.ID
							LEFT JOIN `master`.ruangan r2 ON r2.ID=p.ASAL
							LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
							',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),' 
							LEFT JOIN aplikasi.pengguna usr ON usr.ID = p.OLEH
							, inventory.permintaan p2
							LEFT JOIN inventory.permintaan_detil pd2 ON p2.NOMOR=pd2.PERMINTAAN
							LEFT JOIN inventory.barang minta ON pd2.BARANG= minta.ID 
							, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
								FROM aplikasi.instansi ai
									, master.ppk mp
								WHERE ai.PPK=mp.ID) inst
					WHERE p.PERMINTAAN=p2.NOMOR AND r.JENIS_KUNJUNGAN=11 AND r2.JENIS_KUNJUNGAN=11 AND r2.DESKRIPSI IS NOT NULL AND
							p.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  	',IF(RUANGAN=0,'',CONCAT(' AND p.ASAL LIKE ''',vRUANGAN,'''')),'
							',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
							',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
							',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
					  		',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
					  		',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
					  		',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
							',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
							',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
						ORDER BY p.TANGGAL DESC ,p.TUJUAN, p.ASAL, b.NAMA
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
