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

-- Dumping structure for procedure laporan.LaporanDetailTransaksiTmTk
DROP PROCEDURE IF EXISTS `LaporanDetailTransaksiTmTk`;
DELIMITER //
CREATE PROCEDURE `LaporanDetailTransaksiTmTk`(
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
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   
	SET @sqlText = CONCAT('
		SELECT
			''LAPORAN TRANSAKSI HIBAH / TMTK'' JENISLAPORAN
			, hb.ID, ru.DESKRIPSI RUANGAN, hb.TANGGAL, hb.NOMOR, hb.KET, hb.JENIS, hb.TANGGAL
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
			, IF(hb.TMTK = 1, ''TRANSFER'',''HIBAH'') TRANSAKSI
			, IF(hb.JENIS = 1, ''MASUK'',''KELUAR'') JENISTRANSAKSI
			, IF(hb.JENIS = 1, pny.NAMA, ru.DESKRIPSI) ASALTRANSAKSI
			, IF(hb.JENIS = 1, ru.DESKRIPSI, tjh.NAMA) TUJUANTRANSAKSI
			, ib.NAMA NMBARANG, ik.NAMA NMKATEGORI, hbd.QTY
			, if(hb.JENIS = ''MASUK'',hbd.HARGA, inventory.getHargaPenerimaanTerakhir(ib.ID)) HARGA
			, if(hb.JENIS = ''MASUK'',hbd.HARGA, inventory.getHargaPenerimaanTerakhir(ib.ID) * hbd.QTY ) JUMLAH
		FROM inventory.hibah hb
		LEFT JOIN inventory.tujuan_hibah tjh ON tjh.ID = hb.ASAL
		LEFT JOIN inventory.penyedia pny ON pny.ID = hb.ASAL
		LEFT JOIN master.ruangan ru ON ru.ID = hb.RUANGAN
		, inventory.hibah_detil hbd
		, inventory.barang ib
		LEFT JOIN inventory.kategori ik ON ik.ID = ib.KATEGORI
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
		WHERE ib.ID = hbd.BARANG AND hbd.HIBAH = hb.ID AND hb.STATUS = 2
		AND hb.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		',IF(RUANGAN='0','',CONCAT(' AND hb.RUANGAN LIKE ''',vRUANGAN,'''')),'
		',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
		',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
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
