-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
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

-- membuang struktur untuk procedure laporan.LaporanKunjunganPerpasien
DROP PROCEDURE IF EXISTS `LaporanKunjunganPerpasien`;
DELIMITER //
CREATE PROCEDURE `LaporanKunjunganPerpasien`(
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
	SELECT CONCAT(''LAPORAN KUNJUNGAN '',UPPER(jk.DESKRIPSI),'' PER PASIEN'') JENISLAPORAN, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,TANGGAL_LAHIR),'')'') TGL_LAHIR
		, rjk.DESKRIPSI JENISKELAMIN
		, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
		, ref.DESKRIPSI CARABAYAR
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, su.DESKRIPSI UNITPELAYANAN
		, INST.NAMAINST, INST.ALAMATINST
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, IF(tk.REF IS NULL OR jkr.JENIS_KUNJUNGAN=3,master.getNamaLengkapPegawai(dok.NIP)
			,IF(jkr.JENIS_KUNJUNGAN=4,master.getNamaLengkapPegawai(dokl.NIP)
			 ,IF(jkr.JENIS_KUNJUNGAN=5,(SELECT master.getNamaLengkapPegawai(dokr.NIP)
					FROM layanan.hasil_rad hr
					      LEFT JOIN master.dokter dokr ON hr.DOKTER=dokr.ID
						, layanan.tindakan_medis tm
					WHERE hr.TINDAKAN_MEDIS=tm.ID AND hr.`STATUS`!=0 AND tm.`STATUS`!=0
					 AND tm.KUNJUNGAN=tk.NOMOR  AND hr.DOKTER!=0
					 LIMIT 1),master.getNamaLengkapPegawai(dokj.NIP)))) DOKTER_REG
	FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pd.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
		, pendaftaran.kunjungan tk
		  LEFT JOIN pendaftaran.konsul ks ON tk.REF=ks.NOMOR AND ks.STATUS!=0
		  LEFT JOIN pendaftaran.jawaban_konsul jks ON tk.REF=jks.NOMOR AND jks.STATUS!=0
		  LEFT JOIN master.dokter dokj ON jks.DOKTER=dokj.ID
		  LEFT JOIN layanan.order_lab lab ON tk.REF=lab.NOMOR AND lab.STATUS!=0
		  LEFT JOIN layanan.catatan_hasil_lab lab1 ON lab.KUNJUNGAN=lab1.KUNJUNGAN
		  LEFT JOIN master.dokter dokl ON lab1.DOKTER=dokl.ID
		  LEFT JOIN layanan.order_rad rad ON tk.REF=rad.NOMOR AND rad.STATUS!=0
		  LEFT JOIN pendaftaran.kunjungan kjr ON rad.KUNJUNGAN=kjr.NOMOR AND kjr.STATUS!=0
		  LEFT JOIN master.ruangan rad1 ON kjr.RUANGAN=rad1.ID
		, master.ruangan jkr
		  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
			FROM aplikasi.instansi ai
				, master.ppk p
			WHERE ai.PPK=p.ID) INST
		, (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN  AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=',LAPORAN,'
			AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
			AND tk.RUANGAN LIKE ''',vRUANGAN,'''
			',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
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
