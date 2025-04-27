-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
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

-- Dumping structure for procedure laporan.LaporanPelayananPaketFarmasiPerPasienKlikBayar
DROP PROCEDURE IF EXISTS `LaporanPelayananPaketFarmasiPerPasienKlikBayar`;
DELIMITER //
CREATE PROCEDURE `LaporanPelayananPaketFarmasiPerPasienKlikBayar`(
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
		SELECT LPAD(pp.NORM,8,0) NORM,pj.JENIS,mf.MARGIN, f.JUMLAH, @HRGDASAR:=inventory.getHrgDasarBarang(f.FARMASI, pk.MASUK) HRG_DASAR,(@HRGDASAR+ (@HRGDASAR*mf.MARGIN/100)) HRGSATUAN, f.JUMLAH*(@HRGDASAR+ (@HRGDASAR*mf.MARGIN/100)) TOTAL_TARIF
		, f.ID, f.FARMASI, b.NAMA NMOBAT, pk.MASUK TGL
		, r.DESKRIPSI DEPO, r2.DESKRIPSI RUANG_AWAL
		, pp.NOMOR, `master`.getNamaLengkap(pp.NORM) NMPASIEN, pk2.NOMOR,pk.NOMOR NOKUN ,pp.NOMOR NOPEN
		, pt.TANGGAL TGL_KLIK_BAYAR
		, inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
		, CONCAT(''LAPORAN PELAYANAN PAKET FARMASI PASIEN PER TANGGAL KLIK BAYAR'') JENISLAPORAN
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, IFNULL(master.getHeaderKategoriBarang(IF(''',KATEGORIBARANG,'''!=''0'',''',KATEGORIBARANG,''',IF(''',KATEGORI,'''!=''0'',''',KATEGORI,''',''',JENISINVENTORY,'''))),''Semua'') KATEGORI
		, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			
		FROM
		layanan.order_resep res  
			LEFT JOIN pendaftaran.kunjungan pk2 ON pk2.NOMOR=res.KUNJUNGAN AND res.`STATUS`!=0 
			LEFT JOIN `master`.ruangan r2 ON r2.ID=pk2.RUANGAN
			LEFT JOIN pendaftaran.pendaftaran pp ON pk2.NOPEN=pp.NOMOR
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN `master`.margin_penjamin_farmasi mf ON mf.PENJAMIN=pj.JENIS AND mf.JENIS=1 AND mf.STATUS!=0
		LEFT JOIN `master`.pasien p ON p.NORM=pp.NORM
		, pendaftaran.kunjungan pk 
			LEFT JOIN pendaftaran.pendaftaran pend ON pend.NOMOR=pk.NOPEN
			LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN=pend.NOMOR
		, layanan.farmasi f   
		, inventory.barang b
			LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
			',IF(PENGGOLONGAN=0,'',CONCAT('LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
		,`master`.ruangan r
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
		WHERE pk.REF=res.NOMOR AND r.ID=pk.RUANGAN AND r.JENIS=5 AND f.TINDAKAN_PAKET=1 AND pk.NOMOR=f.KUNJUNGAN AND f.FARMASI=b.ID AND pt.`STATUS`=2
			AND pk2.`STATUS`!=0 AND f.`STATUS`=2  
			AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
		ORDER BY res.TANGGAL DESC 
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
