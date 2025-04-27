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

-- membuang struktur untuk procedure pembayaran.CetakSetoranKasirNonTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirNonTunai`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakSetoranKasirNonTunai`(IN `PNOMOR` VARCHAR(50), IN `PKASIR` SMALLINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalEDC(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
		 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
		 bk.DESKRIPSI BANK, kt.DESKRIPSI KARTUKREDIT, dc.NOMOR NOMORKARTU, dc.PEMILIK
	from pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	   , pembayaran.edc dc
	     LEFT JOIN master.referensi bk ON dc.BANK=bk.ID AND bk.JENIS=16
	     LEFT JOIN master.referensi kt ON dc.JENIS_KARTU=kt.ID AND kt.JENIS=17
	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS=1
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS`=2 AND pt.TAGIHAN=dc.TAGIHAN
	  AND tk.KASIR=',PKASIR ,' AND dc.STATUS IN (1,2)
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
