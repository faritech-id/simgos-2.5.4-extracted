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

-- membuang struktur untuk procedure laporan.LaporanJasaAnastesiPerPasienPalu
DROP PROCEDURE IF EXISTS `LaporanJasaAnastesiPerPasienPalu`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanJasaAnastesiPerPasienPalu`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `CARABAYAR` INT, IN `DOKTER` INT)
BEGIN
	
	

	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
	  'SELECT * FROM (
	  	SELECT RAND() QID, INST.NAMAINST, INST.ALAMATINST,kjgn.NOPEN, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN, tm.TANGGAL
							, t.NAMA NAMATINDAKAN
							, CONCAT(INSERT(INSERT(INSERT(LPAD(ps.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-''),'' - '',master.getNamaLengkap(ps.NORM)) NAMAPASIEN
						   , crbyr.DESKRIPSI CARABAYAR, ptmanas.MEDIS
							, master.getNamaLengkapPegawai(mpdokanas.NIP) PETUGASMEDIS
			           	, (IF(ds.TOTAL IS NULL,0,ds.TOTAL)) DISKON
			           	, (IF(pj.JENIS=2
			           			/* berlakukan aturan untuk pasien BPJS*/
									,IF(tr.ID IS NOT NULL,((0.2 * hslgr.TOTALTARIF)*0.5), (0.18 * hslgr.TOTALTARIF))
						  			,mtt.DOKTER_ANASTESI
						  			)) DOKTER_OPERATOR
				FROM pembayaran.pembayaran_tagihan pt
				   , pembayaran.rincian_tagihan rt
				     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
				     LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
				     LEFT JOIN  master.tindakan_rincian tr ON t.ID=tr.TINDAKAN AND tr.STATUS=1
				     LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
				  	  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1  AND ptm.KE=1 AND ptm.STATUS=1
				  	   LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					  LEFT JOIN layanan.petugas_tindakan_medis ptmanas ON tm.ID=ptmanas.TINDAKAN_MEDIS AND ptmanas.JENIS=2 AND ptmanas.KE=1 AND ptmanas.STATUS=1
					  LEFT JOIN pembayaran.diskon_dokter ds ON rt.TAGIHAN=ds.TAGIHAN AND ds.DOKTER=ptmanas.MEDIS AND ds.STATUS=1
				  	  LEFT JOIN master.dokter dokanas ON ptmanas.MEDIS=dokanas.ID
					  LEFT JOIN master.pegawai mpdokanas ON dokanas.NIP=mpdokanas.NIP
					  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		  LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		  LEFT JOIN inacbg.hasil_grouping hslgr ON p.NOMOR=hslgr.NOPEN 
			  		  LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
			        LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  		  LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
			  	 	  LEFT JOIN master.ruangan r ON r.ID = kjgn.RUANGAN
			  		  LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  	  	  LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		  LEFT JOIN master.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		  LEFT JOIN master.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		  LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
			   	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
								FROM aplikasi.instansi ai
									, master.ppk p
								WHERE ai.PPK=p.ID) INST
			WHERE pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pt.`STATUS` !=0 AND pt.JENIS=1 AND tk.ID IS NULL
			   AND rt.JENIS = 3 AND rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` NOT IN (0) AND mtt.DOKTER_OPERATOR !=0
			  ',IF(RUANGAN=0,'',CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''')),' 
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
		) ab
		WHERE DOKTER_OPERATOR!=0 AND MEDIS IS NOT NULL AND MEDIS!=0
		ORDER BY MEDIS, TANGGAL
	');
	
  
 PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
