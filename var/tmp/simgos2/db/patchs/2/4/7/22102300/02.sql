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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakHasilExam
DROP PROCEDURE IF EXISTS `CetakHasilExam`;
DELIMITER //
CREATE PROCEDURE `CetakHasilExam`(
	IN `P_KUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
				 , hlm.*
				 , master.getNamaLengkapPegawai(d.NIP) AS NAMA_DOKTER
				 , d.NIP
				 , ps.NORM, master.getNamaLengkap(ps.NORM) AS PASIEN
				 , master.getNamaLengkapPegawai(da.NIP) AS DOKTER_ASAL
				 , DATE_FORMAT(k.MASUK, ''%d-%m-%Y %H:%i:%s'') AS TGL_TERIMA
				 , DATE_FORMAT(k.KELUAR, ''%d-%m-%Y %H:%i:%s'') AS TGL_SELESAI
				 , ol.NOMOR AS NOMOR_LAB, k.NOMOR
		  FROM pendaftaran.kunjungan k
				 , pendaftaran.pendaftaran p
				 , layanan.hasil_lab_exam hlm
				 , layanan.order_lab ol
				 , master.dokter d
				 , master.dokter da
				 , master.pegawai pa
				 , master.pasien ps
				 , (SELECT w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							  , master.ppk p
							  , master.wilayah w
					  WHERE ai.PPK = p.ID 
					    AND p.WILAYAH = w.ID
				 ) INST
		 WHERE k.NOMOR = ''',P_KUNJUNGAN,'''
		   AND hlm.DOKTER = d.ID
		   AND k.NOMOR =  hlm.KUNJUNGAN
		   AND k.NOPEN = p.NOMOR
		   AND p.NORM = ps.NORM
		   AND k.REF = ol.NOMOR
		   AND ol.DOKTER_ASAL = da.ID
		   AND da.NIP = pa.NIP
	');
	 
	#SELECT @sqlText;
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
