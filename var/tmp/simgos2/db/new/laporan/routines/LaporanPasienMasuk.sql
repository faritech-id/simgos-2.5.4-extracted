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

-- membuang struktur untuk procedure laporan.LaporanPasienMasuk
DROP PROCEDURE IF EXISTS `LaporanPasienMasuk`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPasienMasuk`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `CARAKELUAR` TINYINT, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
				, INSERT(INSERT(LPAD(p.NORM,6,''0''),3,0,''-''),6,0,''-'') NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(pk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pp.NOMOR NOPEN, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, r.DESKRIPSI UNITPELAYANAN
				, IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(rk.KAMAR, '' - '', kls.DESKRIPSI), '''') KAMAR
				, INST.NAMAINST, INST.ALAMATINST
			FROM pendaftaran.pendaftaran pp
			     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			     LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN layanan.pasien_pulang lpp ON pp.NOMOR=lpp.NOPEN AND lpp.`STATUS`!=0
				, pendaftaran.tujuan_pasien tp
				, master.ruangan r
				, pendaftaran.kunjungan pk
				  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  		     LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		     LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			
			WHERE p.NORM=pp.NORM AND pp.NOMOR=tp.NOPEN  AND pp.NOMOR=pk.NOPEN AND tp.RUANGAN=pk.RUANGAN AND pp.STATUS IN (1,2) AND pk.REF IS NULL
					',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
					AND pk.RUANGAN=r.ID AND r.JENIS=5 AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pk.STATUS IN (1,2)
					AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					');
					

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
