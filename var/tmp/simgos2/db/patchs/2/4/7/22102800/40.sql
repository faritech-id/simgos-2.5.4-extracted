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

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL310
DROP PROCEDURE IF EXISTS `ambilDataRL310`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL310`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL310;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL310 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl310.JUMLAH IS NULL,0,rl310.JUMLAH)) JUMLAH
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT tindk.RL310,COUNT(tm.TINDAKAN) JUMLAH
  				 FROM layanan.tindakan_medis tm
  				 	 , master.rl310_tindakan tindk 
				 WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				  GROUP BY tindk.RL310) rl310 ON rl310.RL310=rl.ID
	       , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	   AND jrl.JENIS='100103' AND jrl.ID=10
	 GROUP BY rl.ID
	 ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-10` (tahun, `no`, jenis_kegiatan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI
			 , IFNULL(JUMLAH, 0)
	  FROM TEMP_LAPORAN_RL310 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-10` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-10` r, TEMP_LAPORAN_RL310 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL311
DROP PROCEDURE IF EXISTS `ambilDataRL311`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL311`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL311;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL311 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl311.JUMLAH IS NULL,0,rl311.JUMLAH)) JUMLAH
	  FROM master.jenis_laporan_detil jrl
	       , master.refrl rl
	       LEFT JOIN (SELECT tindk.RL311,COUNT(tm.TINDAKAN) JUMLAH
  				   FROM layanan.tindakan_medis tm
  				 	     , master.rl311_tindakan tindk 
				  WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	 AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				  GROUP BY tindk.RL311) rl311 ON rl311.RL311=rl.ID
			 , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						  , master.ppk p
						  , master.wilayah w
					WHERE ai.PPK = p.ID AND p.WILAYAH = w.ID) INST
	WHERE jrl.JENIS = rl.JENISRL AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS = '100103' AND jrl.ID=11
	GROUP BY rl.ID
	ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-11` (tahun, `no`, jenis_pelayanan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI
			 , IFNULL(JUMLAH, 0)
	  FROM TEMP_LAPORAN_RL311 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-11` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-11` r, TEMP_LAPORAN_RL311 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)	  
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL312
DROP PROCEDURE IF EXISTS `ambilDataRL312`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL312`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL312;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL312 ENGINE=MEMORY
 	SELECT INST.*, PTAHUN TAHUN, rl.ID, rl.KODE, rl.DESKRIPSI, NONRUJUKAN, RJ, RI, KUNJUNGANULANG, 
 			 0 ANC, 0 PASCAPERSALINAN, 0 CARAMASUKTOTAL, 0 NIFAS, 0 ABORTUS, 0 LAINNYA, 0 EFEKSAMPINGJUMLAH, 0 EFEKSAMPINGRUJUK
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT tindk.RL312
					   , SUM(IF((SELECT r.JENIS_KUNJUNGAN 
							FROM pendaftaran.konsul k 
					           , pendaftaran.kunjungan kjgn
					  			  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
			  			  WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
			  			  LIMIT 1) NOT IN (1,3) AND pk.REF IS NULL AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) NONRUJUKAN
						, SUM(IF((SELECT r.JENIS_KUNJUNGAN 
							FROM pendaftaran.konsul k 
								, pendaftaran.kunjungan kjgn
								  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
							WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
							LIMIT 1)=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) RJ
							, SUM(IF((SELECT r.JENIS_KUNJUNGAN 
							FROM pendaftaran.konsul k 
								, pendaftaran.kunjungan kjgn
								  LEFT JOIN master.ruangan r ON kjgn.RUANGAN=r.ID
							WHERE k.NOMOR=pk.REF AND k.KUNJUNGAN=kjgn.NOMOR
							LIMIT 1)=3 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR),1,0)) RI
						, SUM(IF(DATE(pp.TANGGAL)!=DATE(p.TANGGAL_LAHIR),1,0)) KUNJUNGANULANG
					 		FROM layanan.tindakan_medis tm
							 	  , master.rl312_tindakan tindk 
							 	  , pendaftaran.kunjungan pk
							 	  , pendaftaran.pendaftaran pp
							 	  , master.pasien p
						  WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
							 AND tm.STATUS!=0 AND tm.TINDAKAN=tindk.ID AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
							 AND pk.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pp.NORM=p.NORM
						  GROUP BY tindk.RL312
			 ) rl312 ON rl312.RL312=rl.ID
		, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
			FROM aplikasi.instansi ai
				, master.ppk p
				, master.wilayah w
			WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS='100103' AND jrl.ID=12
	  ORDER BY rl.ID;
		  
	INSERT INTO `kemkes-sirs`.`rl3-12` (tahun, `no`, metoda, konseling_anc, kenseling_pasca_persalinan, 
			 kb_baru_dengan_cara_masuk_bukan_rujukan, kb_baru_dengan_cara_masuk_rujukan_r_inap, 
			 kb_baru_dengan_cara_masuk_rujukan_r_jalan, kb_baru_dengan_cara_masuk_total,
			 kb_baru_dengan_kondisi_pasca_persalinan_atau_nifas, kb_baru_dengan_kondisi_abortus, 
			 kb_baru_dengan_kondisi_lainnya,
			 kunjungan_ulang, keluhan_efek_samping_jumlah, keluhan_efek_samping_dirujuk)													
	SELECT TAHUN, KODE, DESKRIPSI, ANC, PASCAPERSALINAN, 
			 IFNULL(NONRUJUKAN, 0), IFNULL(RI, 0), IFNULL(RJ, 0), IFNULL(CARAMASUKTOTAL, 0),    
			 IFNULL(NIFAS, 0), IFNULL(ABORTUS, 0), IFNULL(LAINNYA, 0), 
			 IFNULL(KUNJUNGANULANG, 0), IFNULL(EFEKSAMPINGJUMLAH, 0), IFNULL(EFEKSAMPINGRUJUK, 0)
  	  FROM TEMP_LAPORAN_RL312 t
    WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-12` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);
		
	UPDATE `kemkes-sirs`.`rl3-12` r, TEMP_LAPORAN_RL312 t
	   SET r.kb_baru_dengan_cara_masuk_bukan_rujukan = IFNULL(t.NONRUJUKAN, 0), 
		    r.kb_baru_dengan_cara_masuk_rujukan_r_inap = IFNULL(t.RI, 0), 
			 r.kb_baru_dengan_cara_masuk_rujukan_r_jalan = IFNULL(t.RJ, 0), 
			 r.kb_baru_dengan_cara_masuk_total = IFNULL(t.CARAMASUKTOTAL, 0),    
			 r.kb_baru_dengan_kondisi_pasca_persalinan_atau_nifas = IFNULL(t.NIFAS, 0), 
			 r.kb_baru_dengan_kondisi_abortus = IFNULL(t.ABORTUS, 0), 
			 r.kb_baru_dengan_kondisi_lainnya = IFNULL(t.LAINNYA, 0), 
			 r.kunjungan_ulang = IFNULL(t.KUNJUNGANULANG, 0), 
			 r.keluhan_efek_samping_jumlah = IFNULL(t.EFEKSAMPINGJUMLAH, 0), 
			 r.keluhan_efek_samping_dirujuk = IFNULL(t.EFEKSAMPINGRUJUK, 0)  
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL313
DROP PROCEDURE IF EXISTS `ambilDataRL313`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL313`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL313;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL313 ENGINE=MEMORY
	SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI, SUM(JUMLAH) JUMLAH
			 , SUM(TERSEDIA) TERSEDIA, SUM(FORNAS) FORNAS
	  FROM master.jenis_laporan_detil jrl
			 , master.refrl rl
			 LEFT JOIN (SELECT ID, SUM(JUMLAH) JUMLAH, SUM(TERSEDIA) TERSEDIA
					, IF(ID=1,SUM(FORNAS),IF(ID=2,SUM(TERSEDIA),0)) FORNAS
					FROM (
						SELECT 1 ID, COUNT(ib.ID) JUMLAH
								 , (SELECT COUNT(JML)  
								 FROM (
									SELECT DISTINCT(br.ID) JML
										FROM inventory.barang_ruangan br
											, inventory.barang ib
											, inventory.transaksi_stok_ruangan tsr
										WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID
										  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=1 AND tsr.STOK > 0
										  AND tsr.TANGGAL < TGLAKHIR
										GROUP BY br.BARANG) ab) TERSEDIA
								 , (SELECT COUNT(JML)  
									FROM (
										SELECT DISTINCT(br.ID) JML
										FROM inventory.barang_ruangan br
											, inventory.barang ib
											, inventory.transaksi_stok_ruangan tsr
										WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=1
										  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=1 AND tsr.STOK > 0
										  AND tsr.TANGGAL < TGLAKHIR
										GROUP BY br.BARANG) ab) FORNAS
						  FROM inventory.barang ib
						 WHERE ib.JENIS_GENERIK=1
						UNION
						SELECT 2 ID, COUNT(ib.ID) JUMLAH
								 , (SELECT COUNT(JML)  
								 FROM (
									SELECT DISTINCT(br.ID) JML
										FROM inventory.barang_ruangan br
											, inventory.barang ib
											, inventory.transaksi_stok_ruangan tsr
										WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=1
										  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=2 AND tsr.STOK > 0
										  AND tsr.TANGGAL < TGLAKHIR
										GROUP BY br.BARANG) ab) TERSEDIA
								 , 0 FORNAS
						 FROM inventory.barang ib
						 WHERE ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=1
						UNION
						SELECT 3 ID, COUNT(ib.ID) JUMLAH
								 , (SELECT COUNT(JML)  
							 	 FROM (
									SELECT DISTINCT(br.ID) JML
										FROM inventory.barang_ruangan br
											, inventory.barang ib
											, inventory.transaksi_stok_ruangan tsr
										WHERE br.`STATUS`=1  AND tsr.BARANG_RUANGAN=br.ID AND ib.FORMULARIUM=2
										  AND br.BARANG=ib.ID AND ib.JENIS_GENERIK=2 AND tsr.STOK > 0
										  AND tsr.TANGGAL < TGLAKHIR
										GROUP BY br.BARANG) ab) TERSEDIA
								 , 0 FORNAS
						  FROM inventory.barang ib
						 WHERE ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=2) ab
					    GROUP BY ID) rl313a ON rl.ID=rl313a.ID
			 , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						  , master.ppk p
						  , master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=13
		GROUP BY rl.ID
		ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-13` (tahun, `no`, golongan_obat, jumlah_item_obat, 
			 jumlah_item_obat_yang_tersedia_di_rs, jumlah_item_obat_formulatorium_yang_tersedia_di_rs)											
	SELECT TAHUN, KODE, DESKRIPSI, IFNULL(JUMLAH, 0), IFNULL(TERSEDIA, 0), IFNULL(FORNAS, 0)
  	  FROM TEMP_LAPORAN_RL313 t
    WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-13` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-13` r, TEMP_LAPORAN_RL313 t
	   SET r.jumlah_item_obat = IFNULL(t.JUMLAH, 0),
	  		 r.jumlah_item_obat_yang_tersedia_di_rs = IFNULL(t.TERSEDIA, 0),
	  		 r.jumlah_item_obat_formulatorium_yang_tersedia_di_rs = IFNULL(t.FORNAS	, 0)		  
	 WHERE r.tahun = t.TAHUN 
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL313B
DROP PROCEDURE IF EXISTS `ambilDataRL313B`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL313B`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL313B;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL313B ENGINE=MEMORY
	SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI
		  , SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
	FROM master.jenis_laporan_detil jrl
		, master.refrl rl
		  LEFT JOIN (SELECT ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
							FROM (
							SELECT 1 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
							FROM (
								SELECT DISTINCT(o.NOMOR) JML
										, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
										, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
										, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
									FROM layanan.order_resep o
										, layanan.order_detil_resep od
										, pendaftaran.kunjungan pk
										, master.ruangan r
										, inventory.barang ib
									WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
										AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
										AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=1
									GROUP BY o.NOMOR) ab
								UNION
								SELECT 2 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
								FROM (
									SELECT DISTINCT(o.NOMOR) JML
											, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
											, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
											, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
										FROM layanan.order_resep o
											, layanan.order_detil_resep od
											, pendaftaran.kunjungan pk
											, master.ruangan r
											, inventory.barang ib
										WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
											AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
											AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=1
										GROUP BY o.NOMOR) ab
								UNION
								SELECT 3 ID, SUM(RJ) RJ, SUM(RD) RD, SUM(IRNA) IRNA  
								FROM (
									SELECT DISTINCT(o.NOMOR) JML
											, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
											, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
											, IF(r.JENIS_KUNJUNGAN=3,1,0) IRNA
										FROM layanan.order_resep o
											, layanan.order_detil_resep od
											, pendaftaran.kunjungan pk
											, master.ruangan r
											, inventory.barang ib
										WHERE o.`STATUS`!=0 AND o.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
											AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0 AND pk.RUANGAN=r.ID
											AND o.NOMOR=od.ORDER_ID AND od.FARMASI=ib.ID AND ib.JENIS_GENERIK=2 AND ib.FORMULARIUM=2
										GROUP BY o.NOMOR) ab
								) ac
								GROUP BY ID
			) rl313b ON rl.ID=rl313b.ID
		, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				FROM aplikasi.instansi ai
					, master.ppk p
					, master.wilayah w
				WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS='100103' AND jrl.ID=13
	GROUP BY rl.ID
	ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl3-13b` (tahun, `no`, golongan_obat, rawat_jalan, igd, rawat_inap)											
	SELECT TAHUN, KODE, DESKRIPSI, IFNULL(RJ, 0), IFNULL(RD, 0), IFNULL(IRNA, 0)
  	  FROM TEMP_LAPORAN_RL313B t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-13b` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-13b` r, TEMP_LAPORAN_RL313B t
	  SET r.rawat_jalan = IFNULL(t.RJ, 0),
	  		r.igd = IFNULL(t.RD, 0),
	  		r.rawat_inap = IFNULL(t.IRNA, 0)
	WHERE r.tahun = t.TAHUN 
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL314
DROP PROCEDURE IF EXISTS `ambilDataRL314`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL314`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL314;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL314 ENGINE=MEMORY
		SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI, SUM(PUSKESMAS) PUSKESMAS, SUM(FASKES) FASKES, SUM(RS) RS
				, SUM(KEMBALIPUSKESMAS) KEMBALIPUSKESMAS, SUM(KEMBALIFASKES) KEMBALIFASKES, SUM(KEMBALIRS) KEMBALIRS
				, SUM(PASIENRUJUKAN) PASIENRUJUKAN, SUM(DATANGSENDIRI) DATANGSENDIRI, SUM(DITERIMAKEMBALI) DITERIMAKEMBALI		
		 FROM master.jenis_laporan_detil jrl
			   , master.refrl rl
			   LEFT JOIN (SELECT rl.RL314
	  						, SUM(IF(pr.JENIS=2,1,0)) PUSKESMAS
	  						, SUM(IF(pr.JENIS NOT IN (1,2),1,0)) FASKES
							, SUM(IF(pr.JENIS=1,1,0)) RS
							, 0 KEMBALIPUSKESMAS
	  						, 0 KEMBALIFASKES
							, 0 KEMBALIRS
							, 0 PASIENRUJUKAN
							, 0 DATANGSENDIRI
							, 0 DITERIMAKEMBALI
						FROM pendaftaran.pendaftaran pp
						     LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					        LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					      , pendaftaran.tujuan_pasien tp
							, master.ruangan r
							, master.rl314_smf rl
						WHERE pp.`STATUS` IN (1,2) AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
							AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN AND r.JENIS_KUNJUNGAN IN (1,2)
						GROUP BY rl.RL314
						UNION
						SELECT rl.RL314
	  						, 0 PUSKESMAS
	  						, 0 FASKES
							, 0 RS
							, SUM(IF(prb.JENIS=2,1,0)) KEMBALIPUSKESMAS
	  						, SUM(IF(prb.JENIS NOT IN (1,2),1,0)) KEMBALIFASKES
							, SUM(IF(prb.JENIS=1,1,0)) KEMBALIRS
							, 0 PASIENRUJUKAN
							, 0 DATANGSENDIRI
							, 0 DITERIMAKEMBALI
						FROM pendaftaran.pendaftaran pp
						     LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					        LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					      , pendaftaran.rujukan_keluar rjk 
					        LEFT JOIN master.ppk prb ON rjk.TUJUAN=prb.KODE
							, pendaftaran.tujuan_pasien tp
							, master.ruangan r
							, master.rl314_smf rl
						WHERE pp.NOMOR=rjk.NOPEN AND rjk.STATUS!=0 AND pp.`STATUS` IN (1,2) AND rjk.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
							AND pp.NOMOR=tp.NOPEN AND tp.SMF=rl.ID AND r.ID=tp.RUANGAN
						GROUP BY rl.RL314) rl314 ON rl314.RL314=rl.ID
				, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 	 WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		   AND jrl.JENIS='100103' AND jrl.ID=15
		 GROUP BY rl.ID
		 ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl3-14` (tahun, `no`, jenis_spesialisasi, rujukan_diterima_dari_puskesmas, rujukan_diterima_dari_faskes_lainnya, rujukan_diterima_dari_rs_lain,
		rujukan_dikembalikan_ke_puskesmas, rujukan_dikembalikan_ke_faskes_lainnya, rujukan_dikembalikan_ke_rs_asal, dirujuk_pasien_rujukan, dirujuk_pasien_datang_sendiri, dirujuk_diterima_kembali)											
	SELECT IFNULL(TAHUN, 0), IFNULL(KODE, 0), IFNULL(DESKRIPSI, 0), 
			 IFNULL(PUSKESMAS, 0), IFNULL(FASKES, 0), IFNULL(RS, 0), 
			 IFNULL(KEMBALIPUSKESMAS, 0), IFNULL(KEMBALIFASKES, 0), IFNULL(KEMBALIRS, 0), 
			 IFNULL(PASIENRUJUKAN, 0), IFNULL(DATANGSENDIRI, 0), IFNULL(DITERIMAKEMBALI, 0)
  	  FROM TEMP_LAPORAN_RL314 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-14` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-14` r, TEMP_LAPORAN_RL314 t
	   SET r.rujukan_diterima_dari_puskesmas = IFNULL(t.PUSKESMAS, 0),
		 	 r.rujukan_diterima_dari_faskes_lainnya = IFNULL(t.FASKES, 0),
			 r.rujukan_diterima_dari_rs_lain = IFNULL(t.RS, 0),
			 r.rujukan_dikembalikan_ke_puskesmas = IFNULL(t.KEMBALIPUSKESMAS, 0),
			 r.rujukan_dikembalikan_ke_faskes_lainnya = IFNULL(t.KEMBALIFASKES, 0),
			 r.rujukan_dikembalikan_ke_rs_asal = IFNULL(t.KEMBALIRS, 0),
			 r.dirujuk_pasien_rujukan = IFNULL(t.PASIENRUJUKAN, 0),
			 r.dirujuk_pasien_datang_sendiri = IFNULL(t.DATANGSENDIRI, 0),
			 r.dirujuk_diterima_kembali = IFNULL(t.DITERIMAKEMBALI, 0)	  
	 WHERE r.tahun = t.TAHUN
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL315
DROP PROCEDURE IF EXISTS `ambilDataRL315`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL315`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL315;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL315 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN
			 , SUM(IF(rl315.JMLRJ IS NULL,0, rl315.JMLRJ)) RJ
		 	 , SUM(IF(rl315.JMLLAB IS NULL,0, rl315.JMLLAB)) LAB
			 , SUM(IF(rl315.JMLRAD IS NULL,0, rl315.JMLRAD)) RAD
			 , SUM(IF(rl315.JMLRI IS NULL,0, rl315.JMLRI)) JMLRI
			 , SUM(IF(rl315.LD IS NULL,0, rl315.LD)) LD
			 , 0 RJLL
	  FROM master.jenis_laporan_detil jrl
			 , master.refrl rl
			 /* Pasien Pengunjung RJ */
			 LEFT JOIN (SELECT penjamin.RL315, refrl.KODE_HIRARKI ,COUNT(pd.NOMOR) JMLRJ, 0 JMLLAB, 0 JMLRAD, 0 JMLRI, 0 LD, 0 RJLL
				 FROM pendaftaran.pendaftaran pd
					   LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					   LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					   LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
					   LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL='100103' AND refrl.IDJENISRL=16
					   , pendaftaran.tujuan_pasien tp
					   LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
					   , pendaftaran.kunjungan tk
					   , master.ruangan jkr
				WHERE pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN
				  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
				  AND tk.MASUK BETWEEN TGLAWAL AND TGLAKHIR
				  AND jkr.JENIS_KUNJUNGAN=1 
				GROUP BY penjamin.RL315
				UNION
			 /* Pasien RJ Laboratorium dan RJ Radiologi */
				SELECT penjamin.RL315, refrl.KODE_HIRARKI ,0 JMLRJ, SUM(IF(jkr.JENIS_KUNJUNGAN=4 AND (tk.REF IS NULL OR lab.JENIS_KUNJUNGAN=1),1,0)) JMLLAB,
				       SUM(IF(jkr.JENIS_KUNJUNGAN=5 AND (tk.REF IS NULL OR rad.JENIS_KUNJUNGAN=1),1,0)) JMLRAD, 0 JMLRI, 0 LD, 0 RJLL
				  FROM pendaftaran.pendaftaran pd
					    LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					    LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
					    LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL='100103' AND refrl.IDJENISRL=16
				  	    , pendaftaran.tujuan_pasien tp
					    LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
					    , pendaftaran.kunjungan tk
					    LEFT JOIN layanan.order_lab ol ON tk.REF=ol.NOMOR
					    LEFT JOIN pendaftaran.kunjungan kjol ON kjol.NOMOR=ol.KUNJUNGAN
					    LEFT JOIN master.ruangan lab ON kjol.RUANGAN=lab.ID AND lab.JENIS_KUNJUNGAN=1
					    LEFT JOIN layanan.order_rad orad ON tk.REF=orad.NOMOR
					    LEFT JOIN pendaftaran.kunjungan kjorad ON kjorad.NOMOR=orad.KUNJUNGAN
					    LEFT JOIN master.ruangan rad ON kjorad.RUANGAN=rad.ID AND rad.JENIS_KUNJUNGAN=1
					    , master.ruangan jkr
				 WHERE pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
				   AND tk.MASUK BETWEEN TGLAWAL AND TGLAKHIR
					AND jkr.JENIS_KUNJUNGAN IN (4 ,5)
				 GROUP BY penjamin.RL315
			 /*	Pasien Keluar dan Lama Dirawat */
				UNION
				SELECT penjamin.RL315, refrl.KODE_HIRARKI ,0 JMLRJ, 0 JMLLAB, 0 JMLRAD, COUNT(lpp.KUNJUNGAN) JMLRI, SUM(DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LD, 0 RJLL
				  FROM pendaftaran.pendaftaran pd
					    LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					    LEFT JOIN master.rl315_penjamin penjamin ON pj.JENIS=penjamin.ID
					    LEFT JOIN master.refrl refrl ON penjamin.RL315=refrl.ID AND refrl.JENISRL='100103' AND refrl.IDJENISRL=16
					    , pendaftaran.kunjungan tk
					    , master.ruangan jkr
					    , layanan.pasien_pulang lpp
				 WHERE pd.NOMOR=tk.NOPEN AND lpp.KUNJUNGAN=tk.NOMOR AND lpp.`STATUS`=1 
				   AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.STATUS=1 
					AND lpp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				   AND jkr.JENIS_KUNJUNGAN=3 
				 GROUP BY penjamin.RL315) rl315 ON rl315.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')			
			 , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				   FROM aplikasi.instansi ai
						  , master.ppk p
						  , master.wilayah w
				  WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	   AND jrl.JENIS='100103' AND jrl.ID=16
	 GROUP BY rl.ID
	 ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-15` (tahun, `no`, cara_pembayaran, pasien_rawat_inap_jpk, pasien_rawat_inap_jld, jumlah_pasien_rawat_jalan,
			 jumlah_pasien_rawat_jalan_lab, jumlah_pasien_rawat_jalan_rad, jumlah_pasien_rawat_jalan_ll)											
	SELECT TAHUN, KODE, DESKRIPSI, 
		    IFNULL(JMLRI, 0), IFNULL(LD, 0), IFNULL(RJ, 0), IFNULL(LAB, 0), IFNULL(RAD, 0), IFNULL(RJLL, 0)
  	  FROM TEMP_LAPORAN_RL315 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-15` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-15` r, TEMP_LAPORAN_RL315 t
	   SET r.pasien_rawat_inap_jpk = IFNULL(t.JMLRI, 0),
			 r.pasien_rawat_inap_jld = IFNULL(t.LD, 0),
			 r.jumlah_pasien_rawat_jalan = IFNULL(t.RJ, 0),
			 r.jumlah_pasien_rawat_jalan_lab = IFNULL(t.LAB, 0),
			 r.jumlah_pasien_rawat_jalan_rad = IFNULL(t.RAD, 0),
			 r.jumlah_pasien_rawat_jalan_ll = IFNULL(t.RJLL, 0)
	 WHERE r.tahun = t.TAHUN
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL35
DROP PROCEDURE IF EXISTS `ambilDataRL35`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL35`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL35;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL35 ENGINE=MEMORY
	SELECT INST.*, PTAHUN TAHUN,rl.ID, rl.KODE, rl.DESKRIPSI, JUMLAH
			, IF(rl.ID >= 4,0,SUM(RS)) RS, IF(rl.ID >= 4,0,SUM(BIDAN)) BIDAN, IF(rl.ID >= 4,0,SUM(PUSKESMAS)) PUSKESMAS
			, IF(rl.ID >= 4,0,SUM(FASKES)) FASKES
			, IF(rl.ID >= 4,0,SUM(RUJUKANHIDUP)) RUJUKANHIDUP
			, IF(rl.ID < 4,0,SUM(RUJUKANMATI)) RUJUKANMATI
			, (IF(rl.ID >= 4,0,SUM(RUJUKANHIDUP))+IF(rl.ID < 4,0,SUM(RUJUKANMATI))) RUJUKANTOTAL
			, IF(rl.ID >= 4,0,SUM(NONMEDISHIDUP)) NONMEDISHIDUP
			, IF(rl.ID < 4,0,SUM(NONMEDISMATI)) NONMEDISMATI
			, (IF(rl.ID >= 4,0,SUM(NONMEDISHIDUP))+IF(rl.ID < 4,0,SUM(NONMEDISMATI))) NONMEDISTOTAL
			, IF(rl.ID >= 4,0,SUM(NONRUJUKANHIDUP)) NONRUJUKANHIDUP
			, IF(rl.ID < 4,0,SUM(NONRUJUKANMATI)) NONRUJUKANMATI
			, (IF(rl.ID >= 4,0,SUM(NONRUJUKANHIDUP))+IF(rl.ID < 4,0,SUM(NONRUJUKANMATI))) NONRUJUKANTOTAL
			, IF(rl.ID >= 4,0,SUM(DIRUJUK)) DIRUJUK
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT 2 ID, COUNT(pp.NOMOR) JUMLAH
					, SUM(IF(pr.JENIS=1 AND pl.CARA NOT IN (6,7),1,0)) RS
					, 0 BIDAN
					, SUM(IF(pr.JENIS=2 AND pl.CARA NOT IN (6,7),1,0)) PUSKESMAS
					, SUM(IF(pr.JENIS NOT IN (1,2) AND pl.CARA NOT IN (6,7),1,0)) FASKES
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA NOT IN (6,7),1,0)) RUJUKANHIDUP
					, 0 RUJUKANMATI
					, 0 NONMEDISHIDUP
					, 0 NONMEDISMATI
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA NOT IN (6,7),1,0)) NONRUJUKANHIDUP
					, 0 NONRUJUKANMATI
					, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
				FROM pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
					  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				WHERE pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
				  AND pp.BERAT_BAYI >= 2500
				GROUP BY ID
			   UNION
			   SELECT 3 ID, COUNT(pp.NOMOR) JUMLAH
					, SUM(IF(pr.JENIS=1 AND pl.CARA NOT IN (6,7),1,0)) RS
					, 0 BIDAN
					, SUM(IF(pr.JENIS=2 AND pl.CARA NOT IN (6,7),1,0)) PUSKESMAS
					, SUM(IF(pr.JENIS NOT IN (1,2) AND pl.CARA NOT IN (6,7),1,0)) FASKES
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA NOT IN (6,7),1,0)) RUJUKANHIDUP
					, 0 RUJUKANMATI
					, 0 NONMEDISHIDUP
					, 0 NONMEDISMATI
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA NOT IN (6,7),1,0)) NONRUJUKANHIDUP
					, 0 NONRUJUKANMATI
					, SUM(IF(pl.CARA=3,1,0)) DIRUJUK
				FROM pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
					  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				WHERE pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
				  AND pp.BERAT_BAYI < 2500
				GROUP BY ID
				UNION
				SELECT 5 ID, COUNT(md.NOPEN) JUMLAH
					, 0 RS
					, 0 BIDAN
					, SUM(IF(pr.JENIS=2 AND pl.CARA IN (6,7),1,0)) PUSKESMAS
					, 0 FASKES
					, 0 RUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
					, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
					, 0 DIRUJUK
				FROM medicalrecord.diagnosa md
					, pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
					  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				WHERE md.`STATUS`!=0  AND pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 
				  AND md.KODE='P95'
				GROUP BY ID
				UNION
				SELECT 6 ID, COUNT(md.NOPEN) JUMLAH
					, 0 RS
					, 0 BIDAN
					, SUM(IF(pr.JENIS=2 AND pl.CARA IN (6,7),1,0)) PUSKESMAS
					, 0 FASKES
					, 0 RUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
					, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
					, 0 DIRUJUK
				FROM medicalrecord.diagnosa md
					, medicalrecord.diagnosa_meninggal mdm
					, pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
					  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				WHERE md.`STATUS`!=0  AND pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
				  AND md.NOPEN=mdm.NOPEN AND mdm.UTAMA=1 AND DATEDIFF(pl.TANGGAL,pp.TANGGAL) < 7
				GROUP BY ID
				UNION
				SELECT ic.RL35 ID, COUNT(md.NOPEN) JUMLAH
					, 0 RS
					, 0 BIDAN
					, 0 PUSKESMAS
					, 0 FASKES, 0 RUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NOT NULL AND pl.CARA IN (6,7),1,0)) RUJUKANMATI
					, 0 NONMEDISHIDUP, 0 NONMEDISMATI, 0 NONRUJUKANHIDUP
					, SUM(IF(pp.RUJUKAN IS NULL AND pl.CARA IN (6,7),1,0)) NONRUJUKANMATI
					, 0 DIRUJUK
				FROM medicalrecord.diagnosa md
					, medicalrecord.diagnosa_meninggal mdm
					, master.rl35_icd10 ic
					, pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pp.RUJUKAN=srp.ID AND srp.`STATUS`!=0
					  LEFT JOIN master.ppk pr ON srp.PPK=pr.ID
					  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.`STATUS`=1
					  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				WHERE md.`STATUS`!=0 AND mdm.KODE=ic.ID AND pl.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND md.NOPEN=pp.NOMOR AND pp.`STATUS`!=0 AND pl.`STATUS`=1 AND DATE(pp.TANGGAL)=DATE(p.TANGGAL_LAHIR)
				  AND ic.RL35 > 6 AND md.NOPEN=mdm.NOPEN AND mdm.UTAMA=1
				GROUP BY ic.RL35) rl35 ON rl35.ID=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				FROM aplikasi.instansi ai
					, master.ppk p
					, master.wilayah w
				WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100103' AND jrl.ID=5
		GROUP BY rl.ID
		ORDER BY rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl3-5` (tahun, `no`, jenis_kegiatan, rm_rumah_sakit, rm_bidan, rm_puskesmas, rm_faskes_lainnya, 
					rm_mati, rm_total, rnm_mati, rnm_total, nr_mati, nr_total, dirujuk)											
	SELECT TAHUN, KODE, DESKRIPSI, 
			 IFNULL(RS, 0), IFNULL(BIDAN, 0), IFNULL(PUSKESMAS, 0), IFNULL(FASKES, 0), IFNULL(RUJUKANMATI, 0), IFNULL(RUJUKANTOTAL, 0), 
			 IFNULL(NONMEDISMATI, 0), IFNULL(NONMEDISTOTAL, 0), IFNULL(NONRUJUKANMATI, 0), IFNULL(NONRUJUKANTOTAL, 0), IFNULL(DIRUJUK, 0)
  	  FROM TEMP_LAPORAN_RL35 t
  	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-5` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-5` r, TEMP_LAPORAN_RL35 t
	  SET r.rm_rumah_sakit = IFNULL(t.RS, 0),
			r.rm_bidan = IFNULL(t.BIDAN, 0),
			r.rm_puskesmas = IFNULL(t.PUSKESMAS, 0),
			r.rm_faskes_lainnya = IFNULL(t.FASKES, 0),
			r.rm_mati = IFNULL(t.RUJUKANMATI, 0),
			r.rm_total = IFNULL(t.RUJUKANTOTAL, 0),
			r.rnm_mati = IFNULL(t.NONMEDISMATI, 0),
			r.rnm_total = IFNULL(t.NONMEDISTOTAL, 0),
			r.nr_mati = IFNULL(t.NONRUJUKANMATI, 0),
			r.nr_total = IFNULL(t.NONRUJUKANTOTAL, 0),
			r.dirujuk = IFNULL(t.DIRUJUK, 0)	  
	WHERE r.tahun = t.TAHUN 
	  AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL36
DROP PROCEDURE IF EXISTS `ambilDataRL36`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL36`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL36;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL36 ENGINE=MEMORY
	SELECT INST.*, PTAHUN TAHUN, rl.KODE, rl.DESKRIPSI, SUM(JML) JML
		    , SUM(KHUSUS) KHUSUS, SUM(BESAR) BESAR, SUM(SEDANG) SEDANG, SUM(KECIL) KECIL
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT sm.RL36, ds.SMF, COUNT(tm.TINDAKAN) JML
					, SUM(IF(klp.KELOMPOK_OPERASI=4,1,0)) KHUSUS
					, SUM(IF(klp.KELOMPOK_OPERASI=3,1,0)) BESAR
					, SUM(IF(klp.KELOMPOK_OPERASI=2,1,0)) SEDANG
					, SUM(IF(klp.KELOMPOK_OPERASI=1,1,0)) KECIL
				FROM layanan.tindakan_medis tm
					  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
					  LEFT JOIN master.dokter_smf ds ON ptm.MEDIS=ds.DOKTER #AND ds.STATUS=1
					, master.tindakan t
					, master.tindakan_klp_operasi klp 
					, pendaftaran.kunjungan pk
					, master.ruangan r
					, master.rl36_smf sm
				WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				  AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND tm.`STATUS` IN (1,2)
				  AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=6 AND tm.TINDAKAN=t.ID AND ds.SMF IS NOT NULL
				  AND ds.SMF=sm.ID AND t.ID=klp.ID
				GROUP BY sm.RL36) b ON b.RL36=rl.ID
		   , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
				FROM aplikasi.instansi ai
					, master.ppk p
					, master.wilayah w
			WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS='100103' AND jrl.ID=6
	GROUP BY rl.ID
	ORDER BY rl.ID;							

	INSERT INTO `kemkes-sirs`.`rl3-6` (tahun, `no`, spesialisasi, total, khusus, besar, sedang, kecil)											
	SELECT TAHUN, KODE, DESKRIPSI, IFNULL(JML, 0), IFNULL(KHUSUS, 0), IFNULL(BESAR, 0), IFNULL(SEDANG, 0), IFNULL(KECIL, 0)
	  FROM TEMP_LAPORAN_RL36 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-6` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-6` r, TEMP_LAPORAN_RL36 t
	   SET r.total = IFNULL(t.JML, 0),
			 r.khusus = IFNULL(t.KHUSUS, 0),
		 	 r.besar = IFNULL(t.BESAR, 0),
			 r.sedang = IFNULL(t.SEDANG, 0),
			 r.kecil = IFNULL(t.KECIL, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL37
DROP PROCEDURE IF EXISTS `ambilDataRL37`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL37`(
	IN `PTAHUN` YEAR
)
BEGIN
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL37;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL37 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl37.JUMLAH IS NULL,0,rl37.JUMLAH)) JUMLAH
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT tindk.RL37,COUNT(tm.TINDAKAN) JUMLAH
  				 FROM layanan.tindakan_medis tm
  				 	 , master.rl37_tindakan tindk 
				 WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				  GROUP BY tindk.RL37) rl37 ON rl37.RL37=rl.ID
		    , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	  AND jrl.JENIS='100103' AND jrl.ID=7
	GROUP BY rl.ID
	ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl3-7` (tahun, `no`, jenis_kegiatan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI
			 , IFNULL(JUMLAH, 0)
	  FROM TEMP_LAPORAN_RL37 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-7` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-7` r, TEMP_LAPORAN_RL37 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)	  
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL38
DROP PROCEDURE IF EXISTS `ambilDataRL38`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL38`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL38;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL38 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl38.JUMLAH IS NULL,0, rl38.JUMLAH)) JUMLAH
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT tindk.ID, refrl.KODE_HIRARKI, COUNT(tm.TINDAKAN) JUMLAH
  				 FROM layanan.tindakan_medis tm
  				 	 , master.rl38_tindakan tindk
  				 	 , master.refrl refrl 
				 WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				 	AND tindk.RL38=refrl.ID AND refrl.JENISRL=100103 AND refrl.IDJENISRL=8
				  GROUP BY tindk.ID
  				 ) rl38 ON rl38.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
		    , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
	   AND jrl.JENIS='100103' AND jrl.ID=8
	 GROUP BY rl.ID
	 ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl3-8` (tahun, `no`, jenis_kegiatan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI
			 , IFNULL(JUMLAH, 0)
	  FROM TEMP_LAPORAN_RL38 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-8` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-8` r, TEMP_LAPORAN_RL38 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL39
DROP PROCEDURE IF EXISTS `ambilDataRL39`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL39`(
	IN `PTAHUN` YEAR
)
BEGIN	
	/*Masih tampilan masternya*/
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
 
 	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL39;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL39 ENGINE=MEMORY
	SELECT INST.*, rl.KODE, rl.DESKRIPSI, PTAHUN TAHUN, SUM(IF(rl39.JUMLAH IS NULL,0, rl39.JUMLAH)) JUMLAH
	  FROM master.jenis_laporan_detil jrl
		    , master.refrl rl
		    LEFT JOIN (SELECT tindk.ID, refrl.KODE_HIRARKI, COUNT(tm.TINDAKAN) JUMLAH
  				 FROM layanan.tindakan_medis tm
  				 	 , master.rl39_tindakan tindk
  				 	 , master.refrl refrl 
				 WHERE tm.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
				 	AND tm.STATUS=1 AND tm.TINDAKAN=tindk.ID
				 	AND tindk.RL39=refrl.ID AND refrl.JENISRL='100103' AND refrl.IDJENISRL=9
				  GROUP BY tindk.ID
  				 ) rl39 ON rl39.KODE_HIRARKI LIKE CONCAT(rl.KODE_HIRARKI,''%'')
			 , (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		AND jrl.JENIS='100103' AND jrl.ID=9
	 GROUP BY rl.ID
	 ORDER BY rl.ID;
			
	INSERT INTO `kemkes-sirs`.`rl3-9` (tahun, `no`, jenis_tindakan, jumlah)
	SELECT TAHUN, KODE, DESKRIPSI
			, IFNULL(JUMLAH, 0)
	  FROM TEMP_LAPORAN_RL39 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl3-9` r WHERE r.tahun = t.TAHUN AND r.`no` = t.KODE);

	UPDATE `kemkes-sirs`.`rl3-9` r, TEMP_LAPORAN_RL39 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL4A
DROP PROCEDURE IF EXISTS `ambilDataRL4A`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL4A`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL4A;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL4A (
		TAHUN YEAR, 
		KODE CHAR(10), 
		ID SMALLINT(5), 
		NODAFTAR VARCHAR(200), 
		DESKRIPSI VARCHAR(200), 
		KLP1LAKI SMALLINT(5), 
		KLP1WANITA SMALLINT(5), 
		KLP2LAKI SMALLINT(5), 
		KLP2WANITA SMALLINT(5), 
		KLP3LAKI SMALLINT(5), 
		KLP3WANITA SMALLINT(5), 
		KLP4LAKI SMALLINT(5),
		KLP4WANITA SMALLINT(5), 
		KLP5LAKI SMALLINT(5), 
		KLP5WANITA SMALLINT(5), 
		KLP6LAKI SMALLINT(5), 
		KLP6WANITA SMALLINT(5), 
		KLP7LAKI SMALLINT(5), 
		KLP7WANITA SMALLINT(5), 
		KLP8LAKI SMALLINT(5), 
		KLP8WANITA SMALLINT(5), 
		KLP9LAKI SMALLINT(5), 
		KLP9WANITA SMALLINT(5), 
		JMLLAKI SMALLINT(5), 
		JMLWANITA SMALLINT(5), 
		JUMLAH SMALLINT(5), 
		JMLMATI SMALLINT(5)
	) ENGINE=MEMORY;
   
   INSERT INTO TEMP_LAPORAN_RL4A
	SELECT 
	 -- INST.*, 
		PTAHUN TAHUN, rl.KODE, rl.ID, rl.NODAFTAR, rl.DESKRIPSI, KLP1LAKI, KLP1WANITA, KLP2LAKI, KLP2WANITA, KLP3LAKI, KLP3WANITA, KLP4LAKI,
					 KLP4WANITA, KLP5LAKI, KLP5WANITA, KLP6LAKI, KLP6WANITA, KLP7LAKI, KLP7WANITA, KLP8LAKI, KLP8WANITA, KLP9LAKI, KLP9WANITA, JMLLAKI, JMLWANITA, JUMLAH, JMLMATI
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
		--			(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, 
					 SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI, 
					 SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA, 
					 SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pk.NOPEN AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3 AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100104' AND jrl.ID=1
		ORDER BY rl.ID;
		
	INSERT INTO 
				`kemkes-sirs`.`rl4a` (`tahun`,  `no_dtd`,  `no_urut`,  `no_daftar_terperinci`,  `golongan_sebab_penyakit`,  `jumlah_pasien_hidup_mati_0-<=6_hari_l`,  
				`jumlah_pasien_hidup_mati_0-<=6_hari_p`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_l`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_p`,  `jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l`,
				`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_l`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_p`,  `jumlah_pasien_hidup_mati_>4-<=14_tahun_l`, 
				`jumlah_pasien_hidup_mati_>4-<=14_tahun_p`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_l`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_p`,  `jumlah_pasien_hidup_mati_>24-<=44_tahun_l`, 
				`jumlah_pasien_hidup_mati_>24-<=44_tahun_p`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_l`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_p`,  `jumlah_pasien_hidup_mati_>64_tahun_l`, 
				`jumlah_pasien_hidup_mati_>64_tahun_p`,  `pasien_keluar_hidup_mati_l`,  `pasien_keluar_hidup_mati_p`,  `jumlah_pasien_keluar_hidup_mati`,  `jumlah_pasien_keluar_mati`)											
	SELECT TAHUN, KODE, ID, NODAFTAR, DESKRIPSI, 
			 IFNULL(KLP1LAKI, 0), IFNULL(KLP1WANITA, 0), 
			 IFNULL(KLP2LAKI, 0), IFNULL(KLP2WANITA, 0), 
			 IFNULL(KLP3LAKI, 0), IFNULL(KLP3WANITA, 0), 
			 IFNULL(KLP4LAKI, 0), IFNULL(KLP4WANITA, 0), 
			 IFNULL(KLP5LAKI, 0), IFNULL(KLP5WANITA, 0), 
			 IFNULL(KLP6LAKI, 0), IFNULL(KLP6WANITA, 0), 
			 IFNULL(KLP7LAKI, 0), IFNULL(KLP7WANITA, 0), 
			 IFNULL(KLP8LAKI, 0), IFNULL(KLP8WANITA, 0), 
			 IFNULL(KLP9LAKI, 0), IFNULL(KLP9WANITA, 0), 
			 IFNULL(JMLLAKI, 0), IFNULL(JMLWANITA, 0), IFNULL(JUMLAH, 0), IFNULL(JMLMATI, 0)
  	  FROM TEMP_LAPORAN_RL4A t
	 WHERE NOT EXISTS (SELECT 1 FROM `kemkes-sirs`.`rl4a` r WHERE r.tahun = t.TAHUN AND r.`no_dtd` = t.KODE);

	UPDATE `kemkes-sirs`.`rl4a` r, TEMP_LAPORAN_RL4A t
	   SET r.`jumlah_pasien_hidup_mati_0-<=6_hari_l` = IFNULL(t.KLP1LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_0-<=6_hari_p` = IFNULL(t.KLP1WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_l` = IFNULL(t.KLP2LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_p` = IFNULL(t.KLP2WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l` = IFNULL(t.KLP3LAKI, 0),
		 	 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p` = IFNULL(t.KLP3WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l` = IFNULL(t.KLP4LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p` = IFNULL(t.KLP4WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l` = IFNULL(t.KLP5LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p` = IFNULL(t.KLP5WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l` = IFNULL(t.KLP6LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p` = IFNULL(t.KLP6WANITA, 0),
		 	 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l` = IFNULL(t.KLP7LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p` = IFNULL(t.KLP7WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l` = IFNULL(t.KLP8LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p` = IFNULL(t.KLP8WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_l` = IFNULL(t.KLP9LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_p` = IFNULL(t.KLP9WANITA, 0),
			 r.`pasien_keluar_hidup_mati_l` = IFNULL(t.JMLLAKI, 0),
			 r.`pasien_keluar_hidup_mati_p` = IFNULL(t.JMLWANITA, 0),
			 r.`jumlah_pasien_keluar_hidup_mati` = IFNULL(t.JUMLAH, 0),
			 r.`jumlah_pasien_keluar_mati` = IFNULL(t.JMLMATI, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no_dtd` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL4ASebab
DROP PROCEDURE IF EXISTS `ambilDataRL4ASebab`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL4ASebab`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL4ASEBAB;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL4ASEBAB (
		TAHUN YEAR, 
		KODE CHAR(10), 
		ID SMALLINT(5), 
		NODAFTAR VARCHAR(200), 
		DESKRIPSI VARCHAR(200), 
		KLP1LAKI SMALLINT(5), 
		KLP1WANITA SMALLINT(5), 
		KLP2LAKI SMALLINT(5), 
		KLP2WANITA SMALLINT(5), 
		KLP3LAKI SMALLINT(5), 
		KLP3WANITA SMALLINT(5), 
		KLP4LAKI SMALLINT(5),
		KLP4WANITA SMALLINT(5), 
		KLP5LAKI SMALLINT(5), 
		KLP5WANITA SMALLINT(5), 
		KLP6LAKI SMALLINT(5), 
		KLP6WANITA SMALLINT(5), 
		KLP7LAKI SMALLINT(5), 
		KLP7WANITA SMALLINT(5), 
		KLP8LAKI SMALLINT(5), 
		KLP8WANITA SMALLINT(5), 
		KLP9LAKI SMALLINT(5), 
		KLP9WANITA SMALLINT(5), 
		JMLLAKI SMALLINT(5), 
		JMLWANITA SMALLINT(5), 
		JUMLAH SMALLINT(5), 
		JMLMATI SMALLINT(5)
   	) ENGINE=MEMORY;
   INSERT INTO TEMP_LAPORAN_RL4ASEBAB 
	SELECT 
	-- INST.*, 
		PTAHUN TAHUN, rl.KODE, rl.ID, rl.NODAFTAR, rl.DESKRIPSI, KLP1LAKI, KLP1WANITA, KLP2LAKI, KLP2WANITA, KLP3LAKI, KLP3WANITA, KLP4LAKI,
					 KLP4WANITA, KLP5LAKI, KLP5WANITA, KLP6LAKI, KLP6WANITA, KLP7LAKI, KLP7WANITA, KLP8LAKI, KLP8WANITA, KLP9LAKI, KLP9WANITA, JMLLAKI, JMLWANITA, JUMLAH, JMLMATI
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
	--				(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH
					 , SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI
					 , SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA
					 , SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pk.NOPEN AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN=3 AND md.KODE=ic.KODE
					AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100104' AND jrl.ID=2
		ORDER BY rl.ID;
	
	INSERT INTO 
				`kemkes-sirs`.`rl4a-sebab` (`tahun`,  `no_dtd`,  `no_urut`,  `no_daftar_terperinci`,  `golongan_sebab_penyakit`,  `jumlah_pasien_hidup_mati_0-<=6_hari_l`,  
				`jumlah_pasien_hidup_mati_0-<=6_hari_p`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_l`,  `jumlah_pasien_hidup_mati_>6-<=28_hari_p`,  `jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l`,
				`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_l`,  `jumlah_pasien_hidup_mati_>1-<=4_tahun_p`,  `jumlah_pasien_hidup_mati_>4-<=14_tahun_l`, 
				`jumlah_pasien_hidup_mati_>4-<=14_tahun_p`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_l`,  `jumlah_pasien_hidup_mati_>14-<=24_tahun_p`,  `jumlah_pasien_hidup_mati_>24-<=44_tahun_l`, 
				`jumlah_pasien_hidup_mati_>24-<=44_tahun_p`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_l`,  `jumlah_pasien_hidup_mati_>44-<=64_tahun_p`,  `jumlah_pasien_hidup_mati_>64_tahun_l`, 
				`jumlah_pasien_hidup_mati_>64_tahun_p`,  `pasien_keluar_hidup_mati_l`,  `pasien_keluar_hidup_mati_p`,  `jumlah_pasien_keluar_hidup_mati`,  `jumlah_pasien_keluar_mati`)											
	SELECT TAHUN, KODE, ID, NODAFTAR, DESKRIPSI, 
			 IFNULL(KLP1LAKI, 0), IFNULL(KLP1WANITA, 0), 
			 IFNULL(KLP2LAKI, 0), IFNULL(KLP2WANITA, 0), 
			 IFNULL(KLP3LAKI, 0), IFNULL(KLP3WANITA, 0), 
			 IFNULL(KLP4LAKI, 0), IFNULL(KLP4WANITA, 0), 
			 IFNULL(KLP5LAKI, 0), IFNULL(KLP5WANITA, 0), 
			 IFNULL(KLP6LAKI, 0), IFNULL(KLP6WANITA, 0), 
			 IFNULL(KLP7LAKI, 0), IFNULL(KLP7WANITA, 0), 
			 IFNULL(KLP8LAKI, 0), IFNULL(KLP8WANITA, 0), 
			 IFNULL(KLP9LAKI, 0), IFNULL(KLP9WANITA, 0), 
			 IFNULL(JMLLAKI, 0), IFNULL(JMLWANITA, 0), IFNULL(JUMLAH, 0), IFNULL(JMLMATI, 0)
  	  FROM TEMP_LAPORAN_RL4ASEBAB t
	 WHERE NOT EXISTS (SELECT 1 FROM `kemkes-sirs`.`rl4a-sebab` r WHERE r.tahun = t.TAHUN AND r.`no_dtd` = t.KODE);

	UPDATE `kemkes-sirs`.`rl4a-sebab` r, TEMP_LAPORAN_RL4ASEBAB t
	   SET r.`jumlah_pasien_hidup_mati_0-<=6_hari_l` = IFNULL(t.KLP1LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_0-<=6_hari_p` = IFNULL(t.KLP1WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_l` = IFNULL(t.KLP2LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>6-<=28_hari_p` = IFNULL(t.KLP2WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_l` = IFNULL(t.KLP3LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>28_hari-<=1_tahun_p` = IFNULL(t.KLP3WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_l` = IFNULL(t.KLP4LAKI, 0),
		 	 r.`jumlah_pasien_hidup_mati_>1-<=4_tahun_p` = IFNULL(t.KLP4WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_l` = IFNULL(t.KLP5LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>4-<=14_tahun_p` = IFNULL(t.KLP5WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_l` = IFNULL(t.KLP6LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>14-<=24_tahun_p` = IFNULL(t.KLP6WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_l` = IFNULL(t.KLP7LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>24-<=44_tahun_p` = IFNULL(t.KLP7WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_l` = IFNULL(t.KLP8LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>44-<=64_tahun_p` = IFNULL(t.KLP8WANITA, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_l` = IFNULL(t.KLP9LAKI, 0),
			 r.`jumlah_pasien_hidup_mati_>64_tahun_p` = IFNULL(t.KLP9WANITA, 0),
			 r.`pasien_keluar_hidup_mati_l` = IFNULL(t.JMLLAKI, 0),
			 r.`pasien_keluar_hidup_mati_p` = IFNULL(t.JMLWANITA, 0),
			 r.`jumlah_pasien_keluar_hidup_mati` = IFNULL(t.JUMLAH, 0),
			 r.`jumlah_pasien_keluar_mati` = IFNULL(t.JMLMATI, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no_dtd` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL4B
DROP PROCEDURE IF EXISTS `ambilDataRL4B`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL4B`(
	IN `PTAHUN` YEAR
)
BEGIN	
   DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL4B;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL4B (
		TAHUN YEAR, 
		KODE CHAR(10), 
		ID SMALLINT(5), 
		NODAFTAR VARCHAR(200), 
		DESKRIPSI VARCHAR(200), 
		KLP1LAKI SMALLINT(5), 
		KLP1WANITA SMALLINT(5), 
		KLP2LAKI SMALLINT(5), 
		KLP2WANITA SMALLINT(5), 
		KLP3LAKI SMALLINT(5), 
		KLP3WANITA SMALLINT(5), 
		KLP4LAKI SMALLINT(5),
		KLP4WANITA SMALLINT(5), 
		KLP5LAKI SMALLINT(5), 
		KLP5WANITA SMALLINT(5), 
		KLP6LAKI SMALLINT(5), 
		KLP6WANITA SMALLINT(5), 
		KLP7LAKI SMALLINT(5), 
		KLP7WANITA SMALLINT(5), 
		KLP8LAKI SMALLINT(5), 
		KLP8WANITA SMALLINT(5), 
		KLP9LAKI SMALLINT(5), 
		KLP9WANITA SMALLINT(5), 
		LAKIBARU SMALLINT(5), 
		WANITABARU SMALLINT(5), 
		JMLBARU SMALLINT(5), 
		JUMLAH SMALLINT(5)
   	) ENGINE=MEMORY;
   	INSERT INTO TEMP_LAPORAN_RL4B 
   
	SELECT 
	-- INST.*, 
		PTAHUN TAHUN, rl.KODE, rl.ID, rl.NODAFTAR, rl.DESKRIPSI, KLP1LAKI, KLP1WANITA, KLP2LAKI, KLP2WANITA, KLP3LAKI, KLP3WANITA, KLP4LAKI,
		KLP4WANITA, KLP5LAKI, KLP5WANITA, KLP6LAKI, KLP6WANITA, KLP7LAKI, KLP7WANITA, KLP8LAKI, KLP8WANITA, KLP9LAKI, KLP9WANITA, LAKIBARU, WANITABARU, JMLBARU, JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
				--	(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, 
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, 
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100104' AND jrl.ID=3
		ORDER BY rl.ID;
		
	INSERT INTO 
				`kemkes-sirs`.`rl4b` (`tahun`,  `no_dtd`,  `no_urut`,  `no_daftar_terperinci`,  `golongan_sebab_penyakit`,  `0-<=6_hari_l`, `0-<=6_hari_p`, `>6-<=28_hari_l`, 
				`>6-<=28_hari_p`, `>28_hari-<=1_tahun_l`, `>28_hari-<=1_tahun_p`, `>1-<=4_tahun_l`, `>1-<=4_tahun_p`, `>4-<=14_tahun_l`, `>4-<=14_tahun_p`, `>14-<=24_tahun_l`, 
				`>14-<=24_tahun_p`, `>24-<=44_tahun_l`, `>24-<=44_tahun_p`, `>44-<=64_tahun_l`, `>44-<=64_tahun_p`, `>64_tahun_l`, `>64_tahun_p`, `kasus_baru_menurut_jenis_kelamain_l`, 
				`kasus_baru_menurut_jenis_kelamain_p`, `jumlah_kasus_baru`, `jumlah_kunjungan`)											
	SELECT TAHUN, KODE, ID, NODAFTAR, DESKRIPSI, 
			 IFNULL(KLP1LAKI, 0), IFNULL(KLP1WANITA, 0), 
			 IFNULL(KLP2LAKI, 0), IFNULL(KLP2WANITA, 0), 
			 IFNULL(KLP3LAKI, 0), IFNULL(KLP3WANITA, 0), 
			 IFNULL(KLP4LAKI, 0), IFNULL(KLP4WANITA, 0), 
			 IFNULL(KLP5LAKI, 0), IFNULL(KLP5WANITA, 0), 
			 IFNULL(KLP6LAKI, 0), IFNULL(KLP6WANITA, 0), 
			 IFNULL(KLP7LAKI, 0), IFNULL(KLP7WANITA, 0), 
			 IFNULL(KLP8LAKI, 0), IFNULL(KLP8WANITA, 0), 
			 IFNULL(KLP9LAKI, 0), IFNULL(KLP9WANITA, 0), 
			 IFNULL(LAKIBARU, 0), IFNULL(WANITABARU, 0), IFNULL(JMLBARU, 0), IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL4B t
	 WHERE NOT EXISTS (SELECT 1 FROM `kemkes-sirs`.`rl4b` r WHERE r.tahun = t.TAHUN AND r.`no_dtd` = t.KODE);

	UPDATE `kemkes-sirs`.`rl4b` r, TEMP_LAPORAN_RL4B t
	   SET r.`0-<=6_hari_l` = IFNULL(t.KLP1LAKI, 0),
		 	 r.`0-<=6_hari_p` = IFNULL(t.KLP1WANITA, 0),
			 r.`>6-<=28_hari_l` = IFNULL(t.KLP2LAKI, 0),
			 r.`>6-<=28_hari_p` = IFNULL(t.KLP2WANITA, 0),
			 r.`>28_hari-<=1_tahun_l` = IFNULL(t.KLP3LAKI, 0),
			 r.`>28_hari-<=1_tahun_p` = IFNULL(t.KLP3WANITA, 0),
			 r.`>1-<=4_tahun_l` = IFNULL(t.KLP4LAKI, 0),
			 r.`>1-<=4_tahun_p` = IFNULL(t.KLP4WANITA, 0),
			 r.`>4-<=14_tahun_l` = IFNULL(t.KLP5LAKI, 0),
			 r.`>4-<=14_tahun_p` = IFNULL(t.KLP5WANITA, 0),
			 r.`>14-<=24_tahun_l` = IFNULL(t.KLP6LAKI, 0),
			 r.`>14-<=24_tahun_p` = IFNULL(t.KLP6WANITA, 0),
			 r.`>24-<=44_tahun_l` = IFNULL(t.KLP7LAKI, 0),
			 r.`>24-<=44_tahun_p` = IFNULL(t.KLP7WANITA, 0),
			 r.`>44-<=64_tahun_l` = IFNULL(t.KLP8LAKI, 0),
			 r.`>44-<=64_tahun_p` = IFNULL(t.KLP8WANITA, 0),
			 r.`>64_tahun_l` = IFNULL(t.KLP9LAKI, 0),
			 r.`>64_tahun_p` = IFNULL(t.KLP9WANITA, 0),
			 r.`kasus_baru_menurut_jenis_kelamain_l` = IFNULL(t.LAKIBARU, 0),
			 r.`kasus_baru_menurut_jenis_kelamain_p` = IFNULL(t.WANITABARU, 0),
			 r.`jumlah_kasus_baru` = IFNULL(t.JMLBARU, 0),
			 r.`jumlah_kunjungan` = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no_dtd` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL4BSebab
DROP PROCEDURE IF EXISTS `ambilDataRL4BSebab`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL4BSebab`(
	IN `PTAHUN` YEAR
)
BEGIN	
    DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL4BSEBAB;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL4BSEBAB (
		TAHUN YEAR, 
		KODE CHAR(10), 
		ID SMALLINT(5), 
		NODAFTAR VARCHAR(200), 
		DESKRIPSI VARCHAR(200), 
		KLP1LAKI SMALLINT(5), 
		KLP1WANITA SMALLINT(5), 
		KLP2LAKI SMALLINT(5), 
		KLP2WANITA SMALLINT(5), 
		KLP3LAKI SMALLINT(5), 
		KLP3WANITA SMALLINT(5), 
		KLP4LAKI SMALLINT(5),
		KLP4WANITA SMALLINT(5), 
		KLP5LAKI SMALLINT(5), 
		KLP5WANITA SMALLINT(5), 
		KLP6LAKI SMALLINT(5), 
		KLP6WANITA SMALLINT(5), 
		KLP7LAKI SMALLINT(5), 
		KLP7WANITA SMALLINT(5), 
		KLP8LAKI SMALLINT(5), 
		KLP8WANITA SMALLINT(5), 
		KLP9LAKI SMALLINT(5), 
		KLP9WANITA SMALLINT(5), 
		LAKIBARU SMALLINT(5), 
		WANITABARU SMALLINT(5), 
		JMLBARU SMALLINT(5), 
		JUMLAH SMALLINT(5)
   	) ENGINE=MEMORY;
   	INSERT INTO TEMP_LAPORAN_RL4BSEBAB 
   	
		SELECT 
			-- INST.*, 
		PTAHUN TAHUN, rl.KODE, rl.ID, rl.NODAFTAR, rl.DESKRIPSI, KLP1LAKI, KLP1WANITA, KLP2LAKI, KLP2WANITA, KLP3LAKI, KLP3WANITA, KLP4LAKI,
		KLP4WANITA, KLP5LAKI, KLP5WANITA, KLP6LAKI, KLP6WANITA, KLP7LAKI, KLP7WANITA, KLP8LAKI, KLP8WANITA, KLP9LAKI, KLP9WANITA, LAKIBARU, WANITABARU, JMLBARU, JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  LEFT JOIN (SELECT md.KODE KODEICD10, ic.IDRL4AB,
	--				(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, 
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, 
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=1,1,0)) KLP1WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=2,1,0)) KLP2WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=3,1,0)) KLP3WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=4,1,0)) KLP4WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=5,1,0)) KLP5WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=6,1,0)) KLP6WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=7,1,0)) KLP7WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=8,1,0)) KLP8WANITA,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9LAKI,
					 SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1 AND master.getKelompokUmur(pp.TANGGAL, ps.TANGGAL_LAHIR)=9,1,0)) KLP9WANITA
			FROM pendaftaran.kunjungan pk
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
				  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
				  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
				  pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
				  medicalrecord.diagnosa md,
				  pendaftaran.tujuan_pasien tp,
				  master.rl4_icd10 ic
			WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
				AND r.JENIS_KUNJUNGAN IN (1,2) AND md.KODE=ic.KODE
				AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
			GROUP BY ic.IDRL4AB
			  ) b ON b.IDRL4AB=rl.ID
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100104' AND jrl.ID=4
		ORDER BY rl.ID;
		
	INSERT INTO 
				`kemkes-sirs`.`rl4b-sebab` (`tahun`,  `no_dtd`,  `no._urut`,  `no_daftar_terperinci`,  `golongan_sebab_penyakit`,  `0-<=6_hari_l`, `0-<=6_hari_p`, `>6-<=28_hari_l`, 
				`>6-<=28_hari_p`, `>28_hari-<=1_tahun_l`, `>28_hari-<=1_tahun_p`, `>1-<=4_tahun_l`, `>1-<=4_tahun_p`, `>4-<=14_tahun_l`, `>4-<=14_tahun_p`, `>14-<=24_tahun_l`, 
				`>14-<=24_tahun_p`, `>24-<=44_tahun_l`, `>24-<=44_tahun_p`, `>44-<=64_tahun_l`, `>44-<=64_tahun_p`, `>64_tahun_l`, `>64_tahun_p`, `kasus_baru_menurut_jenis_kelamain_l`, 
				`kasus_baru_menurut_jenis_kelamain_p`, `jumlah_kasus_baru`, `jumlah_kunjungan`)											
	SELECT TAHUN, KODE, ID, NODAFTAR, DESKRIPSI, 
			 IFNULL(KLP1LAKI, 0), IFNULL(KLP1WANITA, 0), 
			 IFNULL(KLP2LAKI, 0), IFNULL(KLP2WANITA, 0), 
			 IFNULL(KLP3LAKI, 0), IFNULL(KLP3WANITA, 0), 
			 IFNULL(KLP4LAKI, 0), IFNULL(KLP4WANITA, 0), 
			 IFNULL(KLP5LAKI, 0), IFNULL(KLP5WANITA, 0), 
			 IFNULL(KLP6LAKI, 0), IFNULL(KLP6WANITA, 0), 
			 IFNULL(KLP7LAKI, 0), IFNULL(KLP7WANITA, 0), 
			 IFNULL(KLP8LAKI, 0), IFNULL(KLP8WANITA, 0), 
			 IFNULL(KLP9LAKI, 0), IFNULL(KLP9WANITA, 0), 
			 IFNULL(LAKIBARU, 0), IFNULL(WANITABARU, 0), IFNULL(JMLBARU, 0), IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL4BSEBAB t
	 WHERE NOT EXISTS (SELECT 1 FROM `kemkes-sirs`.`rl4b-sebab` r WHERE r.tahun = t.TAHUN AND r.`no_dtd` = t.KODE);

	UPDATE `kemkes-sirs`.`rl4b-sebab` r, TEMP_LAPORAN_RL4BSEBAB t
	   SET r.`0-<=6_hari_l` = IFNULL(t.KLP1LAKI, 0),
			 r.`0-<=6_hari_p` = IFNULL(t.KLP1WANITA, 0),
			 r.`>6-<=28_hari_l` = IFNULL(t.KLP2LAKI, 0),
			 r.`>6-<=28_hari_p` = IFNULL(t.KLP2WANITA, 0),
			 r.`>28_hari-<=1_tahun_l` = IFNULL(t.KLP3LAKI, 0),
			 r.`>28_hari-<=1_tahun_p` = IFNULL(t.KLP3WANITA, 0),
		 	 r.`>1-<=4_tahun_l` = IFNULL(t.KLP4LAKI, 0),
			 r.`>1-<=4_tahun_p` = IFNULL(t.KLP4WANITA, 0),
			 r.`>4-<=14_tahun_l` = IFNULL(t.KLP5LAKI, 0),
			 r.`>4-<=14_tahun_p` = IFNULL(t.KLP5WANITA, 0),
			 r.`>14-<=24_tahun_l` = IFNULL(t.KLP6LAKI, 0),
			 r.`>14-<=24_tahun_p` = IFNULL(t.KLP6WANITA, 0),
			 r.`>24-<=44_tahun_l` = IFNULL(t.KLP7LAKI, 0),
			 r.`>24-<=44_tahun_p` = IFNULL(t.KLP7WANITA, 0),
			 r.`>44-<=64_tahun_l` = IFNULL(t.KLP8LAKI, 0),
			 r.`>44-<=64_tahun_p` = IFNULL(t.KLP8WANITA, 0),
			 r.`>64_tahun_l` = IFNULL(t.KLP9LAKI, 0),
			 r.`>64_tahun_p` = IFNULL(t.KLP9WANITA, 0),
			 r.`kasus_baru_menurut_jenis_kelamain_l` = IFNULL(t.LAKIBARU, 0),
			 r.`kasus_baru_menurut_jenis_kelamain_p` = IFNULL(t.WANITABARU, 0),
			 r.`jumlah_kasus_baru` = IFNULL(t.JMLBARU, 0),
			 r.`jumlah_kunjungan` = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.`no_dtd` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL51
DROP PROCEDURE IF EXISTS `ambilDataRL51`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL51`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL51;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL51 ENGINE=MEMORY
	SELECT tgl.TAHUN, tgl.BULAN, DESKBULAN, ref.ID, CONCAT('Pengunjung ',ref.DESKRIPSI) DESKRIPSI, JUMLAH
   FROM master.referensi ref
      INNER JOIN (SELECT YEAR(TANGGAL) TAHUN, MONTH(TANGGAL) BULAN, `master`.getBulanIndo(TANGGAL) DESKBULAN
             FROM master.tanggal WHERE TANGGAL BETWEEN TGLAWAL AND TGLAKHIR 
          GROUP BY DATE_FORMAT(TANGGAL,'%Y-%m')) tgl
      LEFT JOIN (
         SELECT YEAR(tk.MASUK) TAHUN, MONTH(tk.MASUK) BULAN, IF(DATE_FORMAT(p.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(tk.MASUK,'%d-%m-%Y'),1,2) IDSTATUSPENGUNJUNG
           , COUNT(pd.NOMOR) JUMLAH
         FROM master.pasien p
           , pendaftaran.pendaftaran pd
           , pendaftaran.tujuan_pasien tp
             LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
           , pendaftaran.kunjungan tk
         WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2)
            AND tk.RUANGAN=r.ID AND tk.MASUK BETWEEN TGLAWAL AND TGLAKHIR
            AND r.JENIS_KUNJUNGAN=1
         GROUP BY DATE_FORMAT(tk.MASUK,'%Y-%m'), IF(DATE_FORMAT(p.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(tk.MASUK,'%d-%m-%Y'),1,2) ) a ON a.IDSTATUSPENGUNJUNG=ref.ID AND a.TAHUN=tgl.TAHUN AND a.BULAN=tgl.BULAN
     , (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=1 AND jk.JENIS=15) jk
   WHERE ref.JENIS=22
   GROUP BY tgl.TAHUN, tgl.BULAN,ID
   ORDER BY tgl.TAHUN, tgl.BULAN,ID;
	
	INSERT INTO `kemkes-sirs`.`rl5-1` (tahun, bulan, `no`, jenis_kegiatan, jumlah)											
	SELECT TAHUN, DESKBULAN, ID, DESKRIPSI, IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL51 t
	WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl5-1` r WHERE r.tahun = t.TAHUN AND r.bulan = t.DESKBULAN AND r.`no` = t.ID);

	UPDATE `kemkes-sirs`.`rl5-1` r, TEMP_LAPORAN_RL51 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.bulan = t.DESKBULAN 
		AND r.`no` = t.ID;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL52
DROP PROCEDURE IF EXISTS `ambilDataRL52`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL52`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL52;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL52 ENGINE=MEMORY
	
	SELECT tgl.TAHUN, tgl.BULAN, DESKBULAN , rl.KODE, rl.DESKRIPSI, JUMLAH
		FROM master.jenis_laporan_detil jrl
			, master.refrl rl
			  INNER JOIN (SELECT YEAR(TANGGAL) TAHUN, MONTH(TANGGAL) BULAN, master.getBulanIndo(TANGGAL) DESKBULAN 
	  							 FROM master.tanggal WHERE TANGGAL BETWEEN TGLAWAL AND TGLAKHIR 
							GROUP BY DATE_FORMAT(TANGGAL,'%Y-%m')) tgl
			  LEFT JOIN (SELECT YEAR(tk.MASUK) TAHUN, MONTH(tk.MASUK) BULAN, rl.RL52, COUNT(pd.NOMOR) JUMLAH
			  					   , SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKI
			  					   , SUM(IF(p.JENIS_KELAMIN!=1,1,0)) PR
								FROM master.pasien p
									, pendaftaran.pendaftaran pd
									  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
									  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
									  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
									  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
								  	, pendaftaran.kunjungan tk
									, master.ruangan jkr
									, pendaftaran.tujuan_pasien tps
									, master.rl52_ruangan rl
								WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=1
										AND tk.MASUK BETWEEN TGLAWAL AND TGLAKHIR  AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
										AND pd.NOMOR=tps.NOPEN 
										AND IF(LENGTH(rl.ID)=9,tk.RUANGAN=rl.ID,tps.SMF=rl.ID)
								GROUP BY DATE_FORMAT(tk.MASUK,'%Y-%m'),rl.RL52
								UNION
								SELECT YEAR(tk.MASUK) TAHUN, MONTH(tk.MASUK) BULAN, 24 RL52, COUNT(pd.NOMOR) JUMLAH
										, SUM(IF(p.JENIS_KELAMIN=1,1,0)) LAKI
			  					      , SUM(IF(p.JENIS_KELAMIN!=1,1,0)) PR
									FROM master.pasien p
										, pendaftaran.pendaftaran pd
										  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
										  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
										  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
										  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
								   	, pendaftaran.kunjungan tk
										, master.ruangan jkr
									WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=2
											AND tk.MASUK BETWEEN TGLAWAL AND TGLAKHIR  AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
									GROUP BY DATE_FORMAT(tk.MASUK,'%Y-%m')) b ON b.RL52=rl.ID AND b.TAHUN=tgl.TAHUN AND b.BULAN=tgl.BULAN
			, (SELECT p.KODE KODERS, p.NAMA NAMAINST, p.WILAYAH KODEPROP, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		WHERE jrl.JENIS=rl.JENISRL AND jrl.ID=rl.IDJENISRL
		  AND jrl.JENIS='100105' AND jrl.ID=2 AND rl.KODE!='99'
		ORDER BY TAHUN, BULAN, rl.ID;
		
	INSERT INTO `kemkes-sirs`.`rl5-2` (tahun, bulan, `no`, jenis_kegiatan, jumlah)											
	SELECT TAHUN, DESKBULAN, KODE, DESKRIPSI, IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL52 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl5-2` r WHERE r.tahun = t.TAHUN AND r.bulan = t.DESKBULAN AND r.`no` = t.KODE);
	
	UPDATE `kemkes-sirs`.`rl5-2` r, TEMP_LAPORAN_RL52 t
	   SET r.jumlah = IFNULL(t.JUMLAH, 0)
	 WHERE r.tahun = t.TAHUN 
	   AND r.bulan = t.DESKBULAN
		AND r.`no` = t.KODE;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL53
DROP PROCEDURE IF EXISTS `ambilDataRL53`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL53`(
	IN `PTAHUN` YEAR
)
BEGIN
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	SET @urut = 0;
	SET @lap = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL53;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL53 (
		TAHUN YEAR, 
		BULAN SMALLINT(5), 
		DESKBULAN CHAR(10), 
		KODEICD10 CHAR(6), 
		NOURUT TINYINT(3), 
		DIAGNOSA VARCHAR(200), 
		LAKIHIDUP SMALLINT(5), 
		WANITAHIDUP SMALLINT(5), 
		LAKIMATI SMALLINT(5), 
		WANITAMATI SMALLINT(5), 
		JUMLAH SMALLINT(5)
   	) ENGINE=MEMORY;
	INSERT INTO TEMP_LAPORAN_RL53 	
	SELECT TAHUN, BULAN, DESKBULAN, KODEICD10, NOURUT, DIAGNOSA, LAKIHIDUP, WANITAHIDUP, LAKIMATI, WANITAMATI, JUMLAH
	FROM (
		SELECT TAHUN, BULAN, DESKBULAN, BULANLAPORAN, IF(@lap<>BULANLAPORAN,@urut:=1,@urut:=@urut+1) NOURUT, @lap:=BULANLAPORAN LAP,
				KODEICD10, DIAGNOSA, LAKIHIDUP, WANITAHIDUP, LAKIMATI, WANITAMATI, JUMLAH
		FROM (
			SELECT YEAR(lpp.TANGGAL) TAHUN, MONTH(lpp.TANGGAL) BULAN, master.getBulanIndo(lpp.TANGGAL) DESKBULAN, DATE_FORMAT(lpp.TANGGAL,'%Y-%m') BULANLAPORAN, md.KODE KODEICD10,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND lpp.CARA NOT IN (6,7),1,0)) LAKIHIDUP, SUM(IF(ps.JENIS_KELAMIN=2 AND lpp.CARA NOT IN (6,7),1,0)) WANITAHIDUP,
					 SUM(IF(ps.JENIS_KELAMIN=1 AND lpp.CARA IN (6,7),1,0)) LAKIMATI, SUM(IF(ps.JENIS_KELAMIN=2 AND lpp.CARA IN (6,7),1,0)) WANITAMATI,
					 SUM(IF(ps.JENIS_KELAMIN=1,1,0)) JMLLAKI, 
					 SUM(IF(ps.JENIS_KELAMIN=2,1,0)) JMLWANITA, 
					 SUM(IF(lpp.CARA IN (6,7),1,0)) JMLMATI
				FROM pendaftaran.kunjungan pk
					  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
					  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
					  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
					  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
					  medicalrecord.diagnosa md,
					  pendaftaran.tujuan_pasien tp
				WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
					AND r.JENIS_KUNJUNGAN=3
					AND pk.NOPEN=pp.NOMOR AND lpp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR 
					AND LEFT(md.KODE,1) NOT IN ('Z','O','','R','V','W','Y')
				GROUP BY DATE_FORMAT(lpp.TANGGAL,'%Y-%m'), md.KODE
				ORDER BY DATE_FORMAT(lpp.TANGGAL,'%Y-%m'), JUMLAH
				) ab
		) cd
	WHERE NOURUT <=10
	ORDER BY TAHUN, BULAN, NOURUT;

	INSERT INTO `kemkes-sirs`.`rl5-3` (tahun, bulan, `kode_icd_10`, `no_urut`, deskripsi, `pasien_keluar_hidup_menurut_jenis_kelamin_l`, `pasien_keluar_hidup_menurut_jenis_kelamin_p`,
					`pasien_keluar_mati_menurut_jenis_kelamin_l`, `pasien_keluar_mati_menurut_jenis_kelamin_p`, `total_all`)											
	SELECT TAHUN, DESKBULAN, KODEICD10, NOURUT, DIAGNOSA, LAKIHIDUP, WANITAHIDUP, LAKIMATI, WANITAMATI, JUMLAH
  	  FROM TEMP_LAPORAN_RL53 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl5-3` r WHERE r.tahun = t.TAHUN AND r.bulan = t.DESKBULAN AND r.`no_urut` = t.NOURUT);
		
	UPDATE `kemkes-sirs`.`rl5-3` r, TEMP_LAPORAN_RL53 t
	   SET r.kode_icd_10 = t.KODEICD10,
	  		 r.deskripsi = t.DIAGNOSA,
	  		 r.pasien_keluar_hidup_menurut_jenis_kelamin_l = t.LAKIHIDUP,
	  		 r.pasien_keluar_hidup_menurut_jenis_kelamin_p = t.WANITAHIDUP,
	  		 r.pasien_keluar_mati_menurut_jenis_kelamin_l = t.LAKIMATI,
	  		 r.pasien_keluar_mati_menurut_jenis_kelamin_p = t.WANITAMATI,
	  		 r.total_all = t.JUMLAH	  
	 WHERE r.tahun = t.TAHUN 
	   AND r.bulan = t.DESKBULAN 
		AND r.`no_urut` = t.NOURUT;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-sirs.ambilDataRL54
DROP PROCEDURE IF EXISTS `ambilDataRL54`;
DELIMITER //
CREATE PROCEDURE `ambilDataRL54`(
	IN `PTAHUN` YEAR
)
BEGIN	
	DECLARE TGLAWAL DATETIME;
	DECLARE TGLAKHIR DATETIME;
	SET TGLAWAL = CONCAT(PTAHUN, '-01-01 00:00:01');
	SET TGLAKHIR = CONCAT(PTAHUN, '-12-31 23:59:59');
	SET @urut = 0;
	SET @lap = NULL;
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_LAPORAN_RL54;
	CREATE TEMPORARY TABLE TEMP_LAPORAN_RL54 (
		TAHUN YEAR, 
		BULAN SMALLINT(5), 
		DESKBULAN CHAR(10), 
		KODEICD10 CHAR(6), 
		NOURUT TINYINT(3), 
		DIAGNOSA VARCHAR(200), 
		LAKIBARU SMALLINT(5), 
		WANITABARU SMALLINT(5), 
		JMLBARU SMALLINT(5), 
		JUMLAH SMALLINT(5)
   	) ENGINE=MEMORY;
	INSERT INTO TEMP_LAPORAN_RL54
	SELECT TAHUN, BULAN, DESKBULAN,KODEICD10, NOURUT, DIAGNOSA, LAKIBARU, WANITABARU, JMLBARU, JUMLAH
	 FROM (
		SELECT TAHUN, BULAN, DESKBULAN,BULANLAPORAN, IF(@lap<>BULANLAPORAN,@urut:=1,@urut:=@urut+1) NOURUT, @lap:=BULANLAPORAN LAP,
				 KODEICD10, DIAGNOSA, LAKIBARU, WANITABARU, JMLBARU, JUMLAH
			FROM (
				SELECT YEAR(pp.TANGGAL) TAHUN, MONTH(pp.TANGGAL) BULAN, master.getBulanIndo(pp.TANGGAL) DESKBULAN, DATE_FORMAT(pp.TANGGAL,'%Y-%m') BULANLAPORAN, md.KODE KODEICD10,
					(SELECT ms.STR FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=md.KODE LIMIT 1) DIAGNOSA, 
					 COUNT(md.KODE) JUMLAH, SUM(IF(ps.JENIS_KELAMIN=1 AND md.BARU=1,1,0)) LAKIBARU, SUM(IF(ps.JENIS_KELAMIN=2 AND md.BARU=1,1,0)) WANITABARU,
					 SUM(IF(md.BARU=1,1,0)) JMLBARU
				FROM pendaftaran.kunjungan pk
					  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
					  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1
					  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
					  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
					  medicalrecord.diagnosa md,
					  pendaftaran.tujuan_pasien tp
				WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
					AND r.JENIS_KUNJUNGAN IN (1,2)
					AND pk.NOPEN=pp.NOMOR AND pp.TANGGAL BETWEEN TGLAWAL AND TGLAKHIR
					AND LEFT(md.KODE,1) NOT IN ('Z','O','','R','V','W','Y')
				GROUP BY DATE_FORMAT(pp.TANGGAL,'%Y-%m'), md.KODE
				ORDER BY DATE_FORMAT(pp.TANGGAL,'%Y-%m'), JUMLAH
				) ab
		) cd
	 WHERE NOURUT <= 10
	 ORDER BY TAHUN, BULAN, NOURUT;

	INSERT INTO `kemkes-sirs`.`rl5-4` (tahun, bulan, `kode_icd_10`, `no_urut`, deskripsi, `kasus_baru_menurut_jenis_kelamin_l`, `kasus_baru_menurut_jenis_kelamin_p`,
					`jumlah_kasus_baru`, `jumlah_kunjungan`)
	SELECT TAHUN, DESKBULAN, KODEICD10, NOURUT, DIAGNOSA, 
			 IFNULL(LAKIBARU, 0), IFNULL(WANITABARU, 0), 
			 IFNULL(JMLBARU, 0), IFNULL(JUMLAH, 0)
  	  FROM TEMP_LAPORAN_RL54 t
	 WHERE NOT EXISTS(SELECT 1 FROM `kemkes-sirs`.`rl5-4` r WHERE r.tahun = t.TAHUN AND r.bulan = t.DESKBULAN AND r.`no_urut` = t.NOURUT);
	
	UPDATE `kemkes-sirs`.`rl5-4` r, TEMP_LAPORAN_RL54 t
	   SET r.kode_icd_10 = t.KODEICD10,
	  		 r.deskripsi = t.DIAGNOSA,
	  		 r.kasus_baru_menurut_jenis_kelamin_l = IFNULL(t.LAKIBARU, 0),
	  		 r.kasus_baru_menurut_jenis_kelamin_p = IFNULL(t.WANITABARU, 0),
	  		 r.jumlah_kasus_baru = IFNULL(t.JMLBARU, 0),
	  		 r.jumlah_kunjungan = IFNULL(t.JUMLAH, 0)		  
	 WHERE r.tahun = t.TAHUN 
	   AND r.bulan = t.DESKBULAN 
		AND r.`no_urut` = t.NOURUT;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
