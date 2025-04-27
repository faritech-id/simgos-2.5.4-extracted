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

-- Dumping structure for procedure laporan.LaporanObatResepTidakTerlayani
DROP PROCEDURE IF EXISTS `LaporanObatResepTidakTerlayani`;
DELIMITER //
CREATE PROCEDURE `LaporanObatResepTidakTerlayani`(
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
			LPAD(pas.NORM,8,''0'') NORM, master.getNamaLengkap(pas.NORM) NAMA_PASIEN
			, rp.TANGGAL,master.getNamaLengkapPegawai(mp.NIP) DPJP
			, pk.RUANGAN ASAL, ruang.DESKRIPSI ASAL_RESEP
			, rp.TUJUAN, r2.DESKRIPSI DEPO
			, if(f.ALASAN_TIDAK_TERLAYANI IS NULL,''Terlayani'', ''Tidak terlayani'') status
			, b.NAMA AS OBAT ,f.JUMLAH, lodr.JUMLAH JML_DILAYANI, f.ALASAN_TIDAK_TERLAYANI
			, inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
		FROM 
			pendaftaran.kunjungan pk
			LEFT JOIN master.ruangan ruang ON pk.RUANGAN=ruang.ID 
			LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR
			LEFT JOIN master.pasien pas ON pp.NORM=pas.NORM
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			, layanan.order_resep rp
			LEFT JOIN master.dokter md ON rp.DOKTER_DPJP=md.ID
			LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			LEFT JOIN layanan.order_detil_resep lodr ON rp.NOMOR=lodr.ORDER_ID 
			LEFT JOIN layanan.farmasi f ON f.ID=lodr.REF
			LEFT JOIN master.ruangan r2 ON r2.ID=rp.TUJUAN
			, inventory.barang b 
			LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
			',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID')),'
			, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
		            FROM aplikasi.instansi ai
		              , master.ppk mp
		            WHERE ai.PPK=mp.ID) inst
		WHERE f.`STATUS`IN(1,2) AND rp.KUNJUNGAN=pk.NOMOR 
				AND f.ALASAN_TIDAK_TERLAYANI IS NOT NULL AND f.FARMASI=b.id
				AND f.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(RUANGAN='0','',CONCAT(' AND r2.ID LIKE ''',vRUANGAN,'''')),'
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
				
		GROUP BY pp.NOMOR
		
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
