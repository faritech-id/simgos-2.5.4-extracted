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

-- membuang struktur untuk procedure laporan.LaporanResponTime
DROP PROCEDURE IF EXISTS `LaporanResponTime`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanResponTime`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT


)
BEGIN


	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
					SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, ra.DESKRIPSI RUANGAN_AWAL, hl.TANGGAL TGL_HASIL
						, DATE_FORMAT(TIMEDIFF(k.MASUK,olb.TANGGAL),''%H:%i:%s'') SELISIH1
						, DATE_FORMAT(TIMEDIFF(hl.TANGGAL,k.MASUK),''%H:%i:%s'') SELISIH2
						, DATE_FORMAT(TIMEDIFF(hl.TANGGAL,olb.TANGGAL),''%H:%i:%s'') SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
					FROM layanan.order_lab olb
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_lab hl ON tm.ID=hl.TINDAKAN_MEDIS AND hl.`STATUS`=2
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE olb.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND olb.`STATUS`!=0
					  AND olb.NOMOR=k.REF AND k.RUANGAN=r.ID AND k.`STATUS`!=0
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				GROUP BY olb.NOMOR
				UNION
				SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, ra.DESKRIPSI RUANGAN_AWAL, hl.TANGGAL TGL_HASIL
						, DATE_FORMAT(TIMEDIFF(k.MASUK,olb.TANGGAL),''%H:%i:%s'') SELISIH1
						, DATE_FORMAT(TIMEDIFF(hl.TANGGAL,k.MASUK),''%H:%i:%s'') SELISIH2
						, DATE_FORMAT(TIMEDIFF(hl.TANGGAL,olb.TANGGAL),''%H:%i:%s'') SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
					FROM layanan.order_rad olb
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_rad hl ON tm.ID=hl.TINDAKAN_MEDIS AND hl.`STATUS`=2
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM  
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE olb.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND olb.`STATUS`!=0
					 AND olb.NOMOR=k.REF AND k.RUANGAN=r.ID AND k.`STATUS`!=0 
					 AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				  GROUP BY olb.NOMOR
		');
	
/*	SELECT @sqlText; */
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
