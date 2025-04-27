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

-- Dumping structure for procedure laporan.LaporanTelaahAkhir
DROP PROCEDURE IF EXISTS `LaporanTelaahAkhir`;
DELIMITER //
CREATE PROCEDURE `LaporanTelaahAkhir`(
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
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT
	inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST 
	, CONCAT(''LAPORAN TELAAH AKHIR'') JENISLAPORAN, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
	, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
	, rec.ID, rec.DESKRIPSI
	, SUM((SELECT layanan.getStatusTelaahResep(pk.NOMOR, rec.ID, 2))) TELAAH_AKHIR
   , COUNT(pk.NOMOR) JML_RESEP
	FROM pendaftaran.kunjungan pk
		LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR=pk.NOPEN
		LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN 
		, master.ruangan ru
		LEFT JOIN 
		(
		 SELECT 
		   r.ID, r.DESKRIPSI
		 FROM master.referensi r
		 WHERE r.JENIS=216
		 GROUP BY r.ID 
		 ORDER BY r.ID ASC
		) rec ON 1 = 1
		,(SELECT mp.NAMA, ai.PPK, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
						WHERE ai.PPK=mp.ID) inst
				  
	WHERE ru.ID = pk.RUANGAN AND ru.JENIS_KUNJUNGAN = 11 AND pk.STATUS = 2 
			AND ru.ID != ''101040101'' 
			AND pk.RUANGAN LIKE ''',vRUANGAN,''' 
			AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
	GROUP BY rec.ID
	ORDER BY rec.ID
		
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
