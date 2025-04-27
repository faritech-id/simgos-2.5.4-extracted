-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.cetakSuratKontrol
DROP PROCEDURE IF EXISTS `cetakSuratKontrol`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `cetakSuratKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT
		 , jk.NOMOR 
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , ps.TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , DATE(jk.DIBUAT_TANGGAL) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , d.DIAGNOSIS
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , rt.DESKRIPSI RENCANA_TERAPI
  FROM medicalrecord.jadwal_kontrol jk
  		 LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = jk.KUNJUNGAN
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = jk.KUNJUNGAN
       , pendaftaran.kunjungan k
       , pendaftaran.pendaftaran p
       , `master`.pasien ps
       , `master`.ruangan r
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE jk.KUNJUNGAN = PKUNJUNGAN
   AND k.NOMOR = jk.KUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND r.ID = k.RUANGAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
