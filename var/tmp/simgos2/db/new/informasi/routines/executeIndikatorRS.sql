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

-- membuang struktur untuk procedure informasi.executeIndikatorRS
DROP PROCEDURE IF EXISTS `executeIndikatorRS`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeIndikatorRS`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
	DECLARE VTGL_AKHIR DATETIME;
		
	SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
	SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
	
	BEGIN		
		DECLARE VTANGGAL DATE;
		DECLARE VAWAL, VMASUK, VPINDAHAN, VKURANG48JAM, VLEBIH48JAM
		  		  , VLD, VSISA, VTTIDUR, VHP, VDIPINDAHKAN, VJMLKLR, VJMLHARI INT;
		DECLARE VLASTUPDATED DATETIME;
		
		DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
		DECLARE CR_EXEC CURSOR FOR SELECT mt.TANGGAL
				  , SUM(AWAL) 
				  , SUM(MASUK) 
				  , SUM(PINDAHAN) 
				  , SUM(MATIKURANG48) 
				  , SUM(MATILEBIH48) 
				  , SUM(LD) 
				  , SUM(SISA) 
				  , (SELECT COUNT(TEMPAT_TIDUR) FROM master.ruang_kamar_tidur WHERE STATUS!=0) TTIDUR
				  , SUM(HP) HP
				  , SUM(DIPINDAHKAN) 
				  , SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48) 
				  , (DATEDIFF(TANGGAL,TANGGAL)+1)
				  , NOW()
			  FROM master.tanggal mt
					 LEFT JOIN (
					 				SELECT RAND() IDX, bts.TGL
					 					  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) AWAL
									     , 0 MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , 0 SISA
										  , 0 HP
									  FROM pendaftaran.kunjungan pk
									       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										  , master.ruangan r
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										, (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
									   AND DATE(pk.MASUK) < bts.TGL
										AND (DATE(pk.KELUAR) >= bts.TGL OR pk.KELUAR IS NULL)
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
									     , SUM(IF(pk.`STATUS` IN (1,2),1,0)) MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , 0 SISA
										  , 0 HP
										FROM pendaftaran.pendaftaran pp
										     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
											, pendaftaran.tujuan_pasien tp
											, master.ruangan r
											, pendaftaran.kunjungan pk
											  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
											, (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									  WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS` IN (1,2) AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
									    AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
									    AND pk.MASUK BETWEEN CONCAT(bts.TGL,' 00:00:00') AND CONCAT(bts.TGL,' 23:59:59')
							   	GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
										  , 0 AWAL
										  , 0 MASUK
										  , 0 PINDAHAN
										  , COUNT(pk.NOMOR) DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , 0 SISA
										  , 0 HP
									  FROM pendaftaran.mutasi pm
									     , master.ruangan r
										  , pendaftaran.kunjungan pk
										    LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										 , (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`=2 AND pm.TUJUAN !=pk.RUANGAN AND pk.NOPEN=pp.NOMOR
									   AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2)
									   AND pm.TANGGAL BETWEEN CONCAT(bts.TGL,' 00:00:00') AND CONCAT(bts.TGL,' 23:59:59')
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
										  , 0 MASUK
										  , COUNT(pk.NOMOR) PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , 0 SISA
										  , 0 HP
									  FROM pendaftaran.kunjungan pk
									       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										  , master.ruangan r
										  , pendaftaran.mutasi pm
										  , pendaftaran.kunjungan asal
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										  , (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.REF IS NOT NULL AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
									 	AND pk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND pk.RUANGAN !=asal.RUANGAN
									 	AND pk.MASUK BETWEEN CONCAT(bts.TGL,' 00:00:00') AND CONCAT(bts.TGL,' 23:59:59')
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
										  , 0 MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , SUM(IF(pp.CARA NOT IN (6,7),1,0)) HIDUP
										  , SUM(IF(pp.CARA IN (6,7),1,0)) MATI
										  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48,1,0)) MATIKURANG48
										  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48,1,0)) MATILEBIH48
										  , 0 LD
										  , 0 SISA
										  , 0 HP
										FROM layanan.pasien_pulang pp
											, master.ruangan r
											, pendaftaran.kunjungan pk
											  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
											, pendaftaran.pendaftaran pd
											  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
											, (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
									    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS` IN (1,2)
									    AND pk.KELUAR BETWEEN CONCAT(bts.TGL,' 00:00:00') AND CONCAT(bts.TGL,' 23:59:59')
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
										  , 0 MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , SUM(DATEDIFF(pk.KELUAR, pk.MASUK)) LD
										  , 0 SISA
										  , 0 HP
									  FROM pendaftaran.kunjungan pk
									      LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										  , master.ruangan r
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										  , (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
									   AND pk.KELUAR BETWEEN CONCAT(bts.TGL,' 00:00:00') AND CONCAT(bts.TGL,' 23:59:59')
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
										  , 0 MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) SISA
										  , 0 HP
									  FROM pendaftaran.kunjungan pk
									       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
										  , master.ruangan r
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										  , (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
									  AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
										AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
									GROUP BY bts.TGL
									UNION
									SELECT RAND() IDX, bts.TGL
									     , 0 AWAL
										  , 0 MASUK
										  , 0 PINDAHAN
										  , 0 DIPINDAHKAN
										  , 0 HIDUP
										  , 0 MATI
										  , 0 MATIKURANG48
										  , 0 MATILEBIH48
										  , 0 LD
										  , 0 SISA
										   , SUM(IF(pk.`STATUS` IN (1,2),1,0)) HP
									  FROM pendaftaran.kunjungan pk
									       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
										  , master.ruangan r
										  , pendaftaran.pendaftaran pp
										    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
										  , (SELECT TANGGAL TGL
												  FROM master.tanggal 
												 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts
									 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
									  AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
										AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
									GROUP BY bts.TGL
									) b ON b.TGL=mt.TANGGAL
				
				WHERE mt.TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
			   GROUP BY mt.TANGGAL;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
		OPEN CR_EXEC;
						
		EXIT_EXEC: LOOP
			FETCH CR_EXEC INTO VTANGGAL, VAWAL, VMASUK, VPINDAHAN, VKURANG48JAM, VLEBIH48JAM, VLD, VSISA, VTTIDUR, VHP, VDIPINDAHKAN, VJMLKLR, VJMLHARI, VLASTUPDATED;
							
			IF EXEC_NOT_FOUND THEN
				LEAVE EXIT_EXEC;
			END IF;
			
			SET VAWAL = IFNULL(VAWAL, 0);
			SET VMASUK = IFNULL(VMASUK, 0);
			SET VPINDAHAN = IFNULL(VPINDAHAN, 0);
			SET VKURANG48JAM = IFNULL(VKURANG48JAM, 0);
			SET VLEBIH48JAM = IFNULL(VLEBIH48JAM, 0);
			SET VLD = IFNULL(VLD, 0);
			SET VSISA = IFNULL(VSISA, 0);
			SET VTTIDUR = IFNULL(VTTIDUR, 0);
			SET VHP = IFNULL(VHP, 0);
			SET VDIPINDAHKAN = IFNULL(VDIPINDAHKAN, 0);
			SET VJMLKLR = IFNULL(VJMLKLR, 0);
			SET VJMLHARI = IFNULL(VJMLHARI, 0);
			
			IF EXISTS(SELECT 1 
					FROM informasi.indikator_rs 
				  WHERE TANGGAL = VTANGGAL) THEN
				UPDATE informasi.indikator_rs
				   SET AWAL = VAWAL
						 , MASUK = VMASUK
						 , PINDAHAN = VPINDAHAN
						 , KURANG48JAM = VKURANG48JAM
						 , LEBIH48JAM = VLEBIH48JAM
						 , LD = VLD
						 , SISA = VSISA
						 , TTIDUR = VTTIDUR
						 , HP = VHP
						 , DIPINDAHKAN = VDIPINDAHKAN
						 , JMLKLR = VJMLKLR
						 , JMLHARI = VJMLHARI
						 , LASTUPDATED = VLASTUPDATED
				  WHERE TANGGAL = VTANGGAL;
			ELSE
				INSERT INTO informasi.indikator_rs(TANGGAL, AWAL, MASUK, PINDAHAN, KURANG48JAM, LEBIH48JAM, LD, SISA, TTIDUR, HP, DIPINDAHKAN, JMLKLR, JMLHARI, LASTUPDATED)
					  VALUES (VTANGGAL, VAWAL, VMASUK, VPINDAHAN, VKURANG48JAM, VLEBIH48JAM, VLD, VSISA, VTTIDUR, VHP, VDIPINDAHKAN, VJMLKLR, VJMLHARI, VLASTUPDATED);
			END IF;
		END LOOP;
		
		CLOSE CR_EXEC;
	END;		
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
