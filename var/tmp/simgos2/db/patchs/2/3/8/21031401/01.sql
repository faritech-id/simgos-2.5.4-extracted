-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk informasi
USE `informasi`;

-- membuang struktur untuk procedure informasi.infoKetersediaanTempatTidur
DROP PROCEDURE IF EXISTS `infoKetersediaanTempatTidur`;
DELIMITER //
CREATE PROCEDURE `infoKetersediaanTempatTidur`()
BEGIN
	SET @sqlText = CONCAT('
	SELECT rkls.DESKRIPSI KAMAR
	, SUM(IF(rkt.STATUS_ID=1,1,0)) KOSONG, SUM(IF(rkt.STATUS_ID=1,0,1)) TERISI
	, (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) TOTAL
		  FROM (
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 1	 
		UNION	
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.STATUS = 1
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 2
		UNION		 
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 3
		   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
		   AND k.KELUAR IS NULL
	) rkt
	LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR 
	LEFT JOIN master.referensi rkls ON rk.KELAS = rkls.ID AND rkls.JENIS = 19
	LEFT JOIN master.ruangan rgn On rgn.ID = rk.RUANGAN
	WHERE NOT rkt.STATUS_ID IN (0)
	  AND rgn.STATUS = 1 
	  AND rkls.ID IS NOT NULL
	  AND rk.STATUS = 1
	  AND rgn.JENIS_KUNJUNGAN = 3
	GROUP BY rk.KELAS
	ORDER BY rkls.DESKRIPSI ASC');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure informasi.infoRuangKamar
DROP PROCEDURE IF EXISTS `infoRuangKamar`;
DELIMITER //
CREATE PROCEDURE `infoRuangKamar`(
	IN `PRUANGAN` LONGTEXT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT r.ID ID_RUANGAN, ru.DESKRIPSI NM_RUANGAN, r.KAMAR NM_KAMAR, ref.DESKRIPSI NM_KELAS
		  FROM master.ruang_kamar r
		       , master.ruang_kamar_tidur rkt
				 , master.referensi ref
				 , master.ruangan ru
		 WHERE rkt.RUANG_KAMAR = r.ID 
		   AND ru.ID = r.RUANGAN 
			AND ref.ID = r.KELAS 
			AND ref.JENIS = 19 
			AND rkt.STATUS NOT IN (0) 
			AND r.STATUS=1 
			AND r.RUANGAN IN (',PRUANGAN,')
		GROUP BY r.ID ORDER BY ru.DESKRIPSI');		
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure informasi.infoRuangKamarTidur
DROP PROCEDURE IF EXISTS `infoRuangKamarTidur`;
DELIMITER //
CREATE PROCEDURE `infoRuangKamarTidur`(
	IN `PRUANGAN` LONGTEXT
)
BEGIN	
	SET @sqlText = CONCAT('
		SELECT rkt.ID, rk.ID KAMAR_ID, rkls.DESKRIPSI KAMAR
	          , SUM(IF(rkt.STATUS_ID=1,1,0)) KOSONG, SUM(IF(rkt.STATUS_ID=1,0,1)) TERISI
	          , (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) TOTAL
	          , ROUND((SUM(IF(rkt.STATUS_ID=1,1,0)) / (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) * 100),0) PERC_KOSONG
	          , ROUND((SUM(IF(rkt.STATUS_ID=1,0,1)) / (SUM(IF(rkt.STATUS_ID=1,1,0)) + SUM(IF(rkt.STATUS_ID=1,0,1))) * 100),0) PERC_TERISI
	          , rs.DESKRIPSI STATUS
		  FROM (
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 1	 
		UNION	
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.STATUS = 1
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 2
		UNION		 
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, rkt.STATUS STATUS_ID
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM
		 WHERE NOT rkt.STATUS IN (0)
		   AND rkt.STATUS = 3
		   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
		   AND k.KELUAR IS NULL
	) rkt
	LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR AND rk.RUANGAN IN (',PRUANGAN,')
	LEFT JOIN master.referensi rkls ON rk.KELAS = rkls.ID AND rkls.JENIS = 19
	LEFT JOIN master.ruangan rgn On rgn.ID = rk.RUANGAN
	LEFT JOIN master.referensi rs ON rs.JENIS = 20 AND rs.ID = rkt.STATUS_ID 
	WHERE NOT rkt.STATUS_ID IN (0)
	  AND rgn.STATUS = 1 
	  AND rkls.ID IS NOT NULL
	  AND rk.STATUS = 1
	  AND rgn.JENIS_KUNJUNGAN = 3
	GROUP BY rk.KELAS
	ORDER BY rkls.DESKRIPSI ASC');
		
	 PREPARE stmt FROM @sqlText;
	 EXECUTE stmt;
	 DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure informasi.InfoRuangKamarTidurDetil
DROP PROCEDURE IF EXISTS `InfoRuangKamarTidurDetil`;
DELIMITER //
CREATE PROCEDURE `InfoRuangKamarTidurDetil`(
	IN `PKAMAR` LONGTEXT
)
BEGIN
	SELECT *
			 , IF(rkt.JK = 1, 'laki', 
			 		IF(rkt.JK = 2, 'perempuan', 
					 	IF(rkt.JK IS NULL AND rkt.STATUS_INFO = 'Terisi', 'laki', 'kosong')
					)
				) BED_STATUS
			, if(rkt.STATUS_INFO = 'Kosong', '#FFF', '#878ea2') COLOR
	 FROM (
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, NULL NAMA, NULL JK, 'bed_putih' STATUS_BED, 'Kosong' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		 WHERE rkt.STATUS = 1	 
		UNION	
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, r.ATAS_NAMA NAMA, NULL JK, 'bed_hitam' STATUS_BED, 'Terisi' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.STATUS = 1
		 WHERE rkt.STATUS = 2
		UNION		 
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, ps.NORM, CONCAT(IF(ps.GELAR_DEPAN = '' OR ps.GELAR_DEPAN IS NULL, '', CONCAT(ps.GELAR_DEPAN, '. ')),UPPER(ps.NAMA), IF(ps.GELAR_BELAKANG = '' OR ps.GELAR_BELAKANG IS NULL, '', CONCAT(', ', ps.GELAR_BELAKANG))) NAMA
		, ps.JENIS_KELAMIN JK, 'bed_hitam' STATUS_NM, 'Terisi' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM  		 
		 WHERE rkt.STATUS = 3
		   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
			AND k.KELUAR IS NULL		
	) rkt WHERE rkt.RUANG_KAMAR IN (PKAMAR);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
