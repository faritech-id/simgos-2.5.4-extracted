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

-- membuang struktur untuk procedure laporan.LaporanKegiatanRawatInapPerKelas
DROP PROCEDURE IF EXISTS `LaporanKegiatanRawatInapPerKelas`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanKegiatanRawatInapPerKelas`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `CARAKELUAR` TINYINT, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT)
BEGIN
 
 DECLARE vTGLAWAL DATE;
 DECLARE vTGLAKHIR DATE;
 DECLARE vRUANGAN VARCHAR(11);
  
 SET vRUANGAN = CONCAT(RUANGAN,'%');     
 SET vTGLAWAL = DATE(TGLAWAL);
 SET vTGLAKHIR = DATE(TGLAKHIR);
 
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST
	  , IF(''',RUANGAN,'''='''' OR LENGTH(''',RUANGAN,''')<5	
				, IF(mr.JENIS=2, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
				, IF(mr.JENIS=3, CONCAT(SPACE(mr.JENIS*2), mr.DESKRIPSI)
				, IF(mr.JENIS=4, CONCAT(SPACE(mr.JENIS*3), mr.DESKRIPSI)
				, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*4), mr.DESKRIPSI)
				, mr.DESKRIPSI))))
			, IF(LENGTH(''',RUANGAN,''')<7
				, IF(mr.JENIS=4, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
				, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*2), mr.DESKRIPSI)
				, mr.DESKRIPSI))
			, IF(LENGTH(''',RUANGAN,''')<9
				, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
				, mr.DESKRIPSI)
			, mr.DESKRIPSI))) RUANGAN
	  , kls.ID IDKELAS, kls.DESKRIPSI KELAS
	  , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
	  , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER 
	  , mr.ID IDRUANG, mr.DESKRIPSI RUANG
	  , SUM(AWAL) AWAL
	  , SUM(MASUK) MASUK
	  , SUM(PINDAHAN) PINDAHAN
	  , SUM(DIPINDAHKAN) DIPINDAHKAN
	  , SUM(HIDUP) HIDUP
	  , SUM(MATI) MATI
	  , SUM(MATIKURANG48) MATIKURANG48
	  , SUM(MATILEBIH48) MATILEBIH48
	  , SUM(LD) LD
	  , SUM(SISA) SISA
	  , SUM(HP) HP
  FROM master.ruangan mr
     , master.ruang_kamar mrk
       LEFT JOIN master.referensi kls ON mrk.KELAS = kls.ID AND kls.JENIS=19 AND kls.STATUS!=0
		 LEFT JOIN (
		 				SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND DATE(pk.MASUK) < ''',vTGLAWAL,'''
							AND (DATE(pk.KELUAR) >= ''',vTGLAWAL,''' OR pk.KELUAR IS NULL)
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, tp.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						        LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
						  WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS` IN (1,2) AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
						    AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
						    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						    AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				   	GROUP BY tp.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`=2 AND pm.TUJUAN !=pk.RUANGAN AND pk.NOPEN=pp.NOMOR
						   AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2)
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , master.ruangan r
							  , pendaftaran.mutasi pm
							  , pendaftaran.kunjungan asal
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.REF IS NOT NULL AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						 	AND pk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND pk.RUANGAN !=asal.RUANGAN
						 	AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						 	',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX,pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						        LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
								, pendaftaran.pendaftaran pd
								  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
						  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
						    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS` IN (1,2)
						    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						    AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
  						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND DATE(pk.MASUK) < DATE_ADD(''',vTGLAKHIR,''',INTERVAL 1 DAY)
							AND (DATE(pk.KELUAR) > ''',vTGLAKHIR,''' OR pk.KELUAR IS NULL)
						GROUP BY pk.RUANGAN, kelas.ID
						UNION
						SELECT RAND() IDX, pk.RUANGAN, kelas.ID IDKELAS, kelas.DESKRIPSI KELAS
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
						    	 LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  , (SELECT TANGGAL TGL
									  FROM master.tanggal 
									 WHERE TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''') bts
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
							AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
						GROUP BY pk.RUANGAN, kelas.ID
						) b ON b.RUANGAN=mrk.RUANGAN AND b.IDKELAS=mrk.KELAS
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE mr.ID LIKE ''',vRUANGAN,''' AND mr.JENIS_KUNJUNGAN=3 AND mr.JENIS_KUNJUNGAN=''',LAPORAN,''' AND mr.ID=mrk.RUANGAN AND mrk.status!=0
	GROUP BY mr.ID, kls.ID
	ORDER BY mr.ID, kls.ID
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
