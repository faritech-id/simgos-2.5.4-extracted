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

-- membuang struktur untuk procedure pendaftaran.CetakTracertPasien
DROP PROCEDURE IF EXISTS `CetakTracertPasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakTracertPasien`(
	IN `PNOPEN` CHAR(10)

)
BEGIN
	SELECT LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG
		, p.TANGGAL_LAHIR TGL_LAHIR
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, r.DESKRIPSI UNITPELAYANAN
		, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
		, (SELECT r.DESKRIPSI
			FROM pendaftaran.pendaftaran pdf
		      , pendaftaran.kunjungan pk
			   , master.ruangan r 
			WHERE pdf.NOMOR=pk.NOPEN AND pdf.NORM=pd.NORM AND pd.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pk.RUANGAN=r.ID AND r.JENIS=5 AND r.JENIS_KUNJUNGAN IN (1,2,3)
			  AND pk.MASUK < pd.TANGGAL
			ORDER BY pk.MASUK DESC LIMIT 1) UNIT_SEBELUMNYA
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=PNOPEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
