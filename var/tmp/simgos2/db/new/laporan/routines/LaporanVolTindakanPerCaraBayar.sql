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

-- membuang struktur untuk procedure laporan.LaporanVolTindakanPerCaraBayar
DROP PROCEDURE IF EXISTS `LaporanVolTindakanPerCaraBayar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanVolTindakanPerCaraBayar`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `TINDAKAN` INT, IN `CARABAYAR` INT, IN `DOKTER` INT)
BEGIN


	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	 SELECT IDRUANG,RUANG,IDCARABAYAR, CARABAYAR, SUM(JMLKUNJ) JMLKUNJ, SUM(TOTALTAGIHAN) TOTALTAGIHAN, INST.NAMAINST, INST.ALAMATINST,INSTALASI,CARABAYARHEADER
	 FROM (
			SELECT RAND() QID, kjgn.RUANGAN IDRUANG, r.DESKRIPSI RUANG, pj.JENIS IDCARABAYAR, cr.DESKRIPSI CARABAYAR, 0 JMLKUNJ, SUM(rt.JUMLAH * rt.TARIF) TOTALTAGIHAN,
					 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
					 IF(',CARABAYAR,'=0,''Semua'',cr.DESKRIPSI) CARABAYARHEADER
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
			  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
					 LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1 AND ptm.STATUS!=0
					 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					 LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			  		 /*order lab*/
			  		 LEFT JOIN layanan.order_lab ol ON kjgn.REF=ol.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuol ON ol.KUNJUNGAN=kuol.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktol ON rktol.ID = kuol.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkol ON rkol.ID = rktol.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsol ON klsol.JENIS = 19 AND klsol.ID = rkol.KELAS
			  		 /*order rad*/
			  		 LEFT JOIN layanan.order_rad orad ON kjgn.REF=orad.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuorad ON orad.KUNJUNGAN=kuorad.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktrad ON rktrad.ID = kuorad.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkrad ON rk.ID = rktrad.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsrad ON klsrad.JENIS = 19 AND klsrad.ID = rkrad.KELAS
			 WHERE rt.`STATUS`!=0 AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''
			   AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			   AND rt.JENIS = 3
			   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
				',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),'
			GROUP BY kjgn.RUANGAN, pj.JENIS
			UNION
			SELECT RAND() QID, tk.RUANGAN IDRUANG, jkr.DESKRIPSI RUANG, ref.ID IDCARABAYAR
			, ref.DESKRIPSI CARABAYAR
			, COUNT(pd.NOMOR) JMLKUNJ, 0 TOTALTAGIHAN
			#, INST.NAMAINST, INST.ALAMATINST
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
		FROM master.pasien p
			, pendaftaran.pendaftaran pd
			  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			  LEFT JOIN master.ikatan_kerja_sama iks ON ref.ID=iks.ID AND ref.JENIS=10
			  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
			  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
			  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
			, pendaftaran.kunjungan tk
			, master.ruangan jkr
			  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
		WHERE p.NORM=pd.NORM AND pd.NOMOR=tk.NOPEN AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2)
				AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 
				AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND tk.RUANGAN LIKE ''',vRUANGAN,'''
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		GROUP BY tk.RUANGAN,ref.ID) a
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
		GROUP BY IDRUANG, IDCARABAYAR
		');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
