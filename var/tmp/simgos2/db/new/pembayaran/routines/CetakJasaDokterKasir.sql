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

-- membuang struktur untuk procedure pembayaran.CetakJasaDokterKasir
DROP PROCEDURE IF EXISTS `CetakJasaDokterKasir`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakJasaDokterKasir`(IN `PNOMOR` VARCHAR(50), IN `PKASIR` SMALLINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`,
			 master.getNamaLengkapPegawai(mp.NIP) KASIR,
			 master.getNamaLengkapPegawai(mpdok.NIP) PETUGASMEDIS,
			 INSERT(INSERT(INSERT(LPAD(ps.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM,
			 master.getNamaLengkap(ps.NORM) NAMAPASIEN,kjgn.NOPEN,crbyr.DESKRIPSI CARABAYAR, DATE_FORMAT(p.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG,
			 SUM(mtt.DOKTER_OPERATOR) DOKTER_OPERATOR, tm.KUNJUNGAN,
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 	(SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
			 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
			 LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
	       LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	  		 LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
	  	  , pembayaran.pembayaran_tagihan pt
	  		, pembayaran.transaksi_kasir tk
	  		  LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		     LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	 WHERE rt.JENIS = 3 AND rt.TAGIHAN=pt.TAGIHAN AND tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS=1
	  AND tk.`STATUS`=2 AND tk.NOMOR IN (',PNOMOR,') 
	  AND tk.KASIR=',PKASIR ,'
	GROUP BY ptm.MEDIS, kjgn.RUANGAN, p.NOMOR, tm.TINDAKAN');

   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
