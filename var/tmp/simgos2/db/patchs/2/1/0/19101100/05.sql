-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.24 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk laporan
#CREATE DATABASE IF NOT EXISTS `laporan` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanPengunjungPerpasien
DROP PROCEDURE IF EXISTS `LaporanPengunjungPerpasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPengunjungPerpasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT






)
BEGIN

	/*
	Parameter Laporan = Jenis Kunjungan:
	1. Pengunjung Rawat Jalan
	2. Kunjungan Rawat Darurat (Observasi)
	3. Pasien Masuk Rawat Inap
	*/
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(TIMEDIFF(tk.MASUK,pd.TANGGAL),''%H:%i:%s'') SELISIH
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
				, INST.NAMAINST, INST.ALAMATINST
				, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
				, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
				  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
				, pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					');
					
/*SELECT @sqlText;*/
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
