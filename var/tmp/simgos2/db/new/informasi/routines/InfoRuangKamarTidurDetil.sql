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

-- membuang struktur untuk procedure informasi.InfoRuangKamarTidurDetil
DROP PROCEDURE IF EXISTS `InfoRuangKamarTidurDetil`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `InfoRuangKamarTidurDetil`(IN `PKAMAR` LONGTEXT)
BEGIN
	SELECT *, IF(rkt.JK=1,'laki',IF(rkt.JK=2,'perempuan',IF(rkt.JK IS NULL AND rkt.STATUS_INFO='Terisi','laki','kosong'))) BED_STATUS, if(rkt.STATUS_INFO='Kosong','#FFF','#878ea2') COLOR
	FROM (
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, NULL NAMA, NULL JK, 'bed_putih' STATUS_BED, 'Kosong' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		 WHERE rkt.STATUS = 1	 
		UNION	
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, NULL NORM, r.ATAS_NAMA NAMA, NULL JK, 'bed_hitam' STATUS_BED, 'Terisi' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.STATUS = 1
		 WHERE rkt.STATUS = 2
		UNION		 
		SELECT rkt.ID, rkt.RUANG_KAMAR, rkt.TEMPAT_TIDUR, ps.NORM, CONCAT(IF(ps.GELAR_DEPAN = '' OR ps.GELAR_DEPAN IS NULL, '', CONCAT(ps.GELAR_DEPAN, '. ')),UPPER(ps.NAMA), IF(ps.GELAR_BELAKANG = '' OR ps.GELAR_BELAKANG IS NULL, '', CONCAT(', ', ps.GELAR_BELAKANG))) NAMA
		, ps.JENIS_KELAMIN JK, 'bed_hitam' STATUS_NM, 'Terisi' STATUS_INFO
		  FROM master.ruang_kamar_tidur rkt
		  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
		  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM  		 
		 WHERE rkt.STATUS = 3
		   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
			AND NOT EXISTS(SELECT 1 FROM pembatalan.pembatalan_kunjungan pk WHERE pk.KUNJUNGAN = k.NOMOR AND pk.JENIS = 1)
	) rkt WHERE rkt.RUANG_KAMAR IN (PKAMAR);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
