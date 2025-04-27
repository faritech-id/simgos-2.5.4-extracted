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

-- membuang struktur untuk function pembayaran.getSkripRincianTagihan
DROP FUNCTION IF EXISTS `getSkripRincianTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getSkripRincianTagihan`(
	`PTAGIHAN` CHAR(10)
) RETURNS varchar(10000) CHARSET latin1
    DETERMINISTIC
BEGIN
	RETURN CONCAT('/* Administrasi */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 @RUANGAN := CONCAT(
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(r.DESKRIPSI,'' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), 
					IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
			 ) RUANGAN,
			 adm.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 1, 
			 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR), 
				 NULL) TANGGAL,
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, 
			 @JENIS_KUNJUNGAN := IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  	    /* Karcis RJ or RI */
			 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN
	  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
	  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	  		 
	  		 /* Pelayanan Farmasi */
			 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
	  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 1 AND rt.STATUS = 1
		AND NOT adm.ID = 1
	UNION
	/* Kartu */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 @RUANGAN,
			 adm.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 krtp.TANGGAL,
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, 
			 @JENIS_KUNJUNGAN JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	
	  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
	  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 1 AND rt.STATUS = 1
	   AND adm.ID = 1
	UNION
	/* Paket */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
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
	/* Akomodasi */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')'', IF(kjgn.TITIPAN = 1, CONCAT('' Pasien Titipan '', kls1.DESKRIPSI), '''')), '''')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')'', IF(kjgn.TITIPAN = 1, CONCAT('' Pasien Titipan '', kls1.DESKRIPSI), '''')), '''') LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, 
			 rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF, 
			 rt.`STATUS`, 
			 r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	  		 LEFT JOIN `master`.referensi kls1 ON kls1.JENIS = 19 AND kls1.ID = kjgn.TITIPAN_KELAS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 2 AND rt.STATUS = 1
	UNION
	/* Tindakan */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 3 AND rt.STATUS = 1
	UNION
	/* Farmasi */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 4 AND rt.STATUS = 1
	UNION
	/* O2 */
	SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 ref.DESKRIPSI LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS =  6, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = ''',PTAGIHAN,'''
	   AND rt.JENIS = 6 AND rt.STATUS = 1');
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
