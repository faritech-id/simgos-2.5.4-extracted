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
USE `kemkes-sirs`;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL31
DROP PROCEDURE IF EXISTS `ambilDataRL31`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL31`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE vTGLAWAL DATE;
	DECLARE vTGLAKHIR DATE;
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	SET vTGLAWAL = CONCAT(PTAHUN, '-01-01');
	SET vTGLAKHIR = CONCAT(PTAHUN, '-12-31');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL31;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL31 ENGINE=MEMORY
		SELECT INST.*, PTAHUN TAHUN, rl.ID, rl.KODE, rl.DESKRIPSI
				, SUM(AWAL) AWAL, SUM(AWALLK) AWALLK, SUM(AWALPR) AWALPR
				, SUM(MASUK) MASUK, SUM(MASUKLK) MASUKLK, SUM(MASUKPR) MASUKPR
				, SUM(PINDAHAN) PINDAHAN, SUM(PINDAHANLK) PINDAHANLK, SUM(PINDAHANPR) PINDAHANPR
				, SUM(DIPINDAHKAN) DIPINDAHKAN, SUM(DIPINDAHKANLK) DIPINDAHKANLK, SUM(DIPINDAHKANPR) DIPINDAHKANPR
				, SUM(HIDUP) HIDUP, SUM(HIDUPLK) HIDUPLK, SUM(HIDUPPR) HIDUPPR
				, SUM(MATI) MATI, SUM(MATILK) MATILK, SUM(MATIPR) MATIPR
				, SUM(MATIKURANG48) MATIKURANG48, SUM(MATIKURANG48LK) MATIKURANG48LK, SUM(MATIKURANG48PR) MATIKURANG48PR
				, SUM(MATILEBIH48) MATILEBIH48, SUM(MATILEBIH48LK) MATILEBIH48LK, SUM(MATILEBIH48PR) MATILEBIH48PR
				, SUM(LD) LD, SUM(LDLK) LDLK, SUM(LDPR) LDPR
				, SUM(SISA) SISA, SUM(SISALK) SISALK, SUM(SISAPR) SISAPR
				, SUM(HP) HP, SUM(HPLK) HPLK, SUM(HPPR) HPPR
				, SUM(VVIP) VVIP, SUM(VVIPLK) VVIPLK, SUM(VVIPPR) VVIPPR
				, SUM(VIP) VIP, SUM(VIPLK) VIPLK, SUM(VIPPR) VIPPR
				, SUM(KLSI) KLSI, SUM(KLSILK) KLSILK, SUM(KLSIPR) KLSIPR
				, SUM(KLSII) KLSII, SUM(KLSIILK) KLSIILK, SUM(KLSIIPR) KLSIIPR
				, SUM(KLSIII) KLSIII, SUM(KLSIIILK) KLSIIILK, SUM(KLSIIIPR) KLSIIIPR
				, SUM(KLSKHUSUS) KLSKHUSUS, SUM(KLSKHUSUSLK) KLSKHUSUSLK, SUM(KLSKHUSUSPR) KLSKHUSUSPR
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (
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
			   AND DATE(pk.MASUK) < vTGLAWAL
				AND (DATE(pk.KELUAR) >= vTGLAWAL OR pk.KELUAR IS NULL)
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
			  WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
			    AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
			    AND pk.MASUK BETWEEN TGLAWAL AND TGLAKHIR
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
			   AND pm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
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
			 	AND pk.MASUK BETWEEN TGLAWAL AND TGLAKHIR
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
			    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS`!=0
			    AND pk.KELUAR BETWEEN TGLAWAL AND TGLAKHIR
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
			    AND pk.KELUAR BETWEEN TGLAWAL AND TGLAKHIR
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
			   AND DATE(pk.MASUK) < DATE_ADD(vTGLAKHIR,INTERVAL 1 DAY)
				AND (DATE(pk.KELUAR) > vTGLAKHIR OR pk.KELUAR IS NULL)
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
						 WHERE TANGGAL BETWEEN vTGLAWAL AND vTGLAKHIR) bts
			 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
			   AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
				AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
			GROUP BY rlr.RL31) rl31 ON rl31.RL31=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=1
		GROUP BY rl.ID
		ORDER BY rl.ID;
		

	INSERT INTO `kemkes-sirs`.`rl3-1`(tahun, `no`, jenis_pelayanan, pasien_awal_tahun, pasien_masuk, pasien_keluar_hidup
	, kurang_48_jam, lebih_48_jam, jumlah_lama_dirawat, pasien_akhir_tahun, jumlah_hari_perawatan, vvip, vip, i, ii, iii, kelas_khusus)
	SELECT PTAHUN TAHUN, KODE, DESKRIPSI
			, IFNULL(AWAL, 0)
			, IFNULL(MASUK+PINDAHAN, 0)
			, IFNULL(HIDUP+DIPINDAHKAN, 0)
			, IFNULL(MATIKURANG48, 0)
			, IFNULL(MATILEBIH48, 0)
			, IFNULL(LD, 0)
			, IFNULL(SISA, 0)
			, IFNULL(HP, 0)
			, IFNULL(VVIP, 0)
			, IFNULL(VIP, 0)
			, IFNULL(KLSI, 0)
			, IFNULL(KLSII, 0)
			, IFNULL(KLSIII, 0)
			, IFNULL(KLSKHUSUS, 0)
	  FROM TEMP_LAPORAN_RL31 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-1` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-1` r, TEMP_LAPORAN_RL31 t
	  SET r.pasien_awal_tahun = IFNULL(t.AWAL, 0),
		   r.pasien_masuk = IFNULL(t.MASUK, 0),
		 	r.pasien_keluar_hidup = IFNULL(t.HIDUP, 0),
			r.kurang_48_jam = IFNULL(t.MATIKURANG48, 0),
			r.lebih_48_jam = IFNULL(t.MATILEBIH48, 0),
			r.jumlah_lama_dirawat = IFNULL(t.LD, 0),
			r.pasien_akhir_tahun = IFNULL(t.SISA, 0),
			r.jumlah_hari_perawatan = IFNULL(t.HP, 0),
			r.vvip = IFNULL(t.VVIP, 0),
			r.vip = IFNULL(t.VIP, 0),
			r.i = IFNULL(t.KLSI, 0),
			r.ii = IFNULL(t.KLSII, 0),
			r.iii = IFNULL(t.KLSIII, 0),
			r.kelas_khusus = IFNULL(t.KLSKHUSUS, 0)
	WHERE r.tahun = t.TAHUN 
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk trigger kemkes-sirs.rl3-1_before_update
DROP TRIGGER IF EXISTS `rl3-1_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl3-1_before_update` BEFORE UPDATE ON `rl3-1` FOR EACH ROW BEGIN
	IF NEW.pasien_awal_tahun != OLD.pasien_awal_tahun
		OR NEW.pasien_masuk != OLD.pasien_masuk
		OR NEW.pasien_keluar_hidup != OLD.pasien_keluar_hidup
		OR NEW.kurang_48_jam != OLD.kurang_48_jam
		OR NEW.jumlah_lama_dirawat != OLD.jumlah_lama_dirawat
		OR NEW.pasien_akhir_tahun != OLD.pasien_akhir_tahun 
		OR NEW.jumlah_hari_perawatan != OLD.jumlah_hari_perawatan
		OR NEW.vvip != OLD.vvip 
		OR NEW.vip != OLD.vip
		OR NEW.i != OLD.i
		OR NEW.ii != OLD.ii
		OR NEW.iii != OLD.iii
		OR NEW.kelas_khusus != OLD.kelas_khusus THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
