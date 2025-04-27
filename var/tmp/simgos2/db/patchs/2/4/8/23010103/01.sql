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

-- Dumping structure for procedure layanan.CetakOrderDetilResep
DROP PROCEDURE IF EXISTS `CetakOrderDetilResep`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakOrderDetilResep`(IN `PNOMOR` CHAR(21)
)
BEGIN
	SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
			 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
			 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
			 , r.DESKRIPSI ASALPENGIRIM, ib.NAMA NAMAOBAT, od.JUMLAH
		 	 #, master.getAturanPakai2(lf.ATURAN_PAKAI) ATURANPAKAI
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;