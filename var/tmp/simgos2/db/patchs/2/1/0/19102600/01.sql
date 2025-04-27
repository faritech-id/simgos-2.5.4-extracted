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

	/*Masih tampilan masternya*/
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, ref.ID IDCARABAYAR, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, JENISCARABAYAR, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
				, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
				, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
				, SUM(RADIOGRAFER) RADIOGRAFER, SUM(ANALIS ) ANALIS, SUM(PEMULASARAN_JENAZAH) PEMULASARAN_JENAZAH
				, SUM(EVAKUATOR) EVAKUATOR, SUM(EVAKUATOR) DRIVER
		FROM master.referensi ref
		    LEFT JOIN (SELECT JENISCARABAYAR, TAGIHAN, REF, JENIS, (SUM(ADMINISTRASI) - pembayaran.getTotalDiskonAdministrasi(ab.TAGIHAN)) ADMINISTRASI
								, (SUM(SARANA) - pembayaran.getTotalDiskonSarana(ab.TAGIHAN)) SARANA, SUM(BHP) BHP
								, (SUM(DOKTER_OPERATOR) - pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
								, SUM(PENATA_ANASTESI) PENATA_ANASTESI
								, (SUM(PARAMEDIS) - pembayaran.getTotalDiskonParamedis(ab.TAGIHAN)) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
								, SUM(RADIOGRAFER) RADIOGRAFER, SUM(ANALIS ) ANALIS, SUM(PEMULASARAN_JENAZAH) PEMULASARAN_JENAZAH
								, SUM(EVAKUATOR) EVAKUATOR, SUM(EVAKUATOR) DRIVER
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
										, SUM(tt.RADIOGRAFER * rt.JUMLAH) RADIOGRAFER, SUM(tt.ANALIS * rt.JUMLAH) ANALIS, SUM(tt.PEMULASARAN_JENAZAH * rt.JUMLAH) PEMULASARAN_JENAZAH
										, SUM(tt.EVAKUATOR * rt.JUMLAH) EVAKUATOR, SUM(tt.DRIVER * rt.JUMLAH) DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
			
/*SELECT @sqlText;*/
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

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
	
#	SELECT @sqlText;  
   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure laporan.LaporanPendapatanPerPasien
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerPasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPendapatanPerPasien`(
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
		'SELECT INST.NAMAINST, INST.ALAMATINST,INSTALASI, ab.TAGIHAN, ab.REF, ab.JENIS, (SUM(ADMINISTRASI) - pembayaran.getTotalDiskonAdministrasi(ab.TAGIHAN)) ADMINISTRASI
		, (SUM(SARANA) - pembayaran.getTotalDiskonSarana(ab.TAGIHAN)) SARANA, SUM(BHP) BHP
		, (SUM(DOKTER_OPERATOR) - pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
		, SUM(PENATA_ANASTESI) PENATA_ANASTESI
		, (SUM(PARAMEDIS) - pembayaran.getTotalDiskonParamedis(ab.TAGIHAN)) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
		, SUM(RADIOGRAFER) RADIOGRAFER, SUM(ANALIS ) ANALIS, SUM(PEMULASARAN_JENAZAH) PEMULASARAN_JENAZAH
		, SUM(EVAKUATOR) EVAKUATOR, SUM(EVAKUATOR) DRIVER
		, TOTALTAGIHAN
		, (pembayaran.getTotalDiskon(ab.TAGIHAN)+ pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) TOTALDISKON
		, NORM, NAMAPASIEN, NOPEN,  TGLBAYAR
		, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
		, RUANGAN, CARABAYAR, TGLREG
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, ASAL_REG
	FROM (
	/*Tindakan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
				, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, SUM(tt.RADIOGRAFER * rt.JUMLAH) RADIOGRAFER, SUM(tt.ANALIS * rt.JUMLAH) ANALIS, SUM(tt.PEMULASARAN_JENAZAH * rt.JUMLAH) PEMULASARAN_JENAZAH
				, SUM(tt.EVAKUATOR * rt.JUMLAH) EVAKUATOR, SUM(tt.DRIVER * rt.JUMLAH) DRIVER
				, IF(master.getAsalRegistrasi(kjgn.REF) IS NULL,rf.DESKRIPSI,master.getAsalRegistrasi(kjgn.REF)) ASAL_REG
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
		GROUP BY t.TAGIHAN
		UNION
/*Administrasi Non Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, rf.DESKRIPSI ASAL_REG
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
		GROUP BY t.TAGIHAN
		UNION
		/*Administrasi Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, rf.DESKRIPSI ASAL_REG
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
	  		  LEFT JOIN pendaftaran.konsul ks ON kj.REF=ks.NOMOR AND ks.`STATUS`!=0
			  LEFT JOIN pendaftaran.kunjungan asal ON ks.KUNJUNGAN=asal.NOMOR AND asal.`STATUS`!=0
			  LEFT JOIN `master`.ruangan rasal ON rasal.ID = asal.RUANGAN
			  LEFT JOIN master.referensi rf1 ON rasal.JENIS_KUNJUNGAN=rf1.ID AND rf1.JENIS=15
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kj.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Akomodasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, IF(master.getAsalRegistrasi(kjgn.REF) IS NULL,rf.DESKRIPSI,master.getAsalRegistrasi(kjgn.REF)) ASAL_REG
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
		GROUP BY t.TAGIHAN
		UNION
		
		/*Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(rt.TARIF * rt.JUMLAH) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(rt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, IF(master.getAsalRegistrasi(kjgn.REF) IS NULL,rf.DESKRIPSI,master.getAsalRegistrasi(kjgn.REF)) ASAL_REG
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
		GROUP BY t.TAGIHAN
		UNION
		/*Paket*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tp.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tp.SARANA * rt.JUMLAH) SARANA, SUM(tp.BHP * rt.JUMLAH) BHP
				, SUM(tp.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tp.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tp.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tp.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tp.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tp.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tp.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, rf.DESKRIPSI ASAL_REG
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
			 , master.distribusi_tarif_paket tp
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
		GROUP BY t.TAGIHAN
		UNION
		/*Penjualan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
				, '''' NORM, ppj.PENGUNJUNG NAMAPASIEN, '''' NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
				, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, rfu.DESKRIPSI ASAL_REG
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
			GROUP BY t.TAGIHAN
			UNION
			/*O2*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
				, 0 EVAKUATOR, 0 DRIVER
				, IF(master.getAsalRegistrasi(kjgn.REF) IS NULL,rf.DESKRIPSI,master.getAsalRegistrasi(kjgn.REF)) ASAL_REG
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
		GROUP BY t.TAGIHAN
	) ab
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
		FROM aplikasi.instansi ai
			, master.ppk p
		WHERE ai.PPK=p.ID) INST
	GROUP BY ab.TAGIHAN
			
	');
	
#	SELECT @sqlText;  
   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure laporan.LaporanPendapatanPerUnit
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerUnit`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPendapatanPerUnit`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT

)
BEGIN	

	/*Masih tampilan masternya*/
	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT INST.*, r.ID IDRUANGAN, r.JENIS JENISRUANGAN 
				, IF(''',RUANGAN,'''='''' OR LENGTH(''',RUANGAN,''')<5	
						, IF(r.JENIS=2, CONCAT(SPACE(r.JENIS*3), r.DESKRIPSI)
						, IF(r.JENIS=3, CONCAT(SPACE(r.JENIS*4), r.DESKRIPSI)
						, IF(r.JENIS=4, CONCAT(SPACE(r.JENIS*5), r.DESKRIPSI)
						, IF(r.JENIS=5, CONCAT(SPACE(r.JENIS*6), r.DESKRIPSI)
						, r.DESKRIPSI))))
					, IF(LENGTH(''',RUANGAN,''')<7
						, IF(r.JENIS=4, CONCAT(SPACE(r.JENIS*3), r.DESKRIPSI)
						, IF(r.JENIS=5, CONCAT(SPACE(r.JENIS*4), r.DESKRIPSI)
						, r.DESKRIPSI))
					, IF(LENGTH(''',RUANGAN,''')<9
						, IF(r.JENIS=5, CONCAT(SPACE(r.JENIS*3), r.DESKRIPSI)
						, r.DESKRIPSI)
					, r.DESKRIPSI))) RUANGAN
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, IDRUANGAN, a.TAGIHAN, a.REF, a.JENIS, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
				, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
				, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
				, SUM(RADIOGRAFER) RADIOGRAFER, SUM(ANALIS ) ANALIS, SUM(PEMULASARAN_JENAZAH) PEMULASARAN_JENAZAH
				, SUM(EVAKUATOR) EVAKUATOR, SUM(EVAKUATOR) DRIVER
				, TOTALTAGIHAN
				, TOTALDISKON
				, TGLBAYAR
				, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
				, RUANGAN, CARABAYAR, TGLREG
			FROM master.ruangan r
				  LEFT JOIN (SELECT IDRUANGAN, TAGIHAN, REF, JENIS, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
								, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
								, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
								, SUM(RADIOGRAFER) RADIOGRAFER, SUM(ANALIS ) ANALIS, SUM(PEMULASARAN_JENAZAH) PEMULASARAN_JENAZAH
								, SUM(EVAKUATOR) EVAKUATOR, SUM(EVAKUATOR) DRIVER
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
										, DATE(t.TANGGAL) TGLBAYAR, kjgn.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, SUM(tt.RADIOGRAFER * rt.JUMLAH) RADIOGRAFER, SUM(tt.ANALIS * rt.JUMLAH) ANALIS, SUM(tt.PEMULASARAN_JENAZAH * rt.JUMLAH) PEMULASARAN_JENAZAH
										, SUM(tt.EVAKUATOR * rt.JUMLAH) EVAKUATOR, SUM(tt.DRIVER * rt.JUMLAH) DRIVER
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
								GROUP BY kjgn.RUANGAN
								UNION
						/*Administrasi Non Pelayanan Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, tp.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
								GROUP BY tp.RUANGAN
								UNION
								/*Administrasi Pelayanan Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, kj.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
								GROUP BY kj.RUANGAN
								UNION
								/*Akomodasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, kjgn.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
								GROUP BY kjgn.RUANGAN
								UNION
								
								/*Farmasi*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(rt.TARIF * rt.JUMLAH) BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(rt.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, kjgn.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
								GROUP BY kjgn.RUANGAN
								UNION
								/*Paket*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tp.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tp.SARANA * rt.JUMLAH) SARANA, SUM(tp.BHP * rt.JUMLAH) BHP
										, SUM(tp.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tp.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tp.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
										, SUM(tp.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tp.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tp.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tp.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, tp.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
									 , master.distribusi_tarif_paket tp
								WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
											',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
										     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
								GROUP BY tp.RUANGAN
								UNION
								/*Penjualan*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, ppj.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
										, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
									GROUP BY ppj.RUANGAN
									UNION
									/*O2*/
								SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
										, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
										, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
										, DATE(t.TANGGAL) TGLBAYAR, kjgn.RUANGAN IDRUANGAN
										, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
										, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
										, 0 RADIOGRAFER, 0 ANALIS, 0 PEMULASARAN_JENAZAH
										, 0 EVAKUATOR, 0 DRIVER
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
								GROUP BY kjgn.RUANGAN
							) ab
							GROUP BY IDRUANGAN) a  ON IDRUANGAN LIKE CONCAT(r.ID,''%'')
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID ) INST
				
			WHERE r.ID LIKE ''',vRUANGAN,'''
			GROUP BY r.ID
			ORDER BY r.ID');
			
/*SELECT @sqlText;*/
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
