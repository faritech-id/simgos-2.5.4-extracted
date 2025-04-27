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

-- membuang struktur untuk procedure pendaftaran.CetakBuktiRegistrasi
DROP PROCEDURE IF EXISTS `CetakBuktiRegistrasi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakBuktiRegistrasi`(
	IN `PNOPEN` CHAR(10)

)
BEGIN
	SELECT LPAD(p.NORM,8,'0') NORM, CONCAT(master.getNamaLengkap(p.NORM),' (',IF(p.JENIS_KELAMIN=1,'L)','P)')) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') TGL_LAHIR
		, IF(DATE_FORMAT(p.TANGGAL,'%d-%m-%Y')=DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y'),'Baru','Lama') STATUSPENGUNJUNG
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN
		, rf.DESKRIPSI JENISRAWAT, dm.DIAGNOSA DIAGNOSA_MASUK
		, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, ar.NOMOR NOMORANTRI
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 AND ref.`STATUS`!=0
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID AND ppk.`STATUS`!=0
		  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		  LEFT JOIN master.diagnosa_masuk dm ON pd.DIAGNOSA_MASUK=dm.ID
		  LEFT JOIN pendaftaran.antrian_ruangan ar ON pd.NOMOR=ar.REF AND ar.JENIS=1 AND ar.`STATUS`!=0
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		, master.ruangan jkr
		  LEFT JOIN master.referensi rf ON jkr.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND tp.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.NOMOR=PNOPEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
