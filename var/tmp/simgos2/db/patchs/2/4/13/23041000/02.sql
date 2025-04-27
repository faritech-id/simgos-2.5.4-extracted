-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakRavenTest
DROP PROCEDURE IF EXISTS `CetakRavenTest`;
DELIMITER //
CREATE PROCEDURE `CetakRavenTest`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT INST.*
	  , DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i:%s') TGLSKRG
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT, rvn.KUNJUNGAN, rvn.SKORING, rvn.PRESENTIL, rvn.INTERPRETASI, rvn.ANJURAN
	  , DATE_FORMAT(rvn.DIBUAT_TANGGAL, '%d-%m-%Y %H:%i:%s') TGLPEREKAMAN, rvn.OLEH
	  , master.getNamaLengkapPegawai(md.NIP) DPJP, md.NIP
	FROM medicalrecord.pemeriksaan_raven_test rvn
		 LEFT JOIN pendaftaran.kunjungan pkj ON rvn.KUNJUNGAN=pkj.NOMOR
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	  , master.pasien p
	    LEFT JOIN master.kontak_pasien kp ON p.NORM = kp.NORM
	  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE rvn.KUNJUNGAN=PKUNJUNGAN 
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY rvn.KUNJUNGAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
