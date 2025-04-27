-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for layanan
USE `layanan`;

-- Dumping structure for procedure layanan.CetakOrderDetilResep1
DROP PROCEDURE IF EXISTS `CetakOrderDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderDetilResep`(
	IN `PNOMOR` CHAR(21)
)
BEGIN
	
	SET @gp=0;
	SET @r='';
	SELECT *
			, IF(@r!=RACIKAN,'R/','') R
			 , @r:=RACIKAN R2
		FROM (
				SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU
						 , mp.NIP, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER
						 , o.BERAT_BADAN, o.TINGGI_BADAN
						 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
						 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
						 , r.DESKRIPSI ASALPENGIRIM, ib.NAMA NAMAOBAT
						 , IF(od.RACIKAN=1,od.DOSIS, CONCAT (' Jumlah ',ROUND(od.JUMLAH))) JUMLAH
						 , od.RACIKAN JNS_RACIKAN
					 	 , IF(lf.ID IS NULL
						  		,CONCAT(master.getAturanPakaiDenganFrekuensiDanRute(od.DOSIS, od.FREKUENSI, od.RUTE_PEMBERIAN), ' [ ',od.KETERANGAN , ' ]')
						  		,CONCAT(master.getAturanPakaiDenganFrekuensiDanRute(od.DOSIS, od.FREKUENSI, od.RUTE_PEMBERIAN), ' [ ',od.KETERANGAN , ' ]')
								) ATURANPAKAI
							# $F{KETERANGAN}=="" ? $F{ATURANPAKAI} : $F{ATURANPAKAI} + " ["+$F{KETERANGAN}+"]"	
					
						 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
						 , ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM, lf.RACIKAN RACIKAN1
						 , CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP
						 , od.KETERANGAN
						 , CONCAT(od.RACIKAN,IF(od.RACIKAN=0,@gp:=@gp+1,od.GROUP_RACIKAN)) RACIKAN
						 , IFNULL(CONCAT (`master`.getAturanPakaiDenganFrekuensiDanRute('', od.FREKUENSI, od.RUTE_PEMBERIAN), ' [ ', od.JUMLAH_RACIKAN,' ',f.DESKRIPSI, ' ]'),'') PETUNJUK_RACIKAN
						 , kap.NOMOR NOKARTU
						 , lf.`STATUS` STATUSLAYANAN, pp.NOMOR NOPEN, pj.NOMOR SEP, `master`.getAlamatPasien(pp.NORM) ALAMATLKP
						 , `master`.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, kp.NOMOR NOTLP, IFNULL(wl.DESKRIPSI,ps.TEMPAT_LAHIR) TEMPAT_LAHIR
				  FROM layanan.order_resep o
						 LEFT JOIN master.dokter md ON o.DOKTER_DPJP = md.ID
						 LEFT JOIN master.pegawai mp ON md.NIP = mp.NIP
						 , pendaftaran.kunjungan pk
					    LEFT JOIN master.ruangan r ON pk.RUANGAN = r.ID AND r.JENIS = 5
					    LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
						 , layanan.order_detil_resep od
						 LEFT JOIN master.referensi ref ON ref.ID = od.ATURAN_PAKAI AND ref.JENIS = 41
					    LEFT JOIN layanan.farmasi lf ON od.REF = lf.ID
					    LEFT JOIN `master`.referensi f ON od.PETUNJUK_RACIKAN=f.ID AND f.JENIS=84
						 , inventory.barang ib
						 , pendaftaran.pendaftaran pp
						 LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						 LEFT JOIN master.pasien ps ON pp.NORM = ps.NORM
						 LEFT JOIN `master`.kontak_pasien kp ON ps.NORM=kp.NORM AND kp.JENIS=3
						 LEFT JOIN `master`.kartu_asuransi_pasien kap ON kap.NORM = ps.NORM AND kap.JENIS = 2
						 LEFT JOIN `master`.wilayah wl ON ps.TEMPAT_LAHIR=wl.ID
						 , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
							   FROM aplikasi.instansi ai
								     , master.ppk mp
							  WHERE ai.PPK = mp.ID) inst
				 WHERE o.NOMOR=od.ORDER_ID AND o.`STATUS` IN (1,2)
					AND od.FARMASI = ib.ID AND o.KUNJUNGAN = pk.NOMOR AND pk.`STATUS` IN (1,2)
					AND pk.NOPEN = pp.NOMOR
					AND o.NOMOR = PNOMOR
				 ORDER BY od.RACIKAN DESC, od.GROUP_RACIKAN
	 ) ab;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
