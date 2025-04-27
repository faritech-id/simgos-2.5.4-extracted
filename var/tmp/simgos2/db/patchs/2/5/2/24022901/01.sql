-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk function pendaftaran.getPendaftaranAsal
DROP FUNCTION IF EXISTS `getPendaftaranAsal`;
DELIMITER //
CREATE FUNCTION `getPendaftaranAsal`(
	`PKUNJUNGAN_NOMOR` CHAR(19),
	`PPENJAMIN_ID` SMALLINT,
	`PRUANGAN_ID` CHAR(10)
) RETURNS json
    DETERMINISTIC
BEGIN
	DECLARE VNORM INT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VSEP CHAR(25) DEFAULT '';
	DECLARE VRUJUKAN_NOMOR CHAR(25);
	DECLARE VRUJUKAN_TANGGAL DATE;
	DECLARE VRUJUKAN_EXPIRE SMALLINT;
	DECLARE VPPK INT;
	DECLARE VPENDAFTARAN_NOMOR CHAR(10);
	DECLARE VPASCA_RAWAT_INAP TINYINT DEFAULT 0;
	
	SELECT i.PPK
	  INTO VPPK
	  FROM aplikasi.instansi i
	 LIMIT 1;
	
	SELECT p2.NORM, p2.TANGGAL
	  INTO VNORM, VTANGGAL
	  FROM pendaftaran.kunjungan k,
	       pendaftaran.pendaftaran p,
	       pendaftaran.surat_rujukan_pasien srp,
	       pendaftaran.penjamin pj,
	       pendaftaran.pendaftaran p2
	 WHERE k.NOMOR = PKUNJUNGAN_NOMOR
	   AND p.NOMOR = k.NOPEN
	   AND srp.ID = p.RUJUKAN
		AND srp.PPK = VPPK
		AND pj.JENIS = PPENJAMIN_ID
		AND pj.NOMOR = srp.NOMOR
		AND p2.NOMOR = pj.NOPEN
	LIMIT 1;
   
   IF NOT VNORM IS NULL THEN
   	SET VPASCA_RAWAT_INAP = 1;
   	
		SELECT p.NOMOR, pj.NOMOR, srp.NOMOR, srp.TANGGAL, DATEDIFF(DATE(NOW()), srp.TANGGAL)
		  INTO VPENDAFTARAN_NOMOR, VSEP, VRUJUKAN_NOMOR, VRUJUKAN_TANGGAL, VRUJUKAN_EXPIRE
		  FROM pendaftaran.pendaftaran p,
		  	    pendaftaran.penjamin pj,
		  	    pendaftaran.tujuan_pasien tp,
		  	    pendaftaran.surat_rujukan_pasien srp,
		  	    `master`.ruangan r
		 WHERE p.NORM = VNORM
		   AND p.TANGGAL < VTANGGAL
		   AND p.`STATUS` IN (1, 2)
		   AND pj.NOPEN = p.NOMOR
		   AND pj.JENIS = PPENJAMIN_ID
		   AND tp.NOPEN = p.NOMOR
		   AND tp.RUANGAN = PRUANGAN_ID
			AND srp.ID = p.RUJUKAN
		   AND r.ID = tp.RUANGAN
		   AND r.JENIS_KUNJUNGAN = 1
		 ORDER BY p.TANGGAL DESC
		 LIMIT 1;
		
		IF VSEP IS NULL THEN
			SELECT p.NOMOR, pj.NOMOR, srp.NOMOR, srp.TANGGAL, DATEDIFF(DATE(NOW()), srp.TANGGAL)
			  INTO VPENDAFTARAN_NOMOR, VSEP, VRUJUKAN_NOMOR, VRUJUKAN_TANGGAL, VRUJUKAN_EXPIRE
			  FROM pendaftaran.pendaftaran p,
			  	    pendaftaran.penjamin pj,
			  	    pendaftaran.tujuan_pasien tp,
			  	    pendaftaran.surat_rujukan_pasien srp,
			  	    `master`.ruangan r
			 WHERE p.NORM = VNORM
			   AND p.TANGGAL < VTANGGAL
			   AND p.`STATUS` IN (1, 2)
			   AND pj.NOPEN = p.NOMOR
			   AND pj.JENIS = PPENJAMIN_ID
			   AND tp.NOPEN = p.NOMOR
			   AND srp.ID = p.RUJUKAN
			   AND r.ID = tp.RUANGAN
			   AND r.JENIS_KUNJUNGAN = 1
			   AND NOT r.ID IN (PRUANGAN)
			 ORDER BY p.TANGGAL DESC
			 LIMIT 1;
		END IF;
	END IF;
 
	RETURN JSON_OBJECT(
		'PASCA_RAWAT_INAP', VPASCA_RAWAT_INAP,
	   'PENDAFTARAN_NOMOR', VPENDAFTARAN_NOMOR,
		'SEP_NOMOR', VSEP,
		'RUJUKAN_NOMOR', VRUJUKAN_NOMOR,
		'RUJUKAN_TANGGAL', VRUJUKAN_TANGGAL,
		'RUJUKAN_EXPIRE', IF(VRUJUKAN_EXPIRE <= 90, 0, 1)
	);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
