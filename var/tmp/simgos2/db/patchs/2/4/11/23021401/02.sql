-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6557
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

-- Dumping structure for procedure medicalrecord.CetakKeteranganMeninggal
DROP PROCEDURE IF EXISTS `CetakKeteranganMeninggal`;
DELIMITER //
CREATE PROCEDURE `CetakKeteranganMeninggal`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT INST.NAMAINST, INST.ALAMATINST, INST.KOTA, INST.ID ID_PPK,
			 LPAD(ps.NORM,8,'0') NORM, pp.NOMOR NOPEN, UPPER(ag.DESKRIPSI) AGAMA, pkr.DESKRIPSI PEKERJAAN,
			 master.getNamaLengkap(ps.NORM) NAMALENGKAP, CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),')') TANGGAL_LAHIR, 
			 crbyr.DESKRIPSI CARABAYAR, UPPER(`master`.getAlamatPasien(ps.NORM)) PSALAMAT,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN,
		    DATE_FORMAT(pp.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLMASUK, DATE_FORMAT(lpp.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLKELUAR, 
			 DATE_FORMAT(lpm.TANGGAL,'%d-%m-%Y') TGLMENINGGAL, DATE_FORMAT(lpm.TANGGAL,'%H:%i:%s') JAMMENINGGAL, cr.DESKRIPSI CARAKELUAR, 
			 kd.DESKRIPSI KEADAANKELUAR, UPPER(r.DESKRIPSI) UNIT, IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT, lpm.NOMOR,
			 (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT,
			 IF(GROUP_CONCAT((SELECT CONCAT(ms.CODE,'[',ms.STR,']') 
			   FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=dm.KODE LIMIT 1)) IS NULL, lpm.DIAGNOSA,
				CONCAT(GROUP_CONCAT((SELECT CONCAT(ms.CODE,'[',ms.STR,']') 
			   FROM master.mrconso ms WHERE ms.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND ms.CODE=dm.KODE LIMIT 1)),'(',lpm.DIAGNOSA,')')) DIAGNOSA,
			md.NIP, master.getNamaLengkapPegawai(md.NIP) DPJP
	FROM layanan.pasien_meninggal lpm
		  LEFT JOIN master.dokter md ON lpm.DOKTER=md.ID AND md.`STATUS`=1,
		  layanan.pasien_pulang lpp
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46
		  LEFT JOIN medicalrecord.diagnosa_meninggal dm ON lpp.NOPEN=dm.NOPEN AND dm.UTAMA=1 AND dm.`STATUS`=1,
		  pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.kode_surat_ruangan ksr ON pk.RUANGAN=ksr.RUANGAN,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN master.referensi rjk ON ps.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi ag ON ps.AGAMA=ag.ID AND ag.JENIS=1
		  LEFT JOIN master.referensi pkr ON ps.PEKERJAAN=pkr.ID AND pkr.JENIS=4
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10,
		  (SELECT mp.ID, mp.NAMA NAMAINST, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT ALAMATINST , mp.TELEPON, mp.FAX, ai.EMAIL
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) INST
	WHERE lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1 
	   AND lpp.KUNJUNGAN=lpm.KUNJUNGAN AND lpm.STATUS=1
		AND pk.NOPEN=pp.NOMOR AND lpm.TANGGAL AND pk.NOMOR=PKUNJUNGAN
		GROUP BY lpp.NOPEN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;