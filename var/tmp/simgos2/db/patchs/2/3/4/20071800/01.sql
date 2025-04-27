-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
USE layanan;
-- Dumping structure for procedure layanan.CetakHasilPa
DROP PROCEDURE IF EXISTS `CetakHasilPa`;
DELIMITER //
CREATE PROCEDURE `CetakHasilPa`(
	IN `PID` INT
)
BEGIN
   	SET @sqlText = CONCAT('
		SELECT INST.*, hp.*, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP, p.ALAMAT, pk.MASUK TGLREG,
			master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, ref.DESKRIPSI JENISPEMERIKSAAN, rjk.DESKRIPSI JENISKELAMIN,
			CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),'')'') TGL_LAHIR,
			rasal.DESKRIPSI RUANGAN_ASAL,
			master.getNamaLengkapPegawai(dokasal.NIP) NAMA_DOKTER_ASAL
		FROM layanan.hasil_pa hp
			  LEFT JOIN pendaftaran.kunjungan pk ON hp.KUNJUNGAN = pk.NOMOR
			  LEFT JOIN layanan.order_lab olab ON olab.NOMOR = pk.REF
			  LEFT JOIN pendaftaran.kunjungan pkjgn ON pkjgn.NOMOR = olab.KUNJUNGAN
			  LEFT JOIN master.dokter dokasal ON dokasal.ID = olab.DOKTER_ASAL
			  LEFT JOIN master.ruangan rasal ON rasal.ID = pkjgn.RUANGAN
			  LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN = pp.NOMOR
			  LEFT JOIN master.pasien p ON p.NORM = pp.NORM
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			  LEFT JOIN master.dokter dok ON hp.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			  LEFT JOIN master.referensi ref ON hp.JENIS_PEMERIKSAAN=ref.ID AND ref.JENIS=66
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST,  CONCAT(''Telp. '',TELEPON, '' Fax. '',FAX) TELP, ai.PPK IDPPK
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	   WHERE hp.ID =',PID,'');
   	 
   	PREPARE stmt FROM @sqlText;
   	EXECUTE stmt;
   	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
