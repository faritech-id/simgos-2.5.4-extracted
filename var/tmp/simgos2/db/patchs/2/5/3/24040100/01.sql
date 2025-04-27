-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
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

-- membuang struktur untuk procedure pembayaran.CetakRincianPiutang
DROP PROCEDURE IF EXISTS `CetakRincianPiutang`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPiutang`(
	IN `PNORM` INT,
	IN `PTAGIHAN_PIUTANG` CHAR(10)
)
BEGIN
	SET @JMLPEMBAYARAN=0;
	
	SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST, w.DESKRIPSI KOTA
	  INTO @PPK, @NAMAINST, @ALAMATINST, @KOTA
     FROM aplikasi.instansi ai
	       , `master`.ppk p
	       , `master`.wilayah w
    WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID;
    
	SET @sqlText = CONCAT('
		SELECT *,
				@JMLPEMBAYARAN:=@JMLPEMBAYARAN + TOTALTAGIHAN JMLPEMBAYARAN
		FROM (
		SELECT RAND() idx, @PPK PPK, @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, @KOTA KOTA, master.getNamaLengkapPegawai(mp.NIP) KASIR,
			     p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, ps.NAMA NAMAPEMBAYAR,pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			     pt.JENIS, crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, pt.TOTAL TOTALTAGIHAN, p3.TAGIHAN_PIUTANG,
			     IF(''',PTAGIHAN_PIUTANG,'''=0,(SELECT SUM(bpp.TOTAL)
			           FROM pembayaran.piutang_pasien bpp,
			 	             pembayaran.tagihan t
			            WHERE t.ID = bpp.TAGIHAN
			              AND t.REF = p.NORM
				           AND bpp.`STATUS` = 1), pembayaran.getTotalPiutangPasien(p3.TAGIHAN_PIUTANG)) TOTAL_PIUTANG
	   FROM  pembayaran.pembayaran_tagihan pt
		      LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
		      LEFT JOIN pembayaran.pelunasan_piutang_pasien p3 ON p3.ID = tg.REF
		      LEFT JOIN pembayaran.tagihan tg2 ON tg2.ID = p3.TAGIHAN_PIUTANG
		      LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON ptp.TAGIHAN = tg2.ID AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
		      LEFT JOIN pembayaran.piutang_pasien ps ON ps.TAGIHAN=p3.TAGIHAN_PIUTANG AND ps.`STATUS`!=0
		      LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
		      LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		      LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		      LEFT JOIN master.pasien p ON pp.NORM=p.NORM
		      LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
		      LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		      LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		      LEFT JOIN aplikasi.pengguna us ON pt.OLEH=us.ID
			   LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
		WHERE  pt.`STATUS` = 2 AND pt.JENIS IN (4,5)  AND pt.TOTAL > 0
		  AND p.NORM=',PNORM,' 	
		 ',IF(PTAGIHAN_PIUTANG=0,'',CONCAT(' AND p3.TAGIHAN_PIUTANG=''',PTAGIHAN_PIUTANG,'''')),'
		ORDER BY DATE(pt.TANGGAL)
		) ab
	 ');

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
