-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure laporan.LaporanPendapatanPerKelas
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerKelas`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPendapatanPerKelas`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT  INST.NAMAINST, INST.ALAMATINST,INSTALASI, IDRUANGAN, RUANGAN, IDKELAS, KELAS, IDLAYANAN, NAMA, SUM(FREK) FREK, TARIF, SUM(TOTALTARIF) TOTALTARIF
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		FROM (
			/*administrasi & Materai*/
				SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
								, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, tp.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, rt.JENIS IDLAYANAN, adm.NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							  LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
							  LEFT JOIN master.ruang_kamar_tidur rkt ON res.RUANG_KAMAR_TIDUR=rkt.ID
						     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
							  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
							, pembayaran.rincian_tagihan rt 
							, master.tarif_administrasi ta 
							  LEFT JOIN `master`.administrasi adm ON adm.ID = ta.ADMINISTRASI
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
								',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
							     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID NOT IN (3,4)
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, IF(ta.ADMINISTRASI=2,1,rt.TARIF)
						UNION
						/*Tindakan*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
							   , INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, kjgn.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, tm.TINDAKAN IDLAYANAN, mt.NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							 , pembayaran.rincian_tagihan rt 
							   LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
					  		   LEFT JOIN `master`.tindakan mt ON mt.ID = tm.TINDAKAN
					  		   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
					  		   LEFT JOIN master.ruang_kamar_tidur rkt ON kjgn.RUANG_KAMAR_TIDUR=rkt.ID
						    	LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						      LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
					  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
							   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
							 , master.tarif_tindakan tt 
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
								',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
							    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tt.ID AND rt.JENIS=3
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF
						UNION
						/*Akomodasi*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
								, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, kjgn.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, rt.JENIS IDLAYANAN, ref.DESKRIPSI NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							, pembayaran.rincian_tagihan rt 
							  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
						  	  LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
						  	  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
						  	  LEFT JOIN master.ruang_kamar_tidur rkt ON kjgn.RUANG_KAMAR_TIDUR=rkt.ID
						     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
						     LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
						  ,  master.tarif_ruang_rawat trr
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
								',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
							     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' 
								       AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=2
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF
						UNION
						/*Farmasi*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
								, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, kjgn.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, rt.JENIS IDLAYANAN, ref.DESKRIPSI NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							, pembayaran.rincian_tagihan rt 
							  LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
							  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
							  LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
						  	  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
						  	  LEFT JOIN master.ruang_kamar_tidur rkt ON kjgn.RUANG_KAMAR_TIDUR=rkt.ID
						     LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
						     LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
						     LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
							, inventory.harga_barang tf
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
								',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
							     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								      AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=tf.ID AND rt.JENIS=4
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF
						UNION
						/*Paket*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
								, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, tp.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, rt.JENIS IDLAYANAN, ref.DESKRIPSI NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
							  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
							  LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
					  		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
					  		  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
					  		  LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
					  		 , pembayaran.rincian_tagihan rt
					  		   LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
							 , master.distribusi_tarif_paket tp
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
								',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
							     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								      AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF
						UNION
						/*Penjualan*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, '''' NORM, ppj.PENGUNJUNG NAMAPASIEN, '''' NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN, ppj.RUANGAN IDRUANGAN
								, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, 10 IDKELAS, ''Non Kelas'' KELAS, t.JENIS IDLAYANAN, ''Penjualan'' NAMA, SUM(ppjd.JUMLAH) FREK, 0 TARIF, SUM(t.TOTAL) TOTALTARIF
							FROM pembayaran.pembayaran_tagihan t
								  LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
							     LEFT JOIN penjualan.penjualan ppj ON t.TAGIHAN=ppj.NOMOR
							     LEFT JOIN penjualan.penjualan_detil ppjd ON ppj.NOMOR=ppjd.ID AND ppjd.`STATUS`!=0
							     LEFT JOIN master.ruangan ru ON ppj.RUANGAN=ru.ID AND ru.JENIS=5
							     LEFT JOIN master.referensi rfu ON ru.JENIS_KUNJUNGAN=rfu.ID AND rfu.JENIS=15
							     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
									FROM aplikasi.instansi ai
										, master.ppk p
									WHERE ai.PPK=p.ID) INST
							WHERE t.`STATUS` !=0 AND t.JENIS=8 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND ppj.RUANGAN LIKE ''',vRUANGAN,'''  AND ru.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
								     ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
							GROUP BY t.TAGIHAN
						UNION
						/*O2*/
						SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
								, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
								, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
								, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN, kjgn.RUANGAN IDRUANGAN
								, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
								, IF(kelas.ID IS NULL,10,kelas.ID) IDKELAS, IF(kelas.DESKRIPSI IS NULL,''Non Kelas'',kelas.DESKRIPSI) KELAS, rt.JENIS IDLAYANAN, ref.DESKRIPSI NAMA, SUM(rt.JUMLAH) FREK, rt.TARIF, SUM(rt.TARIF * rt.JUMLAH) TOTALTARIF
						FROM pembayaran.pembayaran_tagihan t
						     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
							  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
							  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
							  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
							  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
							, pembayaran.rincian_tagihan rt 
							  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
						  	  LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
						  	  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
						  	  LEFT JOIN master.ruang_kamar_tidur rkt ON kjgn.RUANG_KAMAR_TIDUR=rkt.ID
							  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
							  LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
							  LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
							 ,  master.tarif_o2 trr
						WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
							',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
						     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								       AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=6
						GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF) ab
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
				GROUP BY IDRUANGAN, IDKELAS, IDLAYANAN, TARIF
			
	');
	
   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
