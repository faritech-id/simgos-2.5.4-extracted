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
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakOrderDetilResep
DROP PROCEDURE IF EXISTS `CetakOrderDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderDetilResep`(
	IN `PNOMOR` CHAR(21)
)
BEGIN
	SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU
			 , mp.NIP, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER
			 , o.BERAT_BADAN, o.TINGGI_BADAN
			 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
			 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
			 , r.DESKRIPSI ASALPENGIRIM, ib.NAMA NAMAOBAT, od.JUMLAH
		 	 , IF(lf.ID IS NULL
			  		,master.getAturanPakai2(od.FREKUENSI, od.DOSIS, od.RUTE_PEMBERIAN)
			  			,master.getAturanPakai2(lf.FREKUENSI, lf.DOSIS, lf.RUTE_PEMBERIAN)
					) ATURANPAKAI
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
