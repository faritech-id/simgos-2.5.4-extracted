-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakHasilEMG
DROP PROCEDURE IF EXISTS `CetakHasilEMG`;
DELIMITER //
CREATE PROCEDURE `CetakHasilEMG`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
SELECT INST.*
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT
	  , emg.KELUHAN
	  , emg.PENGOBATAN
	  , CONCAT(emg.TD, ' mmhg') TD 
	  , CONCAT(emg.RR, ' kali/menit') RR
	  , CONCAT(emg.HR, ' kali/menit') HR
	  , CONCAT(emg.DERAJAT_CELCIUS, ' ''C') SUHU
	  , emg.GCS
	  , emg.NPRS
	  , emg.FKL
	  , CONCAT(emg.NN_CRANIALIS, ' mm ODS') NN_CRANIALIS 
	  , CONCAT(emg.RCT_RCTL, ' ODS') RCT_RCTL 
	  , emg.NN_CR_LAIN
	  , emg.MOTORIK, emg.PERGERAKAN, emg.KEKUATAN, emg.EXTREMITAS_SUPERIOR, emg.EXTREMITAS_INFERIOR, emg.TONUS, emg.REFLEKS_FISOLOGIS
	  , emg.REFLEKS_PATOLOGIS, emg.SENSORIK, emg.OTONOM, emg.NVC_AND_EMG_FINDINGS, emg.IMPRESSION, emg.DIBUAT_TANGGAL, emg.OLEH
	  , `master`.getNamaLengkapPegawai(demg.NIP) DOKTER, demg.NIP
	  , CONCAT(n.TINGGI_BADAN, ' cm') TINGGI_BADAN, CONCAT(n.BERAT_BADAN, ' kg') BERAT_BADAN
	FROM medicalrecord.pemeriksaan_emg emg		 
		 LEFT JOIN pendaftaran.kunjungan pkj ON emg.KUNJUNGAN=pkj.NOMOR
		 LEFT JOIN `master`.dokter demg ON pkj.DPJP = demg.ID
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	    LEFT JOIN medicalrecord.nutrisi n ON pk.NOMOR=n.KUNJUNGAN
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
	WHERE emg.KUNJUNGAN=PKUNJUNGAN 
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY emg.KUNJUNGAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
