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

-- membuang struktur untuk procedure laporan.SensusHarianPasienPindahan
DROP PROCEDURE IF EXISTS `SensusHarianPasienPindahan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `SensusHarianPasienPindahan`(IN `TGLAWAL` DATETIME, IN `RUANGAN` CHAR(10))
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  DECLARE vTGLAWAL DATETIME;
  DECLARE vTGLAKHIR DATETIME;
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  SET vTGLAWAL = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 00:00:00'),'%Y-%m-%d %H:%i:%s');
  SET vTGLAKHIR = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 23:59:59'),'%Y-%m-%d %H:%i:%s');
  
 SET @sqlText = CONCAT('
	SELECT INSERT(INSERT(LPAD(p.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, pd.NOMOR NOPEN, ref.DESKRIPSI CARABAYAR, CONCAT(rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR, IF(tk.RUANGAN=asal.RUANGAN,''Pindah Kamar/Kelas'','''') KET, rasal.DESKRIPSI ASALRUANGAN
			FROM master.pasien p
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					, pendaftaran.kunjungan tk
				  LEFT JOIN master.ruang_kamar_tidur rkt ON tk.RUANG_KAMAR_TIDUR=rkt.ID
		    	  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
		        LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
				, master.ruangan jkr
				, pendaftaran.mutasi pm
				, pendaftaran.kunjungan asal
				  LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID AND rasal.JENIS_KUNJUNGAN=3 AND rasal.JENIS=5
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN AND  pd.STATUS IN (1,2)
					AND tk.REF IS NOT NULL AND tk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND tk.`STATUS` IN (1,2)
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,'''
					AND jkr.JENIS_KUNJUNGAN=3 AND tk.RUANGAN LIKE ''',vRUANGAN,''' AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
				
		
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
