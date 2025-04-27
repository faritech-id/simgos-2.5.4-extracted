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

-- membuang struktur untuk procedure pembayaran.CetakRincianKegiatanPasien
DROP PROCEDURE IF EXISTS `CetakRincianKegiatanPasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakRincianKegiatanPasien`(IN `PTAGIHAN` CHAR(10), IN `PSTATUS` TINYINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT * FROM (
		SELECT 2 IDPAKET, ''LUAR PAKET'' PAKET, r.QID,r.TAGIHAN, r.REF_ID, r.RUANGAN, r.LAYANAN, r.JENIS, r.JENIS_RINCIAN, r.TANGGAL, r.JUMLAH, r.TARIF, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, pt.TANGGAL TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 w.DESKRIPSI WILAYAH,
			 (SELECT GROUP_CONCAT(master.getNamaLengkapPegawai(mpdok.NIP))
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN) PETUGASMEDIS
		  FROM (', pembayaran.getSkripRincianTagihan(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS = 1
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		WHERE r.STATUS = ', PSTATUS, ' AND r.JENIS !=5
		  AND ppk.ID = i.PPK 
		  AND w.ID = ppk.WILAYAH
		UNION
		SELECT 1 IDPAKET, ''PAKET'' PAKET, RAND() QID, rt.TAGIHAN, rt.REF_ID, rt.RUANGAN, rt.LAYANAN, rt.JENIS, rt.JENIS_RINCIAN, rt.TANGGAL, rt.JUMLAH,rt.TARIF, 
	       INSERT(INSERT(INSERT(LPAD(tg.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, tg.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(tg.ID) JENISKUNJUNGAN, DATE_FORMAT(pt.TANGGAL,''%d-%m-%Y'') TANGGALBAYAR, tg.TANGGAL TANGGALTAGIHAN,
			 w.DESKRIPSI WILAYAH,
			 (SELECT GROUP_CONCAT(master.getNamaLengkapPegawai(mpdok.NIP))
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan_paket rtp
					     , master.paket_detil mpd
					WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0
						AND ptm.TINDAKAN_MEDIS=rtp.REF_ID  AND rtp.PAKET_DETIL=mpd.ID AND mpd.JENIS=1 AND rtp.TAGIHAN=rt.TAGIHAN) PETUGASMEDIS
	FROM (', pembayaran.getSkripRincianTagihanPaket(PTAGIHAN),'
		)  rt 
	     LEFT JOIN pembayaran.tagihan tg ON rt.TAGIHAN=tg.ID AND tg.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = tg.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = tg.ID AND pt.JENIS = 1 AND pt.STATUS = 1
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON tg.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
	WHERE rt.STATUS = ', PSTATUS, ' AND rt.JENIS !=5
		  AND ppk.ID = i.PPK 
		  AND w.ID = ppk.WILAYAH
	  ) a ORDER BY IDPAKET ASC, RUANGAN DESC
		');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
