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

-- membuang struktur untuk procedure laporan.LaporanRL34
DROP PROCEDURE IF EXISTS `LaporanRL34`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL34`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME

)
BEGIN	

	
	DECLARE TAHUN INT;
      
   SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.KODE, rl.DESKRIPSI, JUMLAH, RS, BIDAN, PUSKESMAS, FASKES, RUJUKANHIDUP, RUJUKANMATI,NONMEDISHIDUP
			, NONMEDISMATI, NONRUJUKANHIDUP, NONRUJUKANMATI, DIRUJUK
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT ic.RL34 ID, COUNT(md.NOPEN) JUMLAH
							, SUM(IF(pr.JENIS=1,1,0)) RS
							, 0 BIDAN
							, SUM(IF(pr.JENIS=2,1,0)) PUSKESMAS
							, SUM(IF(pr.JENIS NOT IN (1,2),1,0)) FASKES
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) RUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
							, 0 NONMEDISHIDUP, 0 NONMEDISMATI
							, SUM(IF(pp.RUJUKAN IS NULL AND (pl.CARA NOT IN (6,7) OR pl.CARA IS NULL),1,0)) NONRUJUKANHIDUP
							, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
							, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
						FROM medicalrecord.diagnosa md
							, master.rl34_icd10 ic
							, pendaftaran.pendaftaran pp
							  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
							  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
							  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
						WHERE md.`STATUS`!=0 AND md.KODE=ic.ID AND pl.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
						GROUP BY ic.RL34) rl34 ON rl34.ID=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS=''100103'' AND jrl.ID=4
		ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
