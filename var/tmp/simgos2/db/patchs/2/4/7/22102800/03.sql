-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk kemkes-sirs
CREATE DATABASE IF NOT EXISTS `kemkes-sirs` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `kemkes-sirs`;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL12
DROP PROCEDURE IF EXISTS `ambilDataRL12`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL12`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE VTGLAWAL DATE;
	DECLARE VTGLAKHIR DATE;
	DECLARE VTGLAWAL2 DATE;
	DECLARE VTGLAKHIR2 DATE;
	
	SET VTGLAWAL = STR_TO_DATE(CONCAT(PTAHUN, '-01-01'), '%Y-%m-%d');
	SET VTGLAKHIR = STR_TO_DATE(CONCAT(PTAHUN, '-12-31'), '%Y-%m-%d');
	
	SET VTGLAWAL2 = STR_TO_DATE(CONCAT(PTAHUN, '-01-01 00:00:00'), '%Y-%m-%d');
	SET VTGLAKHIR2 = STR_TO_DATE(CONCAT(PTAHUN, '-12-31 23:59:59'), '%Y-%m-%d');
	
	IF DATE(NOW()) <= VTGLAKHIR THEN
		SET VTGLAKHIR = DATE(NOW());
		SET VTGLAKHIR2 = NOW();
	END IF;
	 
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL12;
	
	SET @sqlText = CONCAT('
	   CREATE TEMPORARY TABLE TEMP_LAPORAN_RL12 ENGINE = MEMORY
		SELECT INST.*, ''',PTAHUN,''' TAHUN, SUM(AWAL) AWAL, SUM(MASUK) MASUK
				, SUM(PINDAHAN) PINDAHAN, SUM(DIPINDAHKAN) DIPINDAHKAN, SUM(HIDUP) HIDUP
				, SUM(MATI) MATI, SUM(MATIKURANG48) MATIKURANG48, SUM(MATILEBIH48) MATILEBIH48
				, SUM(LD) LD, SUM(SISA) SISA, SUM(HP) HP
				, @JMLTT:=(SELECT COUNT(TEMPAT_TIDUR) 
									FROM master.ruang_kamar_tidur rkt 
										, master.ruang_kamar rk
									WHERE rkt.`STATUS`!=0 AND rkt.RUANG_KAMAR=rk.ID AND rk.STATUS!=0) JMLTT 
				, IF(SUM(HP)=0 OR @JMLTT=0,0,ROUND((SUM(HP) * 100) / (@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)),2)) BOR
				, IF(SUM(HPLK)=0 OR @JMLTT=0,0,ROUND((SUM(HPLK) * 100) / (@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)),2)) BORLK
				, IF(SUM(HPPR)=0 OR @JMLTT=0,0,ROUND((SUM(HPPR) * 100) / (@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)),2)) BORPR
				, SUM(LD)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48) AVLOS
				, SUM(LDLK)/SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK) AVLOSLK
				, SUM(LDPR)/SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR) AVLOSPR
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0 OR @JMLTT=0,0, ROUND(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48) / (@JMLTT),2)) BTO
				, IF(SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)=0 OR @JMLTT=0,0, ROUND(SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK) / (@JMLTT),2)) BTOLK
				, IF(SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)=0 OR @JMLTT=0,0, ROUND(SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR) / (@JMLTT),2)) BTOPR
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 ,ROUND(((@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)) - SUM(HP)) / (SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)),2)) TOI
				, IF(SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)=0, 0 ,ROUND(((@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)) - SUM(HPLK)) / (SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)),2)) TOILK
				, IF(SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)=0, 0 ,ROUND(((@JMLTT * (DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1)) - SUM(HPPR)) / (SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)),2)) TOIPR
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 , (SUM(MATILEBIH48)*1000)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)) NDR
				, IF(SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)=0, 0 , (SUM(MATILEBIH48LK)*1000)/SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)) NDRLK
				, IF(SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)=0, 0 , (SUM(MATILEBIH48PR)*1000)/SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)) NDRPR
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 , (SUM(MATI)*1000)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)) GDR
				, IF(SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)=0, 0 , (SUM(MATILK)*1000)/SUM(DIPINDAHKANLK+HIDUPLK+MATIKURANG48LK+MATILEBIH48LK)) GDRLK
				, IF(SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)=0, 0 , (SUM(MATIPR)*1000)/SUM(DIPINDAHKANPR+HIDUPPR+MATIKURANG48PR+MATILEBIH48PR)) GDRPR
				, (SELECT COUNT(pd.NOMOR) JUMLAH
						FROM pendaftaran.pendaftaran pd
							, pendaftaran.kunjungan tk
							, master.ruangan jkr
						WHERE pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN IN (1,2)
								AND tk.MASUK BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2))/(DATEDIFF(''',VTGLAKHIR2,''',''',VTGLAWAL2,''')+1) JMLKUNJUNGAN
										
		FROM  (
  				SELECT RAND() IDX, rlr.RL31
				  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) AWAL
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) AWALLK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) AWALPR
			     , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
			  FROM pendaftaran.kunjungan pk
				  , master.ruangan r
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			   AND DATE(pk.MASUK) < ''',VTGLAWAL,'''
				AND (DATE(pk.KELUAR) >= ''',VTGLAWAL,''' OR pk.KELUAR IS NULL)
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
			     , SUM(IF(pk.`STATUS` IN (1,2),1,0)) MASUK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) MASUKLK
			     , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
				FROM pendaftaran.pendaftaran pp
				     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
					, pendaftaran.tujuan_pasien tp
					  LEFT JOIN master.rl31_smf rlr ON tp.SMF=rlr.ID
					, master.ruangan r
					, pendaftaran.kunjungan pk
			  WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`=1 AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
			    AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
			    AND pk.MASUK BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,'''
	   	GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
				  , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR 
				  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) DIPINDAHKAN
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) DIPINDAHKANLK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
			  FROM pendaftaran.mutasi pm
			     , master.ruangan r
				  , pendaftaran.kunjungan pk
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM							    
			 WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`=2 AND pm.TUJUAN !=pk.RUANGAN AND pk.NOPEN=pp.NOMOR
			   AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2)
			   AND pm.TANGGAL BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,'''
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) PINDAHAN
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) PINDAHANLK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
			  FROM pendaftaran.kunjungan pk
				  , master.ruangan r
				  , pendaftaran.mutasi pm
				  , pendaftaran.kunjungan asal
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.REF IS NOT NULL AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			 	AND pk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND pk.RUANGAN !=asal.RUANGAN
			 	AND pk.MASUK BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,'''
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX,rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , SUM(IF(pp.CARA NOT IN (6,7),1,0)) HIDUP
				  , SUM(IF(pp.CARA NOT IN (6,7) AND p.JENIS_KELAMIN=1,1,0)) HIDUPLK
				  , SUM(IF(pp.CARA NOT IN (6,7) AND p.JENIS_KELAMIN!=1,1,0)) HIDUPPR
				  , SUM(IF(pp.CARA IN (6,7),1,0)) MATI
				  , SUM(IF(pp.CARA IN (6,7) AND p.JENIS_KELAMIN=1,1,0)) MATILK
				  , SUM(IF(pp.CARA IN (6,7) AND p.JENIS_KELAMIN!=1,1,0)) MATIPR
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48,1,0)) MATIKURANG48
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48 AND p.JENIS_KELAMIN=1,1,0)) MATIKURANG48LK
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48 AND p.JENIS_KELAMIN!=1,1,0)) MATIKURANG48PR
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48,1,0)) MATILEBIH48
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48 AND p.JENIS_KELAMIN=1,1,0)) MATILEBIH48LK
				  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48 AND p.JENIS_KELAMIN!=1,1,0)) MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
				FROM layanan.pasien_pulang pp
					, master.ruangan r
					, pendaftaran.kunjungan pk
					, pendaftaran.pendaftaran pd
					  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					  LEFT JOIN pendaftaran.tujuan_pasien ptp ON pd.NOMOR=ptp.NOPEN
				     LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				     LEFT JOIN master.pasien p ON pd.NORM=p.NORM
			  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
			    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS`=1
			    AND pk.KELUAR BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,'''
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , SUM(DATEDIFF(pk.KELUAR, pk.MASUK)) LD
				  , SUM(IF(p.JENIS_KELAMIN=1,DATEDIFF(pk.KELUAR, pk.MASUK),0)) LDLK
				  , SUM(IF(p.JENIS_KELAMIN!=1,DATEDIFF(pk.KELUAR, pk.MASUK),0)) LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
			  FROM pendaftaran.kunjungan pk
				  , master.ruangan r
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			    AND pk.KELUAR BETWEEN ''',VTGLAWAL2,''' AND ''',VTGLAKHIR2,'''
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR 
				  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) SISA
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) SISALK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) SISAPR
				  , 0 HP
				  , 0 HPLK
				  , 0 HPPR
				  , 0 VVIP
				  , 0 VVIPLK
				  , 0 VVIPPR
				  , 0 VIP
				  , 0 VIPLK
				  , 0 VIPPR
				  , 0 KLSI
				  , 0 KLSILK
				  , 0 KLSIPR
				  , 0 KLSII
				  , 0 KLSIILK
				  , 0 KLSIIPR
				  , 0 KLSIII
				  , 0 KLSIIILK
				  , 0 KLSIIIPR
				  , 0 KLSKHUSUS
				  , 0 KLSKHUSUSLK
				  , 0 KLSKHUSUSPR
			  FROM pendaftaran.kunjungan pk
				  , master.ruangan r
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			   AND DATE(pk.MASUK) < DATE_ADD(''',VTGLAKHIR,''',INTERVAL 1 DAY)
				AND (DATE(pk.KELUAR) > ''',VTGLAKHIR,''' OR pk.KELUAR IS NULL)
			GROUP BY rlr.RL31
			UNION
			SELECT RAND() IDX, rlr.RL31
			     , 0 AWAL
			     , 0 AWALLK
			     , 0 AWALPR
				  , 0 MASUK
			     , 0 MASUKLK
			     , 0 MASUKPR
				  , 0 PINDAHAN
				  , 0 PINDAHANLK
				  , 0 PINDAHANPR
				  , 0 DIPINDAHKAN
				  , 0 DIPINDAHKANLK
				  , 0 DIPINDAHKANPR
				  , 0 HIDUP
				  , 0 HIDUPLK
				  , 0 HIDUPPR
				  , 0 MATI
				  , 0 MATILK
				  , 0 MATIPR
				  , 0 MATIKURANG48
				  , 0 MATIKURANG48LK
				  , 0 MATIKURANG48PR
				  , 0 MATILEBIH48
				  , 0 MATILEBIH48LK
				  , 0 MATILEBIH48PR
				  , 0 LD
				  , 0 LDLK
				  , 0 LDPR
				  , 0 SISA
				  , 0 SISALK
				  , 0 SISAPR  
				  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) HP
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) HPLK
				  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) HPPR
				  , SUM(IF(mapkls.RL_KELAS=1,1,0)) VVIP
				  , SUM(IF(mapkls.RL_KELAS=1 AND p.JENIS_KELAMIN=1,1,0)) VVIPLK
				  , SUM(IF(mapkls.RL_KELAS=1 AND p.JENIS_KELAMIN!=1,1,0)) VVIPPR
				  , SUM(IF(mapkls.RL_KELAS=2,1,0)) VIP
				  , SUM(IF(mapkls.RL_KELAS=2 AND p.JENIS_KELAMIN=1,1,0)) VIPLK
				  , SUM(IF(mapkls.RL_KELAS=2 AND p.JENIS_KELAMIN!=1,1,0)) VIPPR
				  , SUM(IF(mapkls.RL_KELAS=3,1,0)) KLSI
				  , SUM(IF(mapkls.RL_KELAS=3 AND p.JENIS_KELAMIN=1,1,0)) KLSILK
				  , SUM(IF(mapkls.RL_KELAS=3 AND p.JENIS_KELAMIN!=1,1,0)) KLSIPR
				  , SUM(IF(mapkls.RL_KELAS=4,1,0)) KLSII
				  , SUM(IF(mapkls.RL_KELAS=4 AND p.JENIS_KELAMIN=1,1,0)) KLSIILK
				  , SUM(IF(mapkls.RL_KELAS=4 AND p.JENIS_KELAMIN!=1,1,0)) KLSIIPR
				  , SUM(IF(mapkls.RL_KELAS=5,1,0)) KLSIII
				  , SUM(IF(mapkls.RL_KELAS=5 AND p.JENIS_KELAMIN=1,1,0)) KLSIIILK
				  , SUM(IF(mapkls.RL_KELAS=5 AND p.JENIS_KELAMIN!=1,1,0)) KLSIIIPR
				  , SUM(IF(mapkls.RL_KELAS=6,1,0)) KLSKHUSUS
				  , SUM(IF(mapkls.RL_KELAS=6 AND p.JENIS_KELAMIN=1,1,0)) KLSKHUSUSLK
				  , SUM(IF(mapkls.RL_KELAS=6 AND p.JENIS_KELAMIN!=1,1,0)) KLSKHUSUSPR
			  FROM pendaftaran.kunjungan pk
			       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
				    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
					 LEFT JOIN master.kelas_simrs_rl mapkls ON rk.KELAS=mapkls.KELAS
				  , master.ruangan r
				  , pendaftaran.pendaftaran pp
				    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
				    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
				    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				  , (SELECT TANGGAL TGL
						  FROM master.tanggal 
						 WHERE TANGGAL BETWEEN ''',VTGLAWAL,''' AND ''',VTGLAKHIR,''') bts
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			   AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
				AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
			) rl31 
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	IF NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl1-2` WHERE tahun = PTAHUN) THEN
		INSERT INTO `kemkes-sirs`.`rl1-2`(tahun, bor, los, bto, toi, ndr, gdr, ratakunjungan)
		SELECT TAHUN
					, CAST(IFNULL(BOR, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(AVLOS, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(BTO, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(TOI, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(NDR, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(GDR, 0) AS DECIMAL(10,2))
					, CAST(IFNULL(JMLKUNJUNGAN, 0) AS DECIMAL(10,2))
		  FROM TEMP_LAPORAN_RL12;
	ELSE
		UPDATE `kemkes-sirs`.`rl1-2` r, TEMP_LAPORAN_RL12 t
			SET r.bor = CAST(IFNULL(t.BOR, 0) AS DECIMAL(10,2)),
				 r.los = CAST(IFNULL(t.AVLOS, 0) AS DECIMAL(10,2)),
				 r.bto = CAST(IFNULL(t.BTO, 0) AS DECIMAL(10,2)),
				 r.toi = CAST(IFNULL(t.TOI, 0) AS DECIMAL(10,2)),
				 r.ndr = CAST(IFNULL(t.NDR, 0) AS DECIMAL(10,2)),
				 r.gdr = CAST(IFNULL(t.GDR, 0) AS DECIMAL(10,2)),
				 r.ratakunjungan = CAST(IFNULL(t.JMLKUNJUNGAN, 0) AS DECIMAL(10,2))
		 WHERE r.tahun = t.TAHUN;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
