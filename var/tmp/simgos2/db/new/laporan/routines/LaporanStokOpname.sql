-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure laporan.LaporanStokOpname
DROP PROCEDURE IF EXISTS `LaporanStokOpname`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanStokOpname`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
   
	SET KATEGORI = IF(KATEGORI = '100', '10', KATEGORI);   
   
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   
	SET @sqlText = CONCAT('
				SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST,so.TANGGAL, ib.NAMA NAMAOBAT, sod.AWAL, sod.BARANG_MASUK, sod.BARANG_KELUAR, sod.MANUAL AKHIR,
		       CONCAT(''LAPORAN STOK OPNAME '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
				 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
				 master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI,
				 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
				 IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
			FROM inventory.stok_opname so
			     LEFT JOIN master.ruangan r ON so.RUANGAN=r.ID
				  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15,
			     inventory.stok_opname_detil sod
			     LEFT JOIN inventory.barang_ruangan ibr ON sod.BARANG_RUANGAN=ibr.ID
			     LEFT JOIN inventory.barang ib ON ibr.BARANG=ib.ID
				  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID,
			     (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
							FROM aplikasi.instansi ai
								, master.ppk mp
							WHERE ai.PPK=mp.ID) inst
			WHERE so.ID=sod.STOK_OPNAME AND so.`STATUS`=''Final'' AND sod.`STATUS`=2
			  AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND so.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			  AND so.RUANGAN LIKE ''',vRUANGAN,'''
			  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
			  ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
