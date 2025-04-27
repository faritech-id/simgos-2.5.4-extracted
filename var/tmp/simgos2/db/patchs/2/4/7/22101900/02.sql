-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakHasilPa
DROP PROCEDURE IF EXISTS `CetakHasilPa`;
DELIMITER //
CREATE PROCEDURE `CetakHasilPa`(
	IN `PID` INT
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT INST.*, DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s'') TGLSKRG
		    , hp.*, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP, p.ALAMAT, pk.MASUK TGLREG,
		    mp.NIP, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, ref.DESKRIPSI JENISPEMERIKSAAN, rjk.DESKRIPSI JENISKELAMIN,
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
					 , w.DESKRIPSI KOTA, ai.WEBSITE WEB, ai.DEPARTEMEN, ai.INDUK_INSTANSI 
			  FROM aplikasi.instansi ai
				    , master.ppk p
				    , master.wilayah w
			 WHERE ai.PPK=p.ID 
			   AND p.WILAYAH=w.ID) INST
    WHERE hp.ID =',PID,'');
	 
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
