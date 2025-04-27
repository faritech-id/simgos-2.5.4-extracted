-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanPerSeverity
DROP PROCEDURE IF EXISTS `LaporanPerSeverity`;
DELIMITER //
CREATE PROCEDURE `LaporanPerSeverity`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');

  
  
 SET @sqlText = CONCAT('
	SELECT NAMAINST, ALAMATINST, SEVERITY
			, COUNT(*) JUMLAH
			, (SELECT  COUNT(*) 
			FROM (
				SELECT  hl.CODECBG
					   , REVERSE(LEFT(REVERSE(hl.CODECBG), INSTR(REVERSE(hl.CODECBG),''-'')-1)) SEVERITY
					  , hl.TANGGAL TGL_GROUPING
					FROM pendaftaran.pendaftaran pp
					     LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pp.NOMOR AND lpp.`STATUS`=1
					     LEFT JOIN pendaftaran.kunjungan k ON lpp.kunjungan=k.NOMOR AND k.`STATUS`!=0
					     LEFT JOIN `master`.ruangan rg ON k.RUANGAN=rg.ID 
					     LEFT JOIN `master`.ruang_kamar_tidur rkt ON k.RUANG_KAMAR_TIDUR=rkt.ID
					     LEFT JOIN `master`.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
					     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
					     LEFT JOIN master.ruangan r ON r.ID=tp.RUANGAN AND r.JENIS=5
					     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN AND pj.JENIS=2
					     LEFT JOIN inacbg.hasil_grouping hl ON pp.NOMOR=hl.NOPEN
					WHERE pp.`STATUS`!=0 AND lpp.`STATUS`=1 ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
						AND k.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND pj.JENIS=2 AND hl.CODECBG IS NOT NULL
				GROUP BY pp.NOMOR
				) ab) TOTAL
			, ROUND((COUNT(*)/(SELECT  COUNT(*) 
			FROM (
				SELECT  hl.CODECBG
					   , REVERSE(LEFT(REVERSE(hl.CODECBG), INSTR(REVERSE(hl.CODECBG),''-'')-1)) SEVERITY
					  , hl.TANGGAL TGL_GROUPING
					FROM pendaftaran.pendaftaran pp
					     LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pp.NOMOR AND lpp.`STATUS`=1
					     LEFT JOIN pendaftaran.kunjungan k ON lpp.kunjungan=k.NOMOR AND k.`STATUS`!=0
					     LEFT JOIN `master`.ruangan rg ON k.RUANGAN=rg.ID 
					     LEFT JOIN `master`.ruang_kamar_tidur rkt ON k.RUANG_KAMAR_TIDUR=rkt.ID
					     LEFT JOIN `master`.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
					     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
					     LEFT JOIN master.ruangan r ON r.ID=tp.RUANGAN AND r.JENIS=5
					     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN AND pj.JENIS=2
					     LEFT JOIN inacbg.hasil_grouping hl ON pp.NOMOR=hl.NOPEN
					WHERE pp.`STATUS`!=0 AND lpp.`STATUS`=1 ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
						AND k.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND pj.JENIS=2 AND hl.CODECBG IS NOT NULL
				GROUP BY pp.NOMOR
				) ab))*100,2) PERSEN
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
	FROM (
		SELECT INST.NAMAINST, INST.ALAMATINST,LPAD(pp.NORM,8,''0'') NORM, pp.NOMOR, pp.TANGGAL TGLMASUK, IF(r.JENIS_KUNJUNGAN=3,lpp.TANGGAL,pp.TANGGAL) TGLKELUAR, pj.NOMOR NOSEP
			  , master.getNamaLengkap(pp.NORM) NAMAPASIEN
			  	, IF(r.JENIS_KUNJUNGAN=3, rg.DESKRIPSI, r.DESKRIPSI) UNITPELAYANAN, rk.KAMAR, IF(INSTR(rk.KAMAR,''Depan'') > 0,1, IF(INSTR(rk.KAMAR,''Belaka'') > 0,2,3)) ORDER_KAMAR
			   , hl.CODECBG
			   , REVERSE(LEFT(REVERSE(hl.CODECBG), INSTR(REVERSE(hl.CODECBG),''-'')-1)) SEVERITY
			  , hl.TANGGAL TGL_GROUPING
			FROM pendaftaran.pendaftaran pp
			     LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pp.NOMOR AND lpp.`STATUS`=1
			     LEFT JOIN pendaftaran.kunjungan k ON lpp.kunjungan=k.NOMOR AND k.`STATUS`!=0
			     LEFT JOIN `master`.ruangan rg ON k.RUANGAN=rg.ID 
			     LEFT JOIN `master`.ruang_kamar_tidur rkt ON k.RUANG_KAMAR_TIDUR=rkt.ID
			     LEFT JOIN `master`.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
			     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
			     LEFT JOIN master.ruangan r ON r.ID=tp.RUANGAN AND r.JENIS=5
			     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN AND pj.JENIS=2
			     LEFT JOIN master.kartu_asuransi_pasien kap ON pp.NORM=kap.NORM AND kap.JENIS=2
			     LEFT JOIN inacbg.hasil_grouping hl ON pp.NOMOR=hl.NOPEN
			     LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON tpd.PENDAFTARAN=pp.NOMOR AND tpd.`STATUS`!=0 AND tpd.UTAMA=1
			     LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
			     LEFT JOIN aplikasi.pengguna gr ON hl.USER=gr.ID
			     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
			WHERE pp.`STATUS`!=0 AND lpp.`STATUS`=1 ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
			AND k.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
			',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
			 AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			  AND pj.JENIS=2 AND hl.CODECBG IS NOT NULL
		GROUP BY pp.NOMOR
		) ab
GROUP BY SEVERITY
ORDER BY IF(SEVERITY=''I'',1,IF(SEVERITY=''II'',2,3))

	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
