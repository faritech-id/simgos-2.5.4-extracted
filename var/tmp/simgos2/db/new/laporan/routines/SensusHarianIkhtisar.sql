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

-- membuang struktur untuk procedure laporan.SensusHarianIkhtisar
DROP PROCEDURE IF EXISTS `SensusHarianIkhtisar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `SensusHarianIkhtisar`(IN `TGLAWAL` DATETIME, IN `RUANGAN` CHAR(10))
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  DECLARE vTGLAWAL DATETIME;
  DECLARE vTGLAKHIR DATETIME;
  DECLARE vTGL DATE;
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  SET vTGLAWAL = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 00:00:00'),'%Y-%m-%d %H:%i:%s');
  SET vTGLAKHIR = STR_TO_DATE(CONCAT(DATE(TGLAWAL),' 23:59:59'),'%Y-%m-%d %H:%i:%s');
  SET vTGL = DATE(TGLAWAL);
  
 SET @sqlText = CONCAT('
SELECT IDX, RUANGAN, DESKRIPSI keadaan, sh.ID idkeadaan
		, IF(sh.ID IN (1,2,3),1,IF(sh.ID IN (4,5,6),2,3)) groupkeadaan
		, IF(sh.ID IN (1,2,3),''JUMLAH (A+B+C) (I)'',IF(sh.ID IN (4,5,6),''JUMLAH (D+E+F) (II)'',''RINCIAN HARI PERAWATAN'')) groupket
		, SUM(TOTAL) TOTAL
		, SUM(VVIPUMUM) VVIPUMUM
		, SUM(VVIPJKN) VVIPJKN
		, SUM(VVIPJKD) VVIPJKD
		, SUM(VVIPIKS) VVIPIKS
		, SUM(VIPUMUM) VIPUMUM
		, SUM(VIPJKN) VIPJKN
		, SUM(VIPJKD) VIPJKD
		, SUM(VIPIKS) VIPIKS
		, SUM(KLS1UMUM) KLS1UMUM
		, SUM(KLS1JKN) KLS1JKN
		, SUM(KLS1JKD) KLS1JKD
		, SUM(KLS1IKS) KLS1IKS
		, SUM(KLS2UMUM) KLS2UMUM
		, SUM(KLS2JKN) KLS2JKN
		, SUM(KLS2JKD) KLS2JKD
		, SUM(KLS2IKS) KLS2IKS
		, SUM(HCUUMUM) HCUUMUM
		, SUM(HCUJKN) HCUJKN
		, SUM(HCUJKD) HCUJKD
		, SUM(HCUIKS) HCUIKS
		, SUM(KLS3UMUM) KLS3UMUM
		, SUM(KLS3JKN) KLS3JKN
		, SUM(KLS3JKD) KLS3JKD
		, SUM(KLS3IKS) KLS3IKS
		, IF(sh.ID IN (1,2,3),SUM(TOTAL),IF(sh.ID IN (4,5,6),-SUM(TOTAL),0)) TOTALSUB
		, IF(sh.ID IN (1,2,3),SUM(VVIPUMUM),IF(sh.ID IN (4,5,6),-SUM(VVIPUMUM),0)) TOTALSUBVVIPUMUM
		, IF(sh.ID IN (1,2,3),SUM(VVIPJKN),IF(sh.ID IN (4,5,6),-SUM(VVIPJKN),0)) TOTALSUBVVIPJKN
		, IF(sh.ID IN (1,2,3),SUM(VVIPIKS),IF(sh.ID IN (4,5,6),-SUM(VVIPIKS),0)) TOTALSUBVVIPIKS
		, IF(sh.ID IN (1,2,3),SUM(VIPUMUM),IF(sh.ID IN (4,5,6),-SUM(VIPUMUM),0)) TOTALSUBVIPUMUM
		, IF(sh.ID IN (1,2,3),SUM(VIPJKN),IF(sh.ID IN (4,5,6),-SUM(VIPJKN),0)) TOTALSUBVIPJKN
		, IF(sh.ID IN (1,2,3),SUM(VIPIKS),IF(sh.ID IN (4,5,6),-SUM(VIPIKS),0)) TOTALSUBVIPIKS
		, IF(sh.ID IN (1,2,3),SUM(KLS1UMUM),IF(sh.ID IN (4,5,6),-SUM(KLS1UMUM),0)) TOTALSUBKLS1UMUM
		, IF(sh.ID IN (1,2,3),SUM(KLS1JKN),IF(sh.ID IN (4,5,6),-SUM(KLS1JKN),0)) TOTALSUBKLS1JKN
		, IF(sh.ID IN (1,2,3),SUM(KLS1IKS),IF(sh.ID IN (4,5,6),-SUM(KLS1IKS),0)) TOTALSUBKLS1IKS
		, IF(sh.ID IN (1,2,3),SUM(KLS2UMUM),IF(sh.ID IN (4,5,6),-SUM(KLS2UMUM),0)) TOTALSUBKLS2UMUM
		, IF(sh.ID IN (1,2,3),SUM(KLS2JKN),IF(sh.ID IN (4,5,6),-SUM(KLS2JKN),0)) TOTALSUBKLS2JKN
		, IF(sh.ID IN (1,2,3),SUM(KLS2JKD),IF(sh.ID IN (4,5,6),-SUM(KLS2JKD),0)) TOTALSUBKLS2JKD
		, IF(sh.ID IN (1,2,3),SUM(KLS2IKS),IF(sh.ID IN (4,5,6),-SUM(KLS2IKS),0)) TOTALSUBKLS2IKS
		, IF(sh.ID IN (1,2,3),SUM(HCUUMUM),IF(sh.ID IN (4,5,6),-SUM(HCUUMUM),0)) TOTALSUBHCUUMUM
		, IF(sh.ID IN (1,2,3),SUM(HCUJKN),IF(sh.ID IN (4,5,6),-SUM(HCUJKN),0)) TOTALSUBHCUJKN
		, IF(sh.ID IN (1,2,3),SUM(HCUJKD),IF(sh.ID IN (4,5,6),-SUM(HCUJKD),0)) TOTALSUBHCUJKD
		, IF(sh.ID IN (1,2,3),SUM(HCUIKS),IF(sh.ID IN (4,5,6),-SUM(HCUIKS),0)) TOTALSUBHCUIKS
		, IF(sh.ID IN (1,2,3),SUM(KLS3UMUM),IF(sh.ID IN (4,5,6),-SUM(KLS3UMUM),0)) TOTALSUBKLS3UMUM
		, IF(sh.ID IN (1,2,3),SUM(KLS3JKN),IF(sh.ID IN (4,5,6),-SUM(KLS3JKN),0)) TOTALSUBKLS3JKN
		, IF(sh.ID IN (1,2,3),SUM(KLS3JKD),IF(sh.ID IN (4,5,6),-SUM(KLS3JKD),0)) TOTALSUBKLS3JKD
		, IF(sh.ID IN (1,2,3),SUM(KLS3IKS),IF(sh.ID IN (4,5,6),-SUM(KLS3IKS),0)) TOTALSUBKLS3IKS
	 FROM master.referensi sh
	 LEFT JOIN  (
SELECT RAND() IDX, pk.RUANGAN
		,''A. SISA PENDERITA KEMARIN'' keadaan, 1 AS idkeadaan,1 AS groupkeadaan
		, ''JUMLAH (A+B+C) (I)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS
  FROM pendaftaran.kunjungan pk
       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
	    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	    LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
	  , master.ruangan r
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	    LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
   AND DATE(pk.MASUK) < ''',vTGL,'''
	AND (DATE(pk.KELUAR) >= ''',vTGL,''' OR pk.KELUAR IS NULL)
GROUP BY pk.RUANGAN
UNION
SELECT RAND() IDX, tp.RUANGAN
		, ''B. PENDERITA MASUK'' keadaan, 2 AS idkeadaan,1 AS groupkeadaan
		, ''JUMLAH (A+B+C) (I)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS
	FROM pendaftaran.pendaftaran pp
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	     LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
		, pendaftaran.tujuan_pasien tp
		, master.ruangan r
		, pendaftaran.kunjungan pk
		  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
	     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
	WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`IN (1,2) AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
	 AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
	 AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
	 AND pk.MASUK BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,'''
GROUP BY tp.RUANGAN
UNION
SELECT RAND() IDX, pk.RUANGAN
		, ''C. PENDERITA PINDAHAN'' keadaan, 3 AS idkeadaan,1 AS groupkeadaan
		 , ''JUMLAH (A+B+C) (I)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS
  FROM pendaftaran.kunjungan pk
       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
	    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	    LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
	  , master.ruangan r
	  , pendaftaran.mutasi pm
	  , pendaftaran.kunjungan asal
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	    LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.REF IS NOT NULL AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
 	AND pk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND pk.RUANGAN !=asal.RUANGAN
 	AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
  AND pk.MASUK BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,'''
GROUP BY pk.RUANGAN
UNION
SELECT RAND() IDX, pk.RUANGAN
		, ''D. PENDERITA KELUAR'' keadaan, 4 AS idkeadaan,2 AS groupkeadaan
		, ''JUMLAH (D+E+F) (II)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS
	FROM layanan.pasien_pulang pp
		, master.ruangan r
		, pendaftaran.kunjungan pk
		  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
	     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	     LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS` IN (1,2)
    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND pp.CARA NOT IN (6,7)
    AND pk.KELUAR BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''' AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
GROUP BY pk.RUANGAN
UNION
SELECT RAND() IDX, pk.RUANGAN
		, ''E. PENDERITA MENINGGAL'' keadaan, 5 AS idkeadaan, 2 AS groupkeadaan
		 , ''JUMLAH (D+E+F) (II)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS
	FROM layanan.pasien_pulang pp
		, master.ruangan r
		, pendaftaran.kunjungan pk
		  LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
	     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	     LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS` IN (1,2)
    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND pp.CARA IN (6,7)
    AND pk.KELUAR BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''' AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
GROUP BY pk.RUANGAN
UNION
SELECT RAND() IDX, pk.RUANGAN
		, ''F. PENDERITA DIPINDAHKAN'' keadaan, 6 AS idkeadaan, 2 AS groupkeadaan
		 , ''JUMLAH (D+E+F) (II)'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS

 FROM pendaftaran.mutasi pm
     , master.ruangan r
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
       LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
       LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	    LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
 WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`=2 AND pm.TUJUAN !=pk.RUANGAN AND pk.NOPEN=pp.NOMOR
   AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2)
   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
   AND pm.TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,'''
GROUP BY pk.RUANGAN
UNION
SELECT RAND() IDX, pk.RUANGAN
		, ''RINCIAN HARI PERAWATAN'' keadaan, 7 AS idkeadaan, 3 AS groupkeadaan
		 , ''RINCIAN HARI PERAWATAN'' AS	groupket
		, SUM(IF(pk.`STATUS` IN (1,2),1,0)) TOTAL
		, SUM(IF(kelas.ID=5 AND ref.ID=1,1,0)) VVIPUMUM
		, SUM(IF(kelas.ID=5 AND ref.ID=2,1,0)) VVIPJKN
		, SUM(IF(kelas.ID=5 AND ref.ID=4,1,0)) VVIPJKD
		, SUM(IF(kelas.ID=5 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VVIPIKS
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=1,1,0)) VIPUMUM
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=2,1,0)) VIPJKN
		, SUM(IF(kelas.ID IN (4,9) AND ref.ID=4,1,0)) VIPJKD
		, SUM(IF(kelas.ID IN (4,9) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) VIPIKS
		, SUM(IF(kelas.ID=3 AND ref.ID=1,1,0)) KLS1UMUM
		, SUM(IF(kelas.ID=3 AND ref.ID=2,1,0)) KLS1JKN
		, SUM(IF(kelas.ID=3 AND ref.ID=4,1,0)) KLS1JKD
		, SUM(IF(kelas.ID=3 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS1IKS
		, SUM(IF(kelas.ID=2 AND ref.ID=1,1,0)) KLS2UMUM
		, SUM(IF(kelas.ID=2 AND ref.ID=2,1,0)) KLS2JKN
		, SUM(IF(kelas.ID=2 AND ref.ID=4,1,0)) KLS2JKD
		, SUM(IF(kelas.ID=2 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS2IKS
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=1,1,0)) HCUUMUM
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=2,1,0)) HCUJKN
		, SUM(IF(kelas.ID IN (6,7,8) AND ref.ID=4,1,0)) HCUJKD
		, SUM(IF(kelas.ID IN (6,7,8) AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) HCUIKS
		, SUM(IF(kelas.ID=1 AND ref.ID=1,1,0)) KLS3UMUM
		, SUM(IF(kelas.ID=1 AND ref.ID=2,1,0)) KLS3JKN
		, SUM(IF(kelas.ID=1 AND ref.ID=4,1,0)) KLS3JKD
		, SUM(IF(kelas.ID=1 AND (iks.ID IS NOT NULL OR ref.ID=3),1,0)) KLS3IKS

 FROM pendaftaran.kunjungan pk
      LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
      LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
      LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
  , master.ruangan r
  , pendaftaran.pendaftaran pp
    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	 LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
  , (SELECT TANGGAL TGL
		  FROM master.tanggal
		 WHERE TANGGAL BETWEEN ''',vTGL,''' AND ''',vTGL,''') bts
WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.STATUS IN (1,2) AND pk.NOPEN=pp.NOMOR
	AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=3 AND INSTR(rkt.TEMPAT_TIDUR,''Bayi'')=0
	AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
	AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
GROUP BY pk.RUANGAN
) b ON sh.ID=b.idkeadaan
WHERE sh.JENIS=61
GROUP BY sh.ID
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
