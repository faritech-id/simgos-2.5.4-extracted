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

-- membuang struktur untuk procedure laporan.LaporanRL31
DROP PROCEDURE IF EXISTS `LaporanRL31`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanRL31`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME

)
BEGIN	

	
	 DECLARE vTGLAWAL DATE;
	 DECLARE vTGLAKHIR DATE;
	 DECLARE TAHUN INT;
      
    SET TAHUN = DATE_FORMAT(TGLAKHIR,'%Y');
	 SET vTGLAWAL = DATE(TGLAWAL);
	 SET vTGLAKHIR = DATE(TGLAKHIR);
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ''',TAHUN,''' TAHUN, rl.ID, rl.KODE, rl.DESKRIPSI
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
						   AND DATE(pk.MASUK) < ''',vTGLAWAL,'''
							AND (DATE(pk.KELUAR) >= ''',vTGLAWAL,''' OR pk.KELUAR IS NULL)
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
						    AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
						   AND pm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
						 	AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
						    AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
						    AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
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
						   AND DATE(pk.MASUK) < DATE_ADD(''',vTGLAKHIR,''',INTERVAL 1 DAY)
							AND (DATE(pk.KELUAR) > ''',vTGLAKHIR,''' OR pk.KELUAR IS NULL)
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
									 WHERE TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''') bts
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
		  AND jrl.JENIS=''100103'' AND jrl.ID=1
		GROUP BY rl.ID
		ORDER BY rl.ID');
			

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
