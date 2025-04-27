-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for informasi
USE `informasi`;

-- Dumping structure for procedure informasi.historySeveritySikepo
DROP PROCEDURE IF EXISTS `historySeveritySikepo`;
DELIMITER //
CREATE PROCEDURE `historySeveritySikepo`(
	IN `PCODE_CBG` CHAR(25)
)
BEGIN
    
 SET @sqlText = CONCAT('
				 SELECT pd.NORM, pd.NOMOR NOPEN, pd.TANGGAL TGLREG, pl.TANGGAL TGLKELUAR, gr.CODECBG      
						, REVERSE(LEFT(REVERSE(gr.CODECBG), INSTR(REVERSE(gr.CODECBG),''-'')-1)) LEVEL
				      , (SELECT GROUP_CONCAT(md.KODE)        
								FROM medicalrecord.diagnosa md 
				        WHERE md.`STATUS`=1 AND md.NOPEN=pd.NOMOR AND md.INACBG=1 AND md.INA_GROUPER=0) DIAGNOSA
				      , (SELECT GROUP_CONCAT(pr.KODE) 
								FROM  medicalrecord.prosedur pr 
				        WHERE pr.`STATUS`=1 AND pr.NOPEN=pd.NOMOR AND pr.INACBG=1 AND pr.INA_GROUPER=0) PROSEDUR     
				FROM inacbg.hasil_grouping gr
				      , pendaftaran.pendaftaran pd        
						LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN AND pl.`STATUS`!=0
				      , pendaftaran.tujuan_pasien tp      
						, master.ruangan r
				WHERE LEFT(gr.CODECBG,6)=LEFT(''',PCODE_CBG,''',6)       
				  AND IF(REVERSE(LEFT(REVERSE(''',PCODE_CBG,'''), INSTR(REVERSE(''',PCODE_CBG,'''),''-'')-1)) IN (''II'',''III''),REVERSE(LEFT(REVERSE(gr.CODECBG), INSTR(REVERSE(gr.CODECBG),''-'')-1)) NOT IN (''X'',''I'',''II''),REVERSE(LEFT(REVERSE(gr.CODECBG), INSTR(REVERSE(gr.CODECBG),''-'')-1)) NOT IN (''X'',''I''))
				  AND gr.NOPEN=pd.NOMOR AND pd.NOMOR=tp.NOPEN        
				  AND tp.`STATUS` !=0 AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
				ORDER BY REVERSE(LEFT(REVERSE(gr.CODECBG), INSTR(REVERSE(gr.CODECBG),''-'')-1))
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
