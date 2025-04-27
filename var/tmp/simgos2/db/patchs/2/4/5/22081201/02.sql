-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
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


-- Membuang struktur basisdata untuk layanan
CREATE DATABASE IF NOT EXISTS `layanan`;
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakEtiket
DROP PROCEDURE IF EXISTS `CetakEtiket`;
DELIMITER //
CREATE PROCEDURE `CetakEtiket`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT lf.TANGGAL, lf.ID NOMOR, lf.KUNJUNGAN, r.DESKRIPSI ASALPENGIRIM, cr.DESKRIPSI CARABAYAR
			 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
			 , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR, master.getCariUmur(pk.MASUK,ps.TANGGAL_LAHIR) UMUR
			 , jp.DESKRIPSI JENISPENGGUNAAN, ib.NAMA NAMAOBAT
			 , lf.JUMLAH, master.getAturanPakai(lf.ATURAN_PAKAI) ATURANPAKAI
			 , lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
			 , ib.MASA_BERLAKU, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
			 , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER
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
			 , jp.DESKRIPSI JENISPENGGUNAAN, CONCAT('RACIKAN - ',lf.GROUP_RACIKAN) NAMAOBAT
			 , '' JUMLAH, master.getAturanPakai(lf.ATURAN_PAKAI) ATURANPAKAI
			 , lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
			 , null MASA_BERLAKU, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
			 , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER
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

-- membuang struktur untuk procedure layanan.CetakFakturDetilResep
DROP PROCEDURE IF EXISTS `CetakFakturDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakFakturDetilResep`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT inst.PPK, inst.NAMA INSTASI, lf.ID NOMOR, lf.KUNJUNGAN, DATE_FORMAT(lf.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(lf.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
			 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
			 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
			 , r.DESKRIPSI ASALPENGIRIM, master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
		 	 , ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
			 , CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP
			 , ib.NAMA NAMAOBAT, lf.JUMLAH, master.getAturanPakai(lf.ATURAN_PAKAI) ATURANPAKAI
			 , lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
			 , hb.HARGA_JUAL HARGA, ib.ID
	  FROM layanan.farmasi lf
			 LEFT JOIN master.referensi ref ON ref.ID = lf.ATURAN_PAKAI AND ref.JENIS = 41
			 , pendaftaran.kunjungan pk
		    LEFT JOIN layanan.order_resep o ON o.NOMOR = pk.REF
		    LEFT JOIN master.dokter md ON o.DOKTER_DPJP = md.ID
			 LEFT JOIN master.pegawai mp ON md.NIP = mp.NIP
			 LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN = asal.NOMOR
			 LEFT JOIN master.ruangan r ON asal.RUANGAN = r.ID AND r.JENIS = 5
		    LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
		    , pendaftaran.pendaftaran pp
			 LEFT JOIN master.pasien ps ON pp.NORM = ps.NORM
			 , inventory.barang ib
			 LEFT JOIN inventory.harga_barang hb ON hb.BARANG = ib.ID AND hb.`STATUS` = 1
			 , (SELECT mp.NAMA, ai.PPK
				   FROM aplikasi.instansi ai
					     , master.ppk mp
				  WHERE ai.PPK = mp.ID) inst
	 WHERE lf.`STATUS` = 2 AND lf.KUNJUNGAN = pk.NOMOR AND pk.`STATUS` IN (1,2)
		AND pk.NOPEN = pp.NOMOR AND lf.FARMASI = ib.ID
		AND lf.KUNJUNGAN=PKUNJUNGAN
	 ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;

-- membuang struktur untuk procedure layanan.CetakOrderDetilResep
DROP PROCEDURE IF EXISTS `CetakOrderDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderDetilResep`(
	IN `PNOMOR` CHAR(21)
)
BEGIN
	SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
			 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
			 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
			 , r.DESKRIPSI ASALPENGIRIM, ib.NAMA NAMAOBAT, od.JUMLAH
		 	 , master.getAturanPakai(lf.ATURAN_PAKAI) ATURANPAKAI
			 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
			 , ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
			 , CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP, od.KETERANGAN, CONCAT(od.RACIKAN,od.GROUP_RACIKAN) RACIKAN, od.PETUNJUK_RACIKAN
			 , lf.`STATUS` STATUSLAYANAN
	  FROM layanan.order_resep o
			 LEFT JOIN master.dokter md ON o.DOKTER_DPJP = md.ID
			 LEFT JOIN master.pegawai mp ON md.NIP = mp.NIP
			 , pendaftaran.kunjungan pk
		    LEFT JOIN master.ruangan r ON pk.RUANGAN = r.ID AND r.JENIS = 5
		    LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
			 , layanan.order_detil_resep od
			 LEFT JOIN master.referensi ref ON ref.ID = od.ATURAN_PAKAI AND ref.JENIS = 41
		    LEFT JOIN layanan.farmasi lf ON od.REF = lf.ID
			 , inventory.barang ib
			 , pendaftaran.pendaftaran pp
			 LEFT JOIN master.pasien ps ON pp.NORM = ps.NORM
			 , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
				   FROM aplikasi.instansi ai
					     , master.ppk mp
				  WHERE ai.PPK = mp.ID) inst
	 WHERE o.NOMOR=od.ORDER_ID AND o.`STATUS` IN (1,2)
		AND od.FARMASI = ib.ID AND o.KUNJUNGAN = pk.NOMOR AND pk.`STATUS` IN (1,2)
		AND pk.NOPEN = pp.NOMOR
		AND o.NOMOR = PNOMOR
	 ORDER BY od.RACIKAN, od.GROUP_RACIKAN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
