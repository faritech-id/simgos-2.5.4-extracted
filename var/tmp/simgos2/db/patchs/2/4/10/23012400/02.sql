-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakSetoranKasir
DROP PROCEDURE IF EXISTS `CetakSetoranKasir`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasir`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
			 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
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
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.TOTAL > 0
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR = ',PKASIR ,'
      ORDER BY rf.ID, JENISKUNJUNGAN, DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
