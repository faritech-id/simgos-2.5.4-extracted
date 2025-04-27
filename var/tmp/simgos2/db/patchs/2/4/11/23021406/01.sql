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

-- Dumping structure for procedure medicalrecord.CetakKeteranganOpname
DROP PROCEDURE IF EXISTS `CetakKeteranganOpname`;
DELIMITER //
CREATE PROCEDURE `CetakKeteranganOpname`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
	       , `master`.getNamaDanGelar(p.GELAR_DEPAN, p.NAMA, p.GELAR_BELAKANG) NAMA
			 , `master`.getFormatNorm(p.NORM, '.') NORM, jk.DESKRIPSI JENIS_KELAMIN
	       , `master`.getCariUmur(pdf.TANGGAL, p.TANGGAL_LAHIR) UMUR
	       , p.ALAMAT AS ALAMAT_PASIEN, pkrj.DESKRIPSI PEKERJAAN
	       , kec.DESKRIPSI KECAMATAN
	       , kel.DESKRIPSI KELURAHAN
	       , master.getNamaLengkapPegawai(dok.NIP) DPJP, dok.NIP
	       , opn.NOMOR, opn.KETERANGAN KETERANGAN
			 , IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	       , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	       , IFNULL(lpp.TANGGAL,opn.DIBUAT_TANGGAL) DIBUAT_TANGGAL, DATE_FORMAT(pdf.TANGGAL,'%d-%m-%Y') TGLMSK
	  FROM medicalrecord.surat_opname opn
	  		 , pendaftaran.kunjungan k
	  		 LEFT JOIN layanan.pasien_pulang lpp ON k.NOMOR=lpp.KUNJUNGAN
	  		 LEFT JOIN master.kode_surat_ruangan ksr ON k.RUANGAN=ksr.RUANGAN
	  		 , pendaftaran.pendaftaran pdf
	  		 , `master`.pasien p
	  		 LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
	  		 LEFT JOIN master.wilayah kel ON kel.ID = p.WILAYAH
	  		 , `master`.referensi jk
	  		 , `master`.referensi pkrj
	  		 , `master`.dokter dok
			 , (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE opn.KUNJUNGAN = PKUNJUNGAN
	  AND opn.`STATUS` = 1
	  AND k.NOMOR = opn.KUNJUNGAN
	  AND pdf.NOMOR = k.NOPEN
	  AND p.NORM = pdf.NORM
	  AND jk.JENIS = 2 AND jk.ID = p.JENIS_KELAMIN
	  AND pkrj.JENIS = 4 AND pkrj.ID = p.PEKERJAAN
	  AND dok.ID = k.DPJP;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakSuratSakit
DROP PROCEDURE IF EXISTS `CetakSuratSakit`;
DELIMITER //
CREATE PROCEDURE `CetakSuratSakit`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
	       , skt.NOMOR, skt.LAMA, DATE_FORMAT(skt.TANGGAL,'%d-%m-%Y') MULAI
			 , DATE_FORMAT(DATE_ADD(skt.TANGGAL,INTERVAL skt.LAMA DAY),'%d-%m-%Y') BERAKHIR, skt.DESKRIPSI KETERANGAN
	       , `master`.getNamaDanGelar(p.GELAR_DEPAN, p.NAMA, p.GELAR_BELAKANG) NAMA
			 , `master`.getFormatNorm(p.NORM, '.') NORM, jk.DESKRIPSI JENIS_KELAMIN
	       , `master`.getCariUmur(pdf.TANGGAL, p.TANGGAL_LAHIR) UMUR
	       , IFNULL(p.ALAMAT,'') ALAMAT_PASIEN, IFNULL(pkrj.DESKRIPSI,'') PEKERJAAN
	       , IFNULL(kec.DESKRIPSI,'') KECAMATAN
	       , IFNULL(kel.DESKRIPSI,'') KELURAHAN
	       , master.getNamaLengkapPegawai(dok.NIP) DPJP
	       , dok.NIP, IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	       , skt.DIBUAT_TANGGAL
	       , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	  FROM medicalrecord.surat_sakit skt
	  		 , pendaftaran.kunjungan k
	  		 	LEFT JOIN master.kode_surat_ruangan ksr ON k.RUANGAN=ksr.RUANGAN
	  		 , pendaftaran.pendaftaran pdf
	  		 , `master`.pasien p
	  		 LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
	  		 LEFT JOIN master.wilayah kel ON kel.ID = p.WILAYAH
	  		 , `master`.referensi jk
	  		 , `master`.referensi pkrj
	  		 , `master`.dokter dok
			 , (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE skt.KUNJUNGAN = PKUNJUNGAN
	  AND skt.`STATUS` = 1
	  AND k.NOMOR = skt.KUNJUNGAN
	  AND pdf.NOMOR = k.NOPEN
	  AND p.NORM = pdf.NORM
	  AND jk.JENIS = 2 AND jk.ID = p.JENIS_KELAMIN
	  AND pkrj.JENIS = 4 AND pkrj.ID = p.PEKERJAAN
	  AND dok.ID = k.DPJP;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakSuratSehat
DROP PROCEDURE IF EXISTS `CetakSuratSehat`;
DELIMITER //
CREATE PROCEDURE `CetakSuratSehat`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, inst.NAMA NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
		, CONCAT('Nomor : ',ss.NOMOR) NOMOR_SURAT, `master`.getNamaLengkapPegawai(ds.NIP) DPJP, ds.NIP
	   , p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
	   , jk.DESKRIPSI JENIS_KELAMIN, p.ALAMAT ALAMATPASIEN, ss.TANGGAL
	   , ss.ATAS_PERMINTAAN, ss.HASIL_PEMERIKSAAN, UPPER(ss.KETERANGAN) KETERANGAN, ss.DIBUAT_TANGGAL
	   , IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	   , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	FROM medicalrecord.surat_sehat ss
		, pendaftaran.kunjungan pk
		  LEFT JOIN `master`.dokter ds ON pk.DPJP=ds.ID
		  LEFT JOIN master.kode_surat_ruangan ksr ON pk.RUANGAN=ksr.RUANGAN
		, pendaftaran.pendaftaran pd
		, `master`.pasien p
		  LEFT JOIN `master`.referensi jk ON p.JENIS_KELAMIN=jk.ID AND jk.JENIS=2
		, (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE ss.KUNJUNGAN=pk.NOMOR AND ss.`STATUS`!=0 AND pk.`STATUS`!=0
		AND pk.NOPEN=pd.NOMOR AND pd.`STATUS`!=0 AND pd.NORM=p.NORM
		AND ss.KUNJUNGAN=PKUNJUNGAN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;