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

-- Dumping structure for procedure laporan.LaporanPelayananBonSisa
DROP PROCEDURE IF EXISTS `LaporanPelayananBonSisa`;
DELIMITER //
CREATE PROCEDURE `LaporanPelayananBonSisa`(
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
		SELECT
		  bon.TANGGAL TGL_BON, lb.INPUT_TIME TGL_LYN, bon.REF
		  ,orp.NOMOR NO_RESEP, LPAD(ps.NORM,8,''0'') NORM
		  ,master.getNamaLengkap(ps.NORM) NAMAPS , crbyr.DESKRIPSI CARA_BYR
		  , ib.ID ,ib.NAMA OBAT ,pk.RUANGAN , r.DESKRIPSI DEPO 
		  , SUM(f.JUMLAH) JML_ORDER
		  , SUM(bon.JUMLAH) JML_BON ,SUM(lb.JUMLAH) JML_BON_DILAYANI
		  , (SUM(bon.JUMLAH) - SUM(lb.JUMLAH)) SISA		  
		  , pk.NOMOR
		  ,inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
		  ,master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
		  ,master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		  ,IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
		  ,IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		  
		FROM
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS = 10
		  , pendaftaran.kunjungan pk
		  LEFT JOIN layanan.farmasi f ON f.KUNJUNGAN = pk.NOMOR
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID
		  , layanan.order_resep orp
		  LEFT JOIN layanan.order_detil_resep odr ON odr.ORDER_ID=orp.NOMOR
		  LEFT JOIN layanan.bon_sisa_farmasi bon ON bon.REF=odr.REF
		  LEFT JOIN layanan.layanan_bon_sisa_farmasi lb ON bon.ID=lb.REF
		  , inventory.barang ib 
		  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
		  LEFT JOIN inventory.penggolongan_barang pb ON ib.ID=pb.BARANG
		  , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
		            FROM aplikasi.instansi ai
		              , master.ppk mp
		            WHERE ai.PPK=mp.ID) inst
		WHERE pk.NOPEN = pp.NOMOR AND pk.REF = orp.NOMOR AND odr.FARMASI = ib.ID 
		AND bon.JUMLAH IS NOT NULL 
				AND f.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND pk.RUANGAN LIKE ''',vRUANGAN,'''
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
			GROUP BY f.FARMASI
			ORDER BY bon.TANGGAL, f.TANGGAL
				
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
