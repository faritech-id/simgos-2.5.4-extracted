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

-- membuang struktur untuk procedure laporan.SensusHarianPasienKeluarMati
DROP PROCEDURE IF EXISTS `SensusHarianPasienKeluarMati`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `SensusHarianPasienKeluarMati`(IN `TGLAWAL` DATETIME, IN `RUANGAN` CHAR(10))
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  DECLARE vTGLAWAL DATETIME;
  DECLARE vTGLAKHIR DATETIME;
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  SET vTGLAWAL = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 00:00:00'),'%Y-%m-%d %H:%i:%s');
  SET vTGLAKHIR = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 23:59:59'),'%Y-%m-%d %H:%i:%s');
  
 SET @sqlText = CONCAT('
	SELECT INSERT(INSERT(LPAD(ps.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, crbyr.DESKRIPSI CARABAYAR,
		    IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pk.MASUK, lpp.TANGGAL TGLKELUAR, DATEDIFF(pk.KELUAR,pk.MASUK) LD, CONCAT(rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR,
		    r.DESKRIPSI UNIT, IF(HOUR(TIMEDIFF(lpp.TANGGAL, pp.TANGGAL)) < 48,''< 48 Jam'',''>= 48 Jam'') KET
	FROM layanan.pasien_pulang lpp,
		  pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
    	  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
        LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN master.referensi rjk ON ps.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	WHERE lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1 AND lpp.CARA IN (6,7)
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
		AND pk.NOPEN=pp.NOMOR AND lpp.TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,'''
						
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
