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

-- Dumping structure for procedure medicalrecord.CetakRekonsiliasiTransfer
DROP PROCEDURE IF EXISTS `CetakRekonsiliasiTransfer`;
DELIMITER //
CREATE PROCEDURE `CetakRekonsiliasiTransfer`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT 
	inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, inst.PPK IDPPK, rt.KUNJUNGAN
	, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
	, DATE_FORMAT(mp.TANGGAL_LAHIR ,'%d-%m-%Y') TANGGAL_LAHIR
	, if (pasien.JENIS_KELAMIN=1, 'L','P') JK
	, pk.RUANGAN, r.DESKRIPSI
	, `master`.getNamaLengkap(pp.NORM) NM_PASIEN
	, rtd.OBAT_DARI_LUAR, b.NAMA OBAT, rtd.DOSIS, rtd.FREKUENSI KD_F , f.FREKUENSI DESC_F, rtd.RUTE KD_R, mr.DESKRIPSI DESC_R,  rtd.TINDAK_LANJUT KD_TL, tl.DESKRIPSI DESC_TL, rtd.PERUBAHAN_ATURAN_PAKAI KD_PAP, f2.FREKUENSI DESC_PAP
	, DATE_FORMAT(rt.TANGGAL, '%d-%m-%Y %H:%i:%s') TANGGAL, `master`.getNamaLengkapPegawai(mp.NIP) USER
	FROM
	pendaftaran.kunjungan pk
		LEFT JOIN `master`.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	, pendaftaran.pendaftaran pp
		LEFT JOIN `master`.pasien pasien ON pasien.NORM= pp.NORM
	, medicalrecord.rekonsiliasi_transfer rt
	LEFT JOIN `master`.pegawai mp ON mp.ID=rt.OLEH
	, medicalrecord.rekonsiliasi_transfer_detil rtd
	LEFT JOIN `master`.frekuensi_aturan_resep f ON f.ID=rtd.FREKUENSI 
	LEFT JOIN `master`.frekuensi_aturan_resep f2 ON f2.ID=rtd.PERUBAHAN_ATURAN_PAKAI 
	LEFT JOIN `master`.referensi mr ON mr.ID=rtd.RUTE AND mr.JENIS=217
	LEFT JOIN `master`.referensi tl ON tl.ID=rtd.TINDAK_LANJUT AND tl.JENIS=245
	, inventory.barang b
	, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			            FROM aplikasi.instansi ai
			              , master.ppk mp
			            WHERE ai.PPK=mp.ID) inst
	
	WHERE rt.ID=rtd.REKONSILIASI_TRANSFER AND b.ID=rtd.OBAT_DARI_LUAR AND pk.NOPEN=pp.NOMOR AND pk.NOMOR=rt.KUNJUNGAN
	AND PKUNJUNGAN= rt.KUNJUNGAN
	
	
;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
