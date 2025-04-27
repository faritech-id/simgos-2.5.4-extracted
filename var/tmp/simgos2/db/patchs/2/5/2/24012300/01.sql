-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakHasilEEG
DROP PROCEDURE IF EXISTS `CetakHasilEEG`;
DELIMITER //
CREATE PROCEDURE `CetakHasilEEG`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT INST.*
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT, DATE_FORMAT(eeg.TANGGAL_INPUT, '%d-%m-%Y %H:%i:%s') TGLPEREKAMAN, eeg.KUNJUNGAN
	  , eeg.HASIL, eeg.HASIL_SEBELUMNYA, eeg.MRI_KEPALA, eeg.HASIL_PEREKAMAN, eeg.KESIMPULAN, eeg.SARAN
	  , a.DESKRIPSI ANAMNESIS 
	  , IFNULL(IF(dg.ID IS NULL, CONCAT(dms.CODE,'- ',dms.STR), `master`.getICD10(dg.KODE)), d.DIAGNOSIS) DIAGNOSA
	  , master.getNamaLengkapPegawai(md.NIP) DPJP, md.NIP
	FROM medicalrecord.pemeriksaan_eeg eeg
		 LEFT JOIN pendaftaran.kunjungan pkj ON eeg.KUNJUNGAN=pkj.NOMOR
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	    LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = pk.NOMOR
		 LEFT JOIN medicalrecord.anamnesis a ON a.KUNJUNGAN=pk.NOMOR
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10		 
		 LEFT JOIN master.diagnosa_masuk dm ON pp.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_2020','ICD10_1998') AND dms.TTY !='HT' AND dms.TTY !='PS'
       LEFT JOIN medicalrecord.diagnosa dg ON pp.NOMOR=dg.NOPEN AND dg.UTAMA=1 AND dg.INA_GROUPER=0 AND dg.`STATUS`!=0   
	  , master.pasien p
	    LEFT JOIN master.kontak_pasien kp ON p.NORM = kp.NORM
	  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE eeg.KUNJUNGAN=PKUNJUNGAN
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY eeg.KUNJUNGAN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
