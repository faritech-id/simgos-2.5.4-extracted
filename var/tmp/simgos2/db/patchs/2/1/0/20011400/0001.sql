-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.28 - MySQL Community Server (GPL)
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
		, TOTALTAGIHAN
		, (pembayaran.getTotalDiskon(ab.TAGIHAN)+ pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) TOTALDISKON
		, NORM, NAMAPASIEN, NOPEN,  TGLBAYAR
		, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
		, RUANGAN, CARABAYAR, TGLREG
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
	
	FROM (
	/*Tindakan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
				, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
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
				
				, TOTALTAGIHAN
				, TOTALDISKON
				, TGLBAYAR
				, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
				, RUANGAN, CARABAYAR, TGLREG
			FROM master.ruangan r
				  LEFT JOIN (SELECT IDRUANGAN, TAGIHAN, REF, JENIS, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
								, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
								, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
								
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

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;


-- Membuang struktur basisdata untuk pembayaran
#CREATE DATABASE IF NOT EXISTS `pembayaran` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakRincianPasienPerDokter
DROP PROCEDURE IF EXISTS `CetakRincianPasienPerDokter`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakRincianPasienPerDokter`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_HEADER_RINCIAN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DETIL_RINCIAN;	

	CREATE TEMPORARY TABLE TEMP_HEADER_RINCIAN ENGINE=MEMORY
		SELECT t.ID NOMOR_TAGIHAN
				 , INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
				 , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALREG
				 , `master`.getNamaLengkap(p.NORM) NAMALENGKAP
				 , pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR
				 , p.TANGGAL_LAHIR, CONCAT(CAST(rjk.DESKRIPSI AS CHAR(15)),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') UMUR 
				 , IF(pt.OLEH=0,pt.DESKRIPSI,master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA, t.ID IDTAGIHAN
				 , w.DESKRIPSI WILAYAH
				 , pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN
				 ,  @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN
				 , @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON 
				 , @tedc:=pembayaran.getTotalEDC(t.ID) TOTALEDC 
				 ,  @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 ,  @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
			/*	 , (IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(t.TOTAL > pjt.TOTAL,pjt.TARIF_INACBG_KELAS1,(t.TOTAL))) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN
				 , (pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON
				 , pembayaran.getTotalEDC(t.ID) TOTALEDC, pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 , (pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF(pj.JENIS=2,IF(pjt.NAIK_KELAS_VIP=1,
						IF(t.TOTAL < pjt.TOTAL,0,IF(((t.TOTAL - pjt.TARIF_INACBG_KELAS1) > (pjt.TARIF_INACBG_KELAS1 * 0.75)),(pjt.TARIF_INACBG_KELAS1 * 0.75) ,(t.TOTAL - pjt.TARIF_INACBG_KELAS1)))
						+ (pjt.TARIF_INACBG_KELAS1 - pjt.TOTAL)
					, IF(pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS - pjt.TOTAL)
					 , IF(pjt.NAIK_DIATAS_VIP=1, (t.TOTAL - IF(pjt.TOTAL > pjt.TOTAL_TAGIHAN_HAK,pjt.TOTAL, pjt.TOTAL_TAGIHAN_HAK))
					 , 0))),
					 (t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
					 pembayaran.getTotalEDC(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
					 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))+pembayaran.getTotalSubsidiTagihan(t.ID)))) JUMLAHBAYAR*/
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS = 1
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		       LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  		, aplikasi.instansi i
			   , master.ppk ppk
			   , master.wilayah w
		 WHERE t.ID = PTAGIHAN
		   AND t.JENIS = 1
		   AND t.`STATUS` IN (1, 2)
			AND ppk.ID = i.PPK
		   AND w.ID = ppk.WILAYAH;
	  
	CREATE TEMPORARY TABLE TEMP_DETIL_RINCIAN (
		`TAGIHAN` CHAR(10),
		`RUANGAN` VARCHAR(250),
		`LAYANAN` VARCHAR(100),
		`TANGGAL` DATETIME,
		`JUMLAH` DECIMAL(60,2),
		`TARIF` DECIMAL(60,2),
		`JENIS_KUNJUNGAN` TINYINT(4),
		`DOKTER` VARCHAR(100),
		`DOKTERKEDUA` VARCHAR(100),
		`DOKTERANASTESI` VARCHAR(100),
		`ADMINISTRASI` DECIMAL(60,2),
		`SARANA` DECIMAL(60,2),
		`BHP` DECIMAL(60,2),
		`DOKTER_OPERATOR` DECIMAL(60,2),
		`DOKTER_ANASTESI` DECIMAL(60,2),
		`DOKTER_LAINNYA` DECIMAL(60,2),
		`PENATA_ANASTESI` DECIMAL(60,2),
		`PARAMEDIS` DECIMAL(60,2),
		`NON_MEDIS` DECIMAL(60,2),
		`STATUSTINDAKANRINCIAN` TINYINT(4),
		`LAYANAN1` VARCHAR(250),
		`LAYANAN_OK` VARCHAR(250),
		`TARIF_LAYANAN_OK` VARCHAR(250),
		`RP` VARCHAR(250)
	)
	ENGINE=MEMORY;
	
	INSERT INTO TEMP_DETIL_RINCIAN
		SELECT rt.TAGIHAN,
				 CONCAT(
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT(r.DESKRIPSI,' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), 
						IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
				 ) RUANGAN,
				 adm.NAMA LAYANAN,
				 IF(rt.JENIS = 1, 
				 	IF(tadm.ADMINISTRASI = 1, krtp.TANGGAL, 
					 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR)
					 ), NULL) TANGGAL,
				 rt.JUMLAH, rt.TARIF
				 , IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN
				 , '' DOKTER
			    , '' DOKTERKEDUA
			 	 , '' DOKTERANASTESI
				 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
				 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
				 , '' STATUSTINDAKANRINCIAN
				 , adm.NAMA LAYANAN1
				 , '' LAYANAN_OK
				 , '' TARIF_LAYANAN_OK
				 , '' RP
		  FROM pembayaran.rincian_tagihan rt
		  	    
		  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	
		  		 
		  		 
				 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN AND p.`STATUS`!=0
		  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
		  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
		  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
		  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
		  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
		  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
		  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  		 
		  		 
				 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
		  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
		 WHERE rt.TAGIHAN = PTAGIHAN
		   AND rt.JENIS = 1 AND rt.STATUS = 1;
	
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , pkt.NAMA LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 5 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2 AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 2 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT * FROM (
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, CONCAT(t.NAMA,@dok1) LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NULL AND rt.STATUS = 1
	 UNION
	 
	 SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 'Tindakan Keperawatan' LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, SUM(rt.TARIF)
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, 'Tindakan Keperawatan' LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
			
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NOT NULL AND rt.STATUS = 1
	 GROUP BY RUANGAN,LAYANAN) ab
	 ORDER BY JENIS_KUNJUNGAN;
		  	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , b.NAMA LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4 AND f.`STATUS`!=0
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 4 AND rt.STATUS = 1;
	   	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 ref.DESKRIPSI LAYANAN,
			 IF(rt.JENIS =  6, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
		    , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , ref.DESKRIPSI LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 6 AND rt.STATUS = 1;
	
	SELECT *
	  FROM TEMP_HEADER_RINCIAN thr
	       , TEMP_DETIL_RINCIAN tdr
	 WHERE tdr.TAGIHAN = thr.NOMOR_TAGIHAN
	 ORDER BY JENIS_KUNJUNGAN;	
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonAdministrasi
DROP FUNCTION IF EXISTS `getTotalDiskonAdministrasi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalDiskonAdministrasi`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(ADMINISTRASI) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	IF FOUND_ROWS() = 0  OR VTOTAL IS NULL THEN
		RETURN 0;
	END IF;
	
	RETURN VTOTAL;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonParamedis
DROP FUNCTION IF EXISTS `getTotalDiskonParamedis`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalDiskonParamedis`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(PARAMEDIS) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	IF FOUND_ROWS() = 0  OR VTOTAL IS NULL THEN
		RETURN 0;
	END IF;
	
	RETURN VTOTAL;
END//
DELIMITER ;

-- membuang struktur untuk function pembayaran.getTotalDiskonSarana
DROP FUNCTION IF EXISTS `getTotalDiskonSarana`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalDiskonSarana`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTOTAL DECIMAL(60,2);
	
	SELECT SUM(AKOMODASI+SARANA_NON_AKOMODASI) INTO VTOTAL 
	  FROM pembayaran.diskon 
	 WHERE TAGIHAN = PTAGIHAN
	   AND STATUS = 1;
	
	IF FOUND_ROWS() = 0  OR VTOTAL IS NULL THEN
		RETURN 0;
	END IF;
	
	RETURN VTOTAL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
