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

-- membuang struktur untuk procedure pendaftaran.CetakBarcodeReg
DROP PROCEDURE IF EXISTS `CetakBarcodeReg`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakBarcodeReg`(
	IN `PNOPEN` CHAR(10)
)
BEGIN	
	SELECT inst.NAMA NAMAINSTANSI, LPAD(p.NORM,8,'0') NORM, CONCAT(master.getNamaLengkap(p.NORM),' (',IF(p.JENIS_KELAMIN=1,'L)','P)')) NAMALENGKAP
	   , DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGL_LAHIR
		, CONCAT('RM : ',LPAD(p.NORM,8,'0'),' Tgl Lhr ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) RMTGL_LAHIR
		, pd.NOMOR NOPEN
		, p.ALAMAT
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		, (SELECT ai.PPK ID, mp.NAMA, mp.KODE, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=PNOPEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
