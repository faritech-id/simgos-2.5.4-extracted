-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure pendaftaran.CetakSuratKelahiran
DROP PROCEDURE IF EXISTS `CetakSuratKelahiran`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakSuratKelahiran`(
	IN `PNORM` INT
)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
	     , LPAD(p.NORM,8,'0') NORM, p.NAMA NAMAPASIEN, DATE(p.TANGGAL_LAHIR) TGLLAHIR
	     , jk.DESKRIPSI SEX, ayah.NAMA AYAH, ayah.ALAMAT ALAMATAYAH
	     , ibu.NAMA IBU, ibu.ALAMAT ALAMATIBU, pp.BERAT_BAYI
	FROM pendaftaran.pendaftaran pp
		, master.pasien p
		  LEFT JOIN master.referensi jk ON p.JENIS_KELAMIN=jk.ID AND jk.JENIS=2
		  LEFT JOIN master.keluarga_pasien ayah ON p.NORM=ayah.NORM AND ayah.JENIS_KELAMIN=1 AND ayah.SHDK=7
		  LEFT JOIN master.keluarga_pasien ibu ON p.NORM=ibu.NORM AND ibu.JENIS_KELAMIN=2 AND ibu.SHDK=7
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT 
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pp.NORM=p.NORM AND p.NORM=PNORM 
	  AND DATE(p.TANGGAL_LAHIR)=DATE(pp.TANGGAL);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
