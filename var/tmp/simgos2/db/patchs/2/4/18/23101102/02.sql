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

-- Dumping structure for procedure medicalrecord.CetakRekonsiliasiDischarge
DROP PROCEDURE IF EXISTS `CetakRekonsiliasiDischarge`;
DELIMITER //
CREATE PROCEDURE `CetakRekonsiliasiDischarge`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT 
	inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, inst.PPK IDPPK
	, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, `master`.getNamaLengkap(pp.NORM) NM_PASIEN
	, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN , r.DESKRIPSI RUANGAN
	, rd.KUNJUNGAN, DATE_FORMAT(rd.TANGGAL, '%d-%m-%Y %H:%i:%s') TANGGAL
	, rdt.OBAT_DARI_LUAR KD_OBAT, b.NAMA OBAT, rdt.DOSIS DOSIS, rdt.FREKUENSI KD_F, f.FREKUENSI DESC_F
	, rdt.RUTE KD_RUTE, mr.DESKRIPSI DESC_RUTE, rdt.TINDAK_LANJUT KD_TL, tl.DESKRIPSI DECS_TL
	, rdt.PERUBAHAN_ATURAN_PAKAI KD_PAP, f2.FREKUENSI DESC_PAP
	, `master`.getNamaLengkapPegawai(mp.NIP) user

	FROM 
	pendaftaran.pendaftaran pp
	LEFT JOIN `master`.pasien p ON pp.NORM=p.NORM
	, pendaftaran.kunjungan pk 
	LEFT JOIN `master`.ruangan r ON r.ID=pk.RUANGAN
	, medicalrecord.rekonsiliasi_discharge rd
	LEFT JOIN `master`.pegawai mp ON mp.ID=rd.OLEH
	, medicalrecord.rekonsiliasi_discharge_detil rdt
	LEFT JOIN `master`.frekuensi_aturan_resep f ON f.ID=rdt.FREKUENSI
	LEFT JOIN `master`.referensi mr ON mr.ID=rdt.RUTE AND mr.JENIS=217
	LEFT JOIN `master`.referensi tl ON tl.ID=rdt.TINDAK_LANJUT AND tl.JENIS=245
	LEFT JOIN `master`.frekuensi_aturan_resep f2 ON f2.ID=rdt.PERUBAHAN_ATURAN_PAKAI
	, inventory.barang b
	, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			            FROM aplikasi.instansi ai
			              , master.ppk mp
			            WHERE ai.PPK=mp.ID) inst
	WHERE rd.ID=rdt.REKONSILIASI_DISCHARGE AND b.ID=rdt.OBAT_DARI_LUAR AND pp.NOMOR=rd.PENDAFTARAN AND pp.NOMOR=pk.NOPEN AND pk.NOMOR=rd.KUNJUNGAN
	AND pk.NOMOR=PKUNJUNGAN;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
