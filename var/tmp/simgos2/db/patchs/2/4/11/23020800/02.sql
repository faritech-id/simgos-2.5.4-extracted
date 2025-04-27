-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk procedure layanan.storeNilaiKritisLab
DROP PROCEDURE IF EXISTS `storeNilaiKritisLab`;
DELIMITER //
CREATE PROCEDURE `storeNilaiKritisLab`(
	IN `PIDHASILLAB` CHAR(12)
)
BEGIN
	DECLARE VPARAMETER, VKELAMIN, VJ_KUNJUNGAN, VUMUR INT;
	DECLARE VHASIL DECIMAL(10,2);
	
	SELECT
		hl.PARAMETER_TINDAKAN
		, hl.HASIL
		, psn.JENIS_KELAMIN
		, rgn.JENIS_KUNJUNGAN
		, DATEDIFF(pdf.TANGGAL, psn.TANGGAL_LAHIR)
	INTO
		VPARAMETER
		, VHASIL
		, VKELAMIN
		, VJ_KUNJUNGAN
		, VUMUR
	FROM
		layanan.hasil_lab hl
		LEFT JOIN layanan.tindakan_medis tm ON tm.ID = hl.TINDAKAN_MEDIS
		LEFT JOIN pendaftaran.kunjungan kjg ON kjg.NOMOR = tm.KUNJUNGAN
		LEFT JOIN layanan.order_lab ol ON ol.NOMOR = kjg.REF
		LEFT JOIN pendaftaran.kunjungan kjg2 ON kjg2.NOMOR = ol.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran pdf ON pdf.NOMOR = kjg.NOPEN
		LEFT JOIN `master`.pasien psn ON psn.NORM = pdf.NORM
		LEFT JOIN `master`.ruangan rgn ON rgn.ID = kjg2.RUANGAN
	WHERE
		hl.ID = PIDHASILLAB LIMIT 1;
		
	IF VJ_KUNJUNGAN = 3 THEN
		
		IF EXISTS(SELECT * 
			FROM 
				`master`.nilai_rujukan_lab nrj 
			WHERE nrj.PARAMETER_TINDAKAN = VPARAMETER 
				AND nrj.JENIS_KELAMIN = VKELAMIN
				AND nrj.UMUR <= VUMUR
				AND (VHASIL >= nrj.BATAS_BAWAH OR VHASIL <= nrj.BATAS_ATAS)
				ORDER BY nrj.UMUR DESC
			LIMIT 1) THEN
			
			IF NOT EXISTS(SELECT * FROM layanan.nilai_kritis_lab l WHERE l.HASIL_LAB = PIDHASILLAB LIMIT 1) THEN 
				INSERT INTO layanan.nilai_kritis_lab (`HASIL_LAB`) VALUES (PIDHASILLAB);
			ELSE
				UPDATE layanan.nilai_kritis_lab SET `STATUS` = 1 WHERE HASIL_LAB = PIDHASILLAB;	
			END IF;
			
		ELSE
			UPDATE layanan.nilai_kritis_lab SET `STATUS` = 0 WHERE HASIL_LAB = PIDHASILLAB;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
