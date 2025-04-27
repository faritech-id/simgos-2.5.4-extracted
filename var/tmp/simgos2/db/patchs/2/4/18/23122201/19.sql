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
-- Dumping structure for procedure laporan.LaporanRekapResepJaminan
DROP PROCEDURE IF EXISTS `LaporanRekapResepJaminan`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapResepJaminan`(
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
		SELECT NAMAINST, RGFARMASI, UNIT, CARABAYAR, SUM(LEMBAR) LEMBAR, SUM(JMLOBAT) JMLOBAT, SUM(JUMLAH) JUMLAH, INSTALASI, KATEGORI
FROM
		(
		SELECT 
			inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, COUNT(DISTINCT(lf.ID)) LEMBAR
		   , UPPER(rg.DESKRIPSI) RGFARMASI, UPPER(r.DESKRIPSI) UNIT
		   , UPPER(IFNULL(CONCAT(''BPJS '',psr.nmJenisPeserta),cr.DESKRIPSI)) CARABAYAR
			, sum(rt.JUMLAH) JMLOBAT, SUM(rt.JUMLAH * rt.TARIF) JUMLAH
			, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
						
			FROM layanan.farmasi lf
				  LEFT JOIN master.referensi ref ON lf.ATURAN_PAKAI=ref.ID AND ref.JENIS=41
				  LEFT JOIN pembayaran.rincian_tagihan rt ON lf.ID=rt.REF_ID AND rt.JENIS=4
				, pendaftaran.kunjungan pk
			     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
			     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
				  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
				  LEFT JOIN master.ruangan rg ON pk.RUANGAN=rg.ID AND rg.JENIS=5
				  LEFT JOIN master.referensi jk ON rg.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
				  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
				  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
			     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
			   , pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
				  LEFT JOIN bpjs.peserta psr ON pp.NORM=psr.norm
				, inventory.barang ib
				  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
				  ',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang gb ON gb.BARANG=ib.ID AND gb.CHECKED=1')),'
				, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
			WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
				AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID AND rg.JENIS_KUNJUNGAN=',LAPORAN,'
				AND lf.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND pk.RUANGAN LIKE ''',vRUANGAN,'''
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND gb.PENGGOLONGAN=',PENGGOLONGAN)),'
			#	ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN	
			#	AND INSTR(ik.NAMA,''Tusla'')!=1
			
				GROUP BY pk.NOMOR
				) ab
				GROUP BY ab.CARABAYAR
				ORDER BY ab.CARABAYAR	
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
