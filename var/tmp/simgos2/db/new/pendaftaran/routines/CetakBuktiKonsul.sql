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

-- membuang struktur untuk procedure pendaftaran.CetakBuktiKonsul
DROP PROCEDURE IF EXISTS `CetakBuktiKonsul`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakBuktiKonsul`(
	IN `PNOPEN` CHAR(10)

)
BEGIN
	SELECT LPAD(p.NORM,8,'0') NORM, CONCAT(master.getNamaLengkap(p.NORM),' (',IF(p.JENIS_KELAMIN=1,'L)','P)')) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') TGL_LAHIR
		, pd.NOMOR NOPEN, DATE_FORMAT(ks.TANGGAL,'%d-%m-%Y') TANGGALKONSUL, kj.RUANGAN
		, ref.DESKRIPSI CARABAYAR, r.DESKRIPSI UNITASAL, tj.DESKRIPSI UNITTUJUAN, ks.ALASAN
		, master.getNamaLengkapPegawai(dok.NIP) DOKTERASAL
		, rf.DESKRIPSI JENISRAWAT
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
		, pendaftaran.kunjungan kj
		  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN pendaftaran.konsul ks ON kj.NOPEN=ks.NOPEN AND kj.RUANGAN=ks.ASAL
		  LEFT JOIN master.ruangan tj ON ks.TUJUAN=tj.ID AND tj.JENIS=5
		  LEFT JOIN master.dokter dk ON ks.DOKTER_ASAL=dk.ID
		  LEFT JOIN master.pegawai dok ON dk.NIP=dok.NIP
		, master.ruangan jkr
		  LEFT JOIN master.referensi rf ON jkr.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	WHERE p.NORM=pd.NORM AND pd.NOMOR=kj.NOPEN AND kj.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.NOMOR=PNOPEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
