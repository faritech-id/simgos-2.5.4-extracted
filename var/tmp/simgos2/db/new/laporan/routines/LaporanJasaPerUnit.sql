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

-- membuang struktur untuk procedure laporan.LaporanJasaPerUnit
DROP PROCEDURE IF EXISTS `LaporanJasaPerUnit`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanJasaPerUnit`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `CARABAYAR` INT, IN `DOKTER` INT)
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
						,IF(r.JENIS=4, CONCAT(SPACE(r.JENIS*3), r.DESKRIPSI)
						, IF(r.JENIS=5, CONCAT(SPACE(r.JENIS*4), r.DESKRIPSI)
						, r.DESKRIPSI))
					, IF(LENGTH(''',RUANGAN,''')<9
						,IF(r.JENIS=5, CONCAT(SPACE(r.JENIS*3), r.DESKRIPSI)
						, r.DESKRIPSI)
					, r.DESKRIPSI))) RUANGAN
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
				, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
				, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS
				, SUM(TARIF) TARIF
			FROM master.ruangan r
			     LEFT JOIN (
			     		/*Tindakan*/
				  			SELECT RAND() QID,kjgn.RUANGAN, SUM(mtt.ADMINISTRASI) ADMINISTRASI, SUM(mtt.SARANA) SARANA, SUM(mtt.BHP) BHP
										, SUM(mtt.DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(mtt.DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(mtt.DOKTER_LAINNYA) DOKTER_LAINNYA
										, SUM(mtt.PENATA_ANASTESI) PENATA_ANASTESI, SUM(mtt.PARAMEDIS ) PARAMEDIS, SUM(mtt.NON_MEDIS) NON_MEDIS, SUM(mtt.TARIF) TARIF
										
							FROM pembayaran.pembayaran_tagihan pt
							   , pembayaran.rincian_tagihan rt
							     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
							     LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
							  	  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
							  	  LEFT JOIN pembayaran.diskon_dokter ds ON rt.TAGIHAN=ds.TAGIHAN AND ds.DOKTER=ptm.MEDIS AND ds.STATUS=1
							  	  LEFT JOIN pembayaran.diskon dsk ON rt.TAGIHAN=dsk.TAGIHAN AND dsk.STATUS=1
							  	  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
								  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
								  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
						  		  LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
						  		  LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
						        LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
						  		  LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
						  	 	  LEFT JOIN master.ruangan r ON r.ID = kjgn.RUANGAN
						  		  LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
						  	  	  LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
						  		  LEFT JOIN master.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
						  		  LEFT JOIN master.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
						  		  LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
						   	
							WHERE pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pt.`STATUS` !=0 AND pt.JENIS=1
							  AND rt.JENIS = 3 AND rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` !=0 
							  ',IF(RUANGAN=0,'',CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''')),' 
								',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
							GROUP BY kjgn.RUANGAN
							UNION
							/*Paket*/
							SELECT RAND() QID,kjgn.RUANGAN, SUM(mtt.ADMINISTRASI) ADMINISTRASI, SUM(mtt.SARANA) SARANA, SUM(mtt.BHP) BHP
										, SUM(mtt.DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(mtt.DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(mtt.DOKTER_LAINNYA) DOKTER_LAINNYA
										, SUM(mtt.PENATA_ANASTESI) PENATA_ANASTESI, SUM(mtt.PARAMEDIS ) PARAMEDIS, SUM(mtt.NON_MEDIS) NON_MEDIS, SUM(mtt.TARIF) TARIF
										
							FROM pembayaran.pembayaran_tagihan pt
							   , pembayaran.rincian_tagihan_paket rt
							     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID 
							     LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
							  	  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND ptm.KE=1 AND ptm.STATUS=1
							  	  LEFT JOIN pembayaran.diskon_dokter ds ON rt.TAGIHAN=ds.TAGIHAN AND ds.DOKTER=ptm.MEDIS AND ds.STATUS=1
							  	  LEFT JOIN pembayaran.diskon dsk ON rt.TAGIHAN=dsk.TAGIHAN AND dsk.STATUS=1
							  	  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
								  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
								  LEFT JOIN layanan.petugas_tindakan_medis ptmanas ON tm.ID=ptmanas.TINDAKAN_MEDIS AND ptmanas.JENIS=2 AND ptmanas.KE=1
								  LEFT JOIN master.dokter dokanas ON ptmanas.MEDIS=dokanas.ID
								  LEFT JOIN master.pegawai mpdokanas ON dokanas.NIP=mpdokanas.NIP
								  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
						  		  LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
						  		  LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
						        LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
						  		  LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
						  	 	  LEFT JOIN master.ruangan r ON r.ID = kjgn.RUANGAN
						  		  LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
						  	  	  LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
						  		  LEFT JOIN master.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
						  		  LEFT JOIN master.distribusi_tarif_paket_detil mtt ON rt.TARIF_ID=mtt.ID
						   	  LEFT JOIN master.paket_detil pdt ON rt.PAKET_DETIL=pdt.ID
   	  						  LEFT JOIN master.paket pkt ON pdt.PAKET=pkt.ID
						   	
							WHERE pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pt.`STATUS` !=0 AND pt.JENIS=1
							   AND rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` !=0
							  ',IF(RUANGAN=0,'',CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''')),' 
								',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
								',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
							GROUP BY kjgn.RUANGAN
						) ab ON ab.RUANGAN LIKE CONCAT(r.ID,''%'')
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
