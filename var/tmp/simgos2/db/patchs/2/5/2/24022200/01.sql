-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.36 - MySQL Community Server - GPL
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

-- Dumping structure for procedure laporan.LaporanReturPelayananObat
DROP PROCEDURE IF EXISTS `LaporanReturPelayananObat`;
DELIMITER //
CREATE PROCEDURE `LaporanReturPelayananObat`(
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
   SET @HRGDASAR=0; 
   
   SET@sqlText = CONCAT ('
		SELECT  @HRGDASAR:=inventory.getHrgDasarBarang(f2.FARMASI, pk.MASUK) HRG_DASAR,(@HRGDASAR+ (@HRGDASAR*mf.MARGIN/100)) HRGOBAT, f.JUMLAH*(@HRGDASAR+ (@HRGDASAR*mf.MARGIN/100)) TOTAL_TARIF
		, f.ID, f.KUNJUNGAN,  rf.ID ID_RETUR_FARMASI, rf.TANGGAL
		, f.FARMASI, b.NAMA NMOBAT
		, rf.JUMLAH
		, pk.NOMOR, pk.NOPEN, `master`.getNamaLengkap(pp.NORM) NMPASIEN, LPAD(pp.NORM,8,0) NORM
		, ref.DESKRIPSI CARABAYAR
		, odr.ORDER_ID 
		, p.NAMA USER_RETUR , r.DESKRIPSI RUANGAN, r.ID
		, ''LAPORAN RETUR PELAYANAN OBAT'' JENISLAPORAN, inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
		, IFNULL(master.getHeaderKategoriBarang(IF(''',KATEGORIBARANG,'''!=''0'',''',KATEGORIBARANG,''',IF(''',KATEGORI,'''!=''0'',''',KATEGORI,''',''',JENISINVENTORY,'''))),''Semua'') KATEGORI
		, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		
		FROM  
			layanan.retur_farmasi rf
			LEFT JOIN layanan.farmasi f  ON rf.ID_FARMASI = f.ID
			LEFT JOIN inventory.barang b ON b.ID=f.FARMASI
			LEFT JOIN layanan.order_detil_resep odr ON odr.REF=f.ID
			LEFT JOIN aplikasi.pengguna p ON p.ID=rf.OLEH
			LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
			',IF(PENGGOLONGAN=0,'',CONCAT('LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
			, layanan.farmasi f2
			LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR=f2.KUNJUNGAN
			LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR=pk.NOPEN
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN `master`.referensi ref ON ref.ID=pj.JENIS AND ref.JENIS=10
			LEFT JOIN `master`.margin_penjamin_farmasi mf ON mf.PENJAMIN=pj.JENIS AND mf.JENIS=1 AND mf.STATUS!=0
			LEFT JOIN `master`.ruangan r ON r.ID=pk.RUANGAN
			, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
						WHERE ai.PPK=mp.ID) inst
		WHERE rf.ID_FARMASI = f2.ID AND pk.`STATUS`!=0
		AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND r.ID LIKE ''',vRUANGAN,'''
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
		
		ORDER BY rf.TANGGAL DESC, ref.DESKRIPSI DESC , pp.NORM DESC
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
