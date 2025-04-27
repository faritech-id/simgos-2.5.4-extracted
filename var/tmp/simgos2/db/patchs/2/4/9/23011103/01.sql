USE `layanan`;
-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure layanan.CetakEtiket
DROP PROCEDURE IF EXISTS `CetakEtiket`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakEtiket`(IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT lf.TANGGAL, lf.ID NOMOR, lf.KUNJUNGAN, r.DESKRIPSI ASALPENGIRIM, cr.DESKRIPSI CARABAYAR
			 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
			 , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR, master.getCariUmur(pk.MASUK,ps.TANGGAL_LAHIR) UMUR
			 , jp.DESKRIPSI JENISPENGGUNAAN, ib.NAMA NAMAOBAT, '' NAMAOBATRACIKAN
			 , lf.JUMLAH, master.getAturanPakai2(lf.FREKUENSI,lf.DOSIS,lf.RUTE_PEMBERIAN) ATURANPAKAI
			 , lf.KETERANGAN, '0' RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
			 , ib.MASA_BERLAKU, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
			 , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER
			 , 0 TAMPILKAN_APOTEKER, 0 TAMPILKAN_SIPA_APOTEKER
	  FROM layanan.farmasi lf
			 LEFT JOIN master.referensi ref ON ref.ID = lf.ATURAN_PAKAI AND ref.JENIS = 41
			 , pendaftaran.kunjungan pk
		    LEFT JOIN layanan.order_resep o ON o.NOMOR = pk.REF
		    LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN = asal.NOMOR
			 LEFT JOIN master.ruangan r ON asal.RUANGAN = r.ID AND r.JENIS = 5
		    LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
		    , pendaftaran.pendaftaran pp
			 LEFT JOIN master.pasien ps ON pp.NORM = ps.NORM
			 LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR = pj.NOPEN
			 LEFT JOIN master.referensi cr ON pj.JENIS = cr.ID AND cr.JENIS = 10
			 , inventory.barang ib
			 LEFT JOIN master.referensi jp ON ib.JENIS_PENGGUNAAN_OBAT = jp.ID AND jp.JENIS = 55
			 , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK = mp.ID
			 ) inst
			 , (SELECT ap.NAMA, ap.SIPA
					FROM master.apoteker ap
					WHERE ap.`STATUS` = 1
			 ) apoteker
	 WHERE lf.`STATUS` = 2 
	   AND lf.KUNJUNGAN = pk.NOMOR 
		AND pk.`STATUS` IN (1,2)
	   AND pk.NOPEN = pp.NOMOR 
		AND lf.FARMASI = ib.ID
		AND lf.KUNJUNGAN = PKUNJUNGAN 
		AND lf.RACIKAN = 0
		AND ib.KATEGORI LIKE '101%'
	 UNION 
	SELECT lf.TANGGAL, lf.ID NOMOR, lf.KUNJUNGAN, r.DESKRIPSI ASALPENGIRIM, cr.DESKRIPSI CARABAYAR
			 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
			 , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR, master.getCariUmur(pk.MASUK,ps.TANGGAL_LAHIR) UMUR
			 , jp.DESKRIPSI JENISPENGGUNAAN
			 , CONCAT('RACIKAN - ',lf.GROUP_RACIKAN) NAMAOBAT
			 , REPLACE(CONCAT('<p>RACIKAN - ',lf.GROUP_RACIKAN,'</p>',GROUP_CONCAT(CONCAT('<br><div>',ib.NAMA,'</div></br>'))),'</p>,<p>','</p><p>') NAMAOBATRACIKAN
			 , '' JUMLAH, master.getAturanPakai2(lf.FREKUENSI,lf.DOSIS,lf.RUTE_PEMBERIAN) ATURANPAKAI
			 , lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
			 , null MASA_BERLAKU, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
			 , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER
			 , 0 TAMPILKAN_APOTEKER, 0 TAMPILKAN_SIPA_APOTEKER
	  FROM layanan.farmasi lf
		    LEFT JOIN master.referensi ref ON ref.ID = lf.ATURAN_PAKAI AND ref.JENIS = 41
		    , pendaftaran.kunjungan pk
	       LEFT JOIN layanan.order_resep o ON o.NOMOR = pk.REF
	       LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN = asal.NOMOR
		    LEFT JOIN master.ruangan r ON asal.RUANGAN = r.ID AND r.JENIS = 5
	       LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
	       , pendaftaran.pendaftaran pp
		    LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		    LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
		    , inventory.barang ib
		    LEFT JOIN master.referensi jp ON ib.JENIS_PENGGUNAAN_OBAT=jp.ID AND jp.JENIS=55
		    , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
				   FROM aplikasi.instansi ai
					     , master.ppk mp
				  WHERE ai.PPK=mp.ID
			 ) inst
		    , (SELECT ap.NAMA, ap.SIPA
				   FROM master.apoteker ap
				  WHERE ap.`STATUS` = 1
			 ) apoteker
 	 WHERE lf.`STATUS` = 2 
	   AND lf.KUNJUNGAN = pk.NOMOR 
		AND pk.`STATUS` IN (1,2)
		AND pk.NOPEN = pp.NOMOR 
		AND lf.FARMASI = ib.ID
		AND lf.KUNJUNGAN = PKUNJUNGAN 
		AND lf.RACIKAN = 1
		AND ib.KATEGORI LIKE '101%'
	 GROUP BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;