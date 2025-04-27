-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakSuratSehat
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
	   , ss.ATAS_PERMINTAAN, ss.HASIL_PEMERIKSAAN, ss.KETERANGAN, ss.DIBUAT_TANGGAL
	FROM medicalrecord.surat_sehat ss
		, pendaftaran.kunjungan pk
		  LEFT JOIN `master`.dokter ds ON pk.DPJP=ds.ID
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
