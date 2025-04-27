-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanPengunjungPerpasien
DROP PROCEDURE IF EXISTS `LaporanPengunjungPerpasien`;
DELIMITER //
CREATE PROCEDURE `LaporanPengunjungPerpasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, TIMEDIFF(tk.MASUK,pd.TANGGAL) SELISIH
				, TIMEDIFF(tk.KELUAR,tk.MASUK) WKTPELAYANAN
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLORDER
				, TIMEDIFF(kf.MASUK,orr.TANGGAL) TERIMARESEP
				, TIMEDIFF(kf.KELUAR,kf.MASUK) OBATSIAP
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
				, INST.NAMAINST, INST.ALAMATINST
				, IF(mp.NIP IS NULL, ''ANJUNGAN PENDAFTARAN MANDIRI'', master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getNopenIRD(pd.NORM, pd.NOMOR), master.getNopenIRNA(pd.NORM, pd.NOMOR)) NOPENRDRI
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getSepIRD(pd.NORM, pd.NOMOR), master.getSepIRNA(pd.NORM, pd.NOMOR)) SEPRDRI
				, jkr.JENIS_KUNJUNGAN JNSK
				, kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , IF(jkr.JENIS_KUNJUNGAN=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pd.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jkr.JENIS_KUNJUNGAN=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LOS
				, IF(jkr.JENIS_KUNJUNGAN=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pd.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
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
		        LEFT JOIN inacbg.hasil_grouping cbg ON pd.NOMOR=cbg.NOPEN
			  	  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
			  	  LEFT JOIN layanan.pasien_pulang lpp ON pd.NOMOR=lpp.NOPEN AND lpp.STATUS=1
			  	  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			  	  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pd.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
			  	  LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
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
					GROUP BY pd.NOMOR
					ORDER BY UNITPELAYANAN, pd.TANGGAL					
					');
	
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
