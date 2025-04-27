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

-- membuang struktur untuk function pembayaran.getSkripRincianTagihanPaket
DROP FUNCTION IF EXISTS `getSkripRincianTagihanPaket`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getSkripRincianTagihanPaket`(
	`PTAGIHAN` CHAR(10)
) RETURNS varchar(10000) CHARSET latin1
    DETERMINISTIC
BEGIN
	RETURN CONCAT('/* Administrasi */
	SELECT RAND() QID, rtp.TAGIHAN, rtp.REF_ID, mp.NAMA NAMAPAKET,
		CONCAT(r.DESKRIPSI,
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
				 ) RUANGAN,
				 rf.DESKRIPSI LAYANAN,
				 mpd.JENIS JENIS, rf.DESKRIPSI JENIS_RINCIAN,
				 ''''  TARIF_ID,
				 IF(mpd.JENIS=1, p.TANGGAL, NULL) TANGGAL, 
				 1 JUMLAH,  '''' TARIF, rtp.`STATUS`
		FROM pembayaran.rincian_tagihan_paket rtp
	     /* Kartu */
	  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rtp.REF_ID	
	  		 
	  		 /* Karcis RJ or RI */
			 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rtp.REF_ID 
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  	, master.paket_detil mpd
		  LEFT JOIN master.referensi rf ON mpd.JENIS=rf.ID AND rf.JENIS=37
		  LEFT JOIN master.paket mp ON mpd.PAKET=mp.ID
	WHERE rtp.TAGIHAN=''',PTAGIHAN,''' AND  rtp.PAKET_DETIL=mpd.ID AND mpd.JENIS=3 AND rtp.STATUS = 1
	UNION
	/* Akomdosi */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, pkt.NAMA NAMAPAKET,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			 4 JENIS, IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''') JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 5 AND rt.STATUS = 1
	UNION
	/* Tindakan */
	SELECT RAND() QID, rtp.TAGIHAN, rtp.REF_ID, mp.NAMA NAMAPAKET,
		CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 mpd.JENIS JENIS, rf.DESKRIPSI JENIS_RINCIAN,
			 ''''  TARIF_ID,
			 IF(mpd.JENIS=1, tm.TANGGAL, NULL) TANGGAL, 
			 1 JUMLAH,  '''' TARIF, rtp.`STATUS`
	FROM pembayaran.rincian_tagihan_paket rtp
	     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rtp.REF_ID
  		  LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
  		  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
  		  LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
  		  LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
  		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
  		  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
  		  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
  		, master.paket_detil mpd
		  LEFT JOIN master.referensi rf ON mpd.JENIS=rf.ID AND rf.JENIS=37
		  LEFT JOIN master.paket mp ON mpd.PAKET=mp.ID
	WHERE rtp.TAGIHAN=''',PTAGIHAN,''' AND  rtp.PAKET_DETIL=mpd.ID AND mpd.JENIS=1 AND rtp.STATUS = 1
	UNION
	/* Farmasi */
	SELECT RAND() QID, rtp.TAGIHAN, rtp.REF_ID, mp.NAMA NAMAPAKET,
		CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 mpd.JENIS JENIS, rf.DESKRIPSI JENIS_RINCIAN,
			 ''''  TARIF_ID,
			 IF(mpd.JENIS=1, f.TANGGAL, NULL) TANGGAL, 
			 f.JUMLAH JUMLAH,  '''' TARIF, rtp.`STATUS`
	FROM pembayaran.rincian_tagihan_paket rtp
	     LEFT JOIN layanan.farmasi f ON f.ID = rtp.REF_ID AND f.`STATUS` !=0
	  	  LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  	  LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
	  	  LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  	  LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  	  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  	, master.paket_detil mpd
		  LEFT JOIN master.referensi rf ON mpd.JENIS=rf.ID AND rf.JENIS=37
		  LEFT JOIN master.paket mp ON mpd.PAKET=mp.ID
	WHERE rtp.TAGIHAN=''',PTAGIHAN,''' AND  rtp.PAKET_DETIL=mpd.ID AND mpd.JENIS=2 AND rtp.STATUS = 1');
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
