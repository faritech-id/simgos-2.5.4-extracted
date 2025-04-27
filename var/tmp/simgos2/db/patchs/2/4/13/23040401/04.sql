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

-- membuang struktur untuk procedure laporan.LaporanResponTimeIKT
DROP PROCEDURE IF EXISTS `LaporanResponTimeIKT`;
DELIMITER //
CREATE PROCEDURE `LaporanResponTimeIKT`(
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
					SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, ra.DESKRIPSI RUANGAN_AWAL
						, IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, master.getTglHasilLab(k.NOMOR)) TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, (SELECT a.TANGGAL
										FROM layanan.hasil_lab a 
											, layanan.tindakan_medis b
										WHERE b.KUNJUNGAN=k.NOMOR AND a.TINDAKAN_MEDIS=b.ID 
										ORDER BY a.TANGGAL ASC LIMIT 1)),k.MASUK) SELISIH2
						, TIMEDIFF(IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, (SELECT a.TANGGAL
									FROM layanan.hasil_lab a 
										, layanan.tindakan_medis b
									WHERE b.KUNJUNGAN=k.NOMOR AND a.TINDAKAN_MEDIS=b.ID 
									ORDER BY a.TANGGAL ASC LIMIT 1)),olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
					FROM layanan.order_lab olb
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
					     LEFT JOIN layanan.order_detil_lab odl ON odl.ORDER_ID = olb.NOMOR
						, pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_lab hl ON tm.ID=hl.TINDAKAN_MEDIS
						  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
						  LEFT JOIN master.dokter drh ON chl.DOKTER=drh.ID
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						  LEFT JOIN layanan.hasil_pa pa ON k.NOMOR=pa.KUNJUNGAN AND pa.`STATUS`!=0
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE olb.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND olb.`STATUS`!=0
					  AND olb.NOMOR=k.REF AND k.RUANGAN=r.ID AND k.`STATUS`!=0 AND t.ID = ''1094'' AND k.FINAL_HASIL = 1
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				GROUP BY olb.NOMOR
				UNION
				SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA
						, ra.DESKRIPSI RUANGAN_AWAL, hl.TANGGAL TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(hl.TANGGAL,k.MASUK) SELISIH2
						, TIMEDIFF(hl.TANGGAL,olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
					FROM layanan.order_rad olb
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_rad hl ON tm.ID=hl.TINDAKAN_MEDIS AND hl.`STATUS`=2
						  LEFT JOIN master.dokter drh ON hl.DOKTER=drh.ID
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
					 AND olb.NOMOR=k.REF AND k.RUANGAN=r.ID AND k.`STATUS`!=0  AND t.ID IN (''2350'',''2353'',''2355'',''2361'')
					 AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				  GROUP BY olb.NOMOR
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
