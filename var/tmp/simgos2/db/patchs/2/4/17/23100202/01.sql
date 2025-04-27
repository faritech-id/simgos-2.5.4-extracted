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

-- Dumping structure for procedure laporan.LaporanMutasiBarang
DROP PROCEDURE IF EXISTS `LaporanMutasiBarang`;
DELIMITER //
CREATE PROCEDURE `LaporanMutasiBarang`(
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
				SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, ib.NAMA NAMAOBAT, jts.DESKRIPSI, DATE_FORMAT(tsr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLPELAYANAN
						, IF(jts.TAMBAH_ATAU_KURANG=''+'',tsr.JUMLAH,0) MASUK
						, IF(jts.TAMBAH_ATAU_KURANG=''-'',tsr.JUMLAH,0) KELUAR
						, tsr.STOK
						, CONCAT(''LAPORAN MUTASI BARANG '',UPPER(jk.DESKRIPSI)) JENISLAPORAN
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
						, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
						, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
						, LPAD(ps.NORM,8,''0'') NORM, pk.NOPEN, master.getNamaLengkap(ps.NORM) NAMAPASIEN, IF(tsr.JENIS = 33, ra.DESKRIPSI, inventory.getKeteranganTransaksi(tsr.JENIS,tsr.REF)) RUANGASAL
					FROM inventory.transaksi_stok_ruangan tsr
					     LEFT JOIN inventory.jenis_transaksi_stok jts ON tsr.JENIS=jts.ID
					     LEFT JOIN layanan.farmasi lf ON tsr.REF=lf.ID
					     LEFT JOIN pendaftaran.kunjungan pk ON lf.KUNJUNGAN=pk.NOMOR
					     LEFT JOIN layanan.order_resep o ON pk.REF=o.NOMOR
					     LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
					     LEFT JOIN master.ruangan ra ON asal.RUANGAN=ra.ID
					     LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR
					     LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
						, inventory.barang_ruangan br
						, master.ruangan r
						  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
						, inventory.barang ib
						  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
						  LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=ib.ID
						, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
											FROM aplikasi.instansi ai
												, master.ppk mp
											WHERE ai.PPK=mp.ID) inst
					WHERE tsr.BARANG_RUANGAN=br.ID AND br.RUANGAN=r.ID AND r.JENIS=5 AND br.BARANG=ib.ID 
						 AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND tsr.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						 AND br.RUANGAN LIKE ''',vRUANGAN,''' AND ib.ID=',BARANG,'
						  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
						  ',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
						  ',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
						  ',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
						  ',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
						  ',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
						  ',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
											  
					ORDER BY tsr.BARANG_RUANGAN, tsr.TANGGAL
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
