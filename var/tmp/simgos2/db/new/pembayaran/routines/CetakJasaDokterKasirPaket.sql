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

-- membuang struktur untuk procedure pembayaran.CetakJasaDokterKasirPaket
DROP PROCEDURE IF EXISTS `CetakJasaDokterKasirPaket`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakJasaDokterKasirPaket`(IN `PNOMOR` VARCHAR(50), IN `PKASIR` SMALLINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`,
			 dtp.DOKTER_OPERATOR, dtp.DOKTER_ANASTESI, dtp.DOKTER_LAINNYA,
			 INSERT(INSERT(INSERT(LPAD(ps.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM,
			 master.getNamaLengkap(ps.NORM) NAMAPASIEN, p.TANGGAL TGLREG, master.getNamaLengkapPegawai(mp.NIP) KASIR,
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 	(SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
			 (SELECT GROUP_CONCAT(DISTINCT(master.getNamaLengkapPegawai(mpdok.NIP)),''\r'') 
					FROM pendaftaran.kunjungan pk
						, layanan.tindakan_medis tm
						, layanan.petugas_tindakan_medis ptm
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
						, pembayaran.pembayaran_tagihan pt
						, pembayaran.tagihan_pendaftaran ptp
				   	, pembayaran.rincian_tagihan_paket rtp
						, master.paket_detil pdt
					WHERE pt.TAGIHAN=rt.TAGIHAN AND pk.NOMOR=tm.KUNJUNGAN AND tm.`STATUS` IN (1,2)
						AND tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0 AND pt.`STATUS` IN (1,2)
						AND pt.TAGIHAN=ptp.TAGIHAN AND pk.NOPEN=ptp.PENDAFTARAN
						AND pt.TAGIHAN=rtp.TAGIHAN AND rtp.PAKET_DETIL=pdt.ID AND tm.TINDAKAN=pdt.ITEM) DOKTER
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID
	  		 LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			, pembayaran.pembayaran_tagihan pt
	  		, pembayaran.transaksi_kasir tk
	  		  LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		     LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	 WHERE rt.JENIS = 5 AND rt.TAGIHAN=pt.TAGIHAN AND tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS=1
	  AND tk.`STATUS`=2 AND tk.NOMOR IN (',PNOMOR,') 
	  AND tk.KASIR=',PKASIR ,'
	  ');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
