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

-- membuang struktur untuk procedure medicalrecord.CetakPermohonanDPJP
DROP PROCEDURE IF EXISTS `CetakPermohonanDPJP`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakPermohonanDPJP`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT 
		CONCAT(master.getNamaLengkap(psn.NORM)) NAMA,
		psn.NORM,
		DATE_FORMAT(psn.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR,
		master.getCariUmur(pdft.TANGGAL,psn.TANGGAL_LAHIR) UMUR,
		psn.ALAMAT,
		master.getNamaLengkapPegawai(dkr.NIP) DPJP,
		DATE_FORMAT(NOW(),'%d-%m-%Y') TANGGAL
	FROM 
		pendaftaran.pendaftaran pdft
	LEFT JOIN master.pasien psn ON psn.NORM = pdft.NORM
	LEFT JOIN pendaftaran.tujuan_pasien tjp ON tjp.NOPEN = pdft.NOMOR 
	LEFT JOIN master.dokter dkr ON dkr.ID = tjp.DOKTER
	WHERE
		pdft.NOMOR = PNOPEN;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
