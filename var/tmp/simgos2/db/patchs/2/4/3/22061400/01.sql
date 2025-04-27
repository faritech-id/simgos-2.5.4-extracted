-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for layanan
CREATE DATABASE IF NOT EXISTS `layanan` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `layanan`;

-- Dumping structure for procedure layanan.CetakJobListLab
DROP PROCEDURE IF EXISTS `CetakJobListLab`;
DELIMITER //
CREATE PROCEDURE `CetakJobListLab`(
	IN `PKUNJUNGAN` CHAR(21),
	IN `PJENIS` INT
)
BEGIN
	 SET @sqlText = CONCAT('SELECT 
		"REGULER" STATUS_CITO,
		INSERT(INSERT(LPAD(p.NORM,6,"0"),3,0,"-"),6,0,"-") NORM, 
		master.getNamaLengkap(p.NORM) NAMALENGKAP,
		IF(p.JENIS_KELAMIN = 1, "Laki-laki", "Perempuan") J_KELAMIN,
		DATE_FORMAT(p.TANGGAL_LAHIR, "%d-%m-%Y") TGL_LAHIR,
		master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR,
		kjg.NOMOR NOMOR_KUNJUNGAN,
		DATE_FORMAT(kjg.MASUK, "%d-%m-%Y %H:%i:%s") TGL_KUNJUNGAN,
		rasal.DESKRIPSI UNIT_SEBELUMNYA,
		IF(DATE_FORMAT(p.TANGGAL,"%d-%m-%Y")=DATE_FORMAT(kjg.MASUK,"%d-%m-%Y"),"Baru","Lama") STATUSPENGUNJUNG,
		CONCAT("<b>",t.NAMA,"</b> (", tm.ID ,")") TINDAKAN,
		ref.DESKRIPSI CARA_BAYAR, lab.ALASAN DIAGNOSA, IF(dok.NIP IS NULL, master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP)) DOKTER
	FROM pendaftaran.kunjungan kjg 
	JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = kjg.NOPEN
	JOIN pendaftaran.penjamin pjm ON pjm.NOPEN = pd.NOMOR
	LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pd.NOMOR
	LEFT JOIN layanan.order_lab lab ON kjg.REF = lab.NOMOR
	LEFT JOIN pendaftaran.kunjungan asal ON lab.KUNJUNGAN=asal.NOMOR
	LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
	LEFT JOIN master.dokter dok ON lab.DOKTER_ASAL=dok.id
	LEFT JOIN master.dokter dok1 ON tp.DOKTER=dok1.id
	LEFT JOIN layanan.tindakan_medis tm ON tm.KUNJUNGAN = kjg.NOMOR AND tm.`STATUS`!=0
	LEFT JOIN master.tindakan t ON t.ID = tm.TINDAKAN
	JOIN master.referensi ref ON ref.ID = pjm.JENIS AND ref.JENIS = 10
	JOIN master.pasien p ON p.NORM = pd.NORM
	WHERE 
		kjg.NOMOR = "',PKUNJUNGAN,'"');
		
	IF PJENIS = 2 THEN	
		SET @sqlText = CONCAT('SELECT 
			"REGULER" STATUS_CITO,
			INSERT(INSERT(LPAD(p.NORM,6,"0"),3,0,"-"),6,0,"-") NORM, 
			master.getNamaLengkap(p.NORM) NAMALENGKAP,
			IF(p.JENIS_KELAMIN = 1, "Laki-laki", "Perempuan") J_KELAMIN,
			DATE_FORMAT(p.TANGGAL_LAHIR, "%d-%m-%Y") TGL_LAHIR,
			master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR,
			kjg.NOMOR NOMOR_KUNJUNGAN,
			DATE_FORMAT(kjg.MASUK, "%d-%m-%Y %H:%i:%s") TGL_KUNJUNGAN,
			rasal.DESKRIPSI UNIT_SEBELUMNYA,
			IF(DATE_FORMAT(p.TANGGAL,"%d-%m-%Y")=DATE_FORMAT(kjg.MASUK,"%d-%m-%Y"),"Baru","Lama") STATUSPENGUNJUNG,
			DAFTAR_TINDAKAN TINDAKAN, lab.ALASAN DIAGNOSA, IF(dok.NIP IS NULL, master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP)) DOKTER,
			ref.DESKRIPSI CARA_BAYAR
		FROM pendaftaran.kunjungan kjg 
		JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = kjg.NOPEN
		JOIN pendaftaran.penjamin pjm ON pjm.NOPEN = pd.NOMOR
		LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pd.NOMOR
		LEFT JOIN layanan.order_lab lab ON kjg.REF = lab.NOMOR
		LEFT JOIN pendaftaran.kunjungan asal ON lab.KUNJUNGAN=asal.NOMOR
		LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
		LEFT JOIN master.dokter dok ON lab.DOKTER_ASAL=dok.id
		LEFT JOIN master.dokter dok1 ON tp.DOKTER=dok1.id
		LEFT JOIN (
			SELECT tm.KUNJUNGAN, GROUP_CONCAT("<b>", t.NAMA, " </b>- ", tm.ID, "<br>" SEPARATOR "") DAFTAR_TINDAKAN
			FROM tindakan_medis tm
			LEFT JOIN master.tindakan t ON t.ID = tm.TINDAKAN 
			WHERE tm.KUNJUNGAN = "',PKUNJUNGAN,'" AND tm.`STATUS`!=0
		) tm ON tm.KUNJUNGAN = kjg.NOMOR 
		JOIN master.referensi ref ON ref.ID = pjm.JENIS AND ref.JENIS = 10
		JOIN master.pasien p ON p.NORM = pd.NORM
		WHERE 
			kjg.NOMOR = "',PKUNJUNGAN,'"');
	END IF;
	 
	 PREPARE stmt FROM @sqlText;
	 EXECUTE stmt;
	 DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure layanan.CetakJobListRad
DROP PROCEDURE IF EXISTS `CetakJobListRad`;
DELIMITER //
CREATE PROCEDURE `CetakJobListRad`(
	IN `PKUNJUNGAN` CHAR(21),
	IN `PJENIS` INT
)
BEGIN
	SET @sqlText = CONCAT('SELECT 
		"REGULER" STATUS_CITO,
		INSERT(INSERT(LPAD(p.NORM,6,"0"),3,0,"-"),6,0,"-") NORM, 
		master.getNamaLengkap(p.NORM) NAMALENGKAP,
		IF(p.JENIS_KELAMIN = 1, "Laki-laki", "Perempuan") J_KELAMIN,
		DATE_FORMAT(p.TANGGAL_LAHIR, "%d-%m-%Y") TGL_LAHIR,
		master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR,
		kjg.NOMOR NOMOR_KUNJUNGAN,
		DATE_FORMAT(kjg.MASUK, "%d-%m-%Y %H:%i:%s") TGL_KUNJUNGAN,
		rasal.DESKRIPSI UNIT_SEBELUMNYA,
		IF(DATE_FORMAT(p.TANGGAL,"%d-%m-%Y")=DATE_FORMAT(kjg.MASUK,"%d-%m-%Y"),"Baru","Lama") STATUSPENGUNJUNG,
		CONCAT("<b>",t.NAMA,"</b> (", tm.ID ,")") TINDAKAN,
		ref.DESKRIPSI CARA_BAYAR, rad.ALASAN DIAGNOSA, master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP)) DOKTER
	FROM pendaftaran.kunjungan kjg 
	JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = kjg.NOPEN
	JOIN pendaftaran.penjamin pjm ON pjm.NOPEN = pd.NOMOR
	LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pd.NOMOR 
	LEFT JOIN layanan.order_rad rad ON kjg.REF = rad.NOMOR
	LEFT JOIN pendaftaran.kunjungan asal ON rad.KUNJUNGAN=asal.NOMOR
	LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
	LEFT JOIN master.dokter dok ON rad.DOKTER_ASAL=dok.id
	LEFT JOIN master.dokter dok1 ON tp.DOKTER=dok1.id
	LEFT JOIN layanan.tindakan_medis tm ON tm.KUNJUNGAN = kjg.NOMOR AND tm.`STATUS`!=0
	LEFT JOIN master.tindakan t ON t.ID = tm.TINDAKAN
	JOIN master.referensi ref ON ref.ID = pjm.JENIS AND ref.JENIS = 10
	JOIN master.pasien p ON p.NORM = pd.NORM
	WHERE 
		kjg.NOMOR = "',PKUNJUNGAN,'"');
	
	IF PJENIS = 2 THEN
		SET @sqlText = CONCAT('SELECT 
				"REGULER" STATUS_CITO,
				INSERT(INSERT(LPAD(p.NORM,6,"0"),3,0,"-"),6,0,"-") NORM, 
				master.getNamaLengkap(p.NORM) NAMALENGKAP,
				IF(p.JENIS_KELAMIN = 1, "Laki-laki", "Perempuan") J_KELAMIN,
				DATE_FORMAT(p.TANGGAL_LAHIR, "%d-%m-%Y") TGL_LAHIR,
				master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR,
				kjg.NOMOR NOMOR_KUNJUNGAN,
				DATE_FORMAT(kjg.MASUK, "%d-%m-%Y %H:%i:%s") TGL_KUNJUNGAN,
				rasal.DESKRIPSI UNIT_SEBELUMNYA,
				IF(DATE_FORMAT(p.TANGGAL,"%d-%m-%Y")=DATE_FORMAT(kjg.MASUK,"%d-%m-%Y"),"Baru","Lama") STATUSPENGUNJUNG,
				DAFTAR_TINDAKAN TINDAKAN,
				ref.DESKRIPSI CARA_BAYAR, rad.ALASAN DIAGNOSA,master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP)) DOKTER
			FROM pendaftaran.kunjungan kjg 
			JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = kjg.NOPEN
			JOIN pendaftaran.penjamin pjm ON pjm.NOPEN = pd.NOMOR
			LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = pd.NOMOR 
			LEFT JOIN layanan.order_rad rad ON kjg.REF = rad.NOMOR
			LEFT JOIN pendaftaran.kunjungan asal ON rad.KUNJUNGAN=asal.NOMOR
			LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
			LEFT JOIN master.dokter dok ON rad.DOKTER_ASAL=dok.id
			LEFT JOIN master.dokter dok1 ON tp.DOKTER=dok1.id
			LEFT JOIN (
				SELECT tm.KUNJUNGAN, GROUP_CONCAT("<b>", t.NAMA, " </b>- ", tm.ID, "<br>" SEPARATOR "") DAFTAR_TINDAKAN
				FROM tindakan_medis tm
				LEFT JOIN master.tindakan t ON t.ID = tm.TINDAKAN 
				WHERE tm.KUNJUNGAN = "',PKUNJUNGAN,'" AND tm.`STATUS`!=0
			) tm ON tm.KUNJUNGAN = kjg.NOMOR 
			JOIN master.referensi ref ON ref.ID = pjm.JENIS AND ref.JENIS = 10
			JOIN master.pasien p ON p.NORM = pd.NORM
			WHERE 
				kjg.NOMOR = "',PKUNJUNGAN,'"');
	END IF;
	
	 
	 PREPARE stmt FROM @sqlText;
	 EXECUTE stmt;
	 DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
