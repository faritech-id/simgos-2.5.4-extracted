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

-- membuang struktur untuk procedure laporan.LaporanPendapatanPerCaraBayar
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerCaraBayar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPendapatanPerCaraBayar`(
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
		SELECT INST.*, ref.ID IDCARABAYAR, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, JENISCARABAYAR, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
				, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
				, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
				
		FROM master.referensi ref
		    LEFT JOIN (SELECT JENISCARABAYAR, TAGIHAN, REF, JENIS, (SUM(ADMINISTRASI) - pembayaran.getTotalDiskonAdministrasi(ab.TAGIHAN)) ADMINISTRASI
								, (SUM(SARANA) - pembayaran.getTotalDiskonSarana(ab.TAGIHAN)) SARANA, SUM(BHP) BHP
								, (SUM(DOKTER_OPERATOR) - pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
								, SUM(PENATA_ANASTESI) PENATA_ANASTESI
								, (SUM(PARAMEDIS) - pembayaran.getTotalDiskonParamedis(ab.TAGIHAN)) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
								
								, TOTALTAGIHAN
								, (pembayaran.getTotalDiskon(TAGIHAN)+ pembayaran.getTotalDiskonDokter(TAGIHAN)) TOTALDISKON
								, TGLBAYAR
								, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
								, RUANGAN, CARABAYAR, TGLREG
							FROM (
							/*Tindakan*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
										, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
										, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
									
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
							  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
									   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
									 , master.tarif_tindakan tt 
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tt.ID AND rt.JENIS=3
								GROUP BY pj.JENIS
								UNION
						/*Administrasi Non Pelayanan Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
									
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
									 , pembayaran.rincian_tagihan rt 
									 ,  master.tarif_administrasi ta 
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID NOT IN (3,4)
								GROUP BY pj.JENIS
								UNION
								/*Administrasi Pelayanan Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
								FROM pembayaran.pembayaran_tagihan t
								     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
									  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
									  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
									  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
									  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
									  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
									  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
									 , pembayaran.rincian_tagihan rt 
									  LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
							  		  LEFT JOIN `master`.ruangan r ON r.ID = kj.RUANGAN
							  		  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
									 ,  master.tarif_administrasi ta 
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kj.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID IN (3,4)
								GROUP BY pj.JENIS
								UNION
								/*Akomodasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
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
									 ,  master.tarif_ruang_rawat trr
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=2
								GROUP BY pj.JENIS
								UNION
								
								/*Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(rt.TARIF * rt.JUMLAH) BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(rt.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
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
									 , inventory.harga_barang tf
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=tf.ID AND rt.JENIS=4
								GROUP BY pj.JENIS
								UNION
								/*Paket*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI) ADMINISTRASI, SUM(tt.SARANA) SARANA, SUM(tt.BHP) BHP
										, SUM(tt.DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA) DOKTER_LAINNYA
										, SUM(tt.PENATA_ANASTESI) PENATA_ANASTESI, SUM(tt.PARAMEDIS) PARAMEDIS, SUM(tt.NON_MEDIS) NON_MEDIS, SUM(tt.TARIF) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
								FROM pembayaran.pembayaran_tagihan t
								     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
									  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
									  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
									  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
									  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
									  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
									  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
									 , pembayaran.rincian_tagihan_paket rt 
									   LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID
							  		   LEFT JOIN `master`.tindakan mt ON mt.ID = tm.TINDAKAN
							  		   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
							  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
									   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
									   LEFT JOIN master.distribusi_tarif_paket_detil tt ON rt.TARIF_ID=tt.ID
						   	      LEFT JOIN master.paket_detil pdt ON rt.PAKET_DETIL=pdt.ID
   	  						      LEFT JOIN master.paket pkt ON pdt.PAKET=pkt.ID
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  
								GROUP BY pj.JENIS
								UNION
								/*Penjualan*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, crbyr.ID JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
										, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
									FROM pembayaran.pembayaran_tagihan t
										  LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
									     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
									     LEFT JOIN penjualan.penjualan ppj ON t.TAGIHAN=ppj.NOMOR
									     LEFT JOIN master.ruangan ru ON ppj.RUANGAN=ru.ID AND ru.JENIS=5
									     LEFT JOIN master.referensi rfu ON ru.JENIS_KUNJUNGAN=rfu.ID AND rfu.JENIS=15
									     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
											FROM aplikasi.instansi ai
												, master.ppk p
											WHERE ai.PPK=p.ID) INST
									WHERE t.`STATUS` !=0 AND t.JENIS=8 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND ppj.RUANGAN LIKE ''',vRUANGAN,'''  AND ru.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
									GROUP BY crbyr.ID
									UNION
									/*O2*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, pj.JENIS JENISCARABAYAR
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										
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
									 ,  master.tarif_o2 trr
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=6
								GROUP BY pj.JENIS
								
							) ab
							GROUP BY JENISCARABAYAR) a ON a.JENISCARABAYAR=ref.ID
			, master.jenis_referensi jref
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID ) INST
			
			WHERE ref.JENIS=jref.ID AND jref.ID=10 AND SARANA!=0
			GROUP BY ref.ID
			ORDER BY ref.ID');
			
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
