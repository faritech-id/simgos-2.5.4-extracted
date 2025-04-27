-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
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


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakMR1C
DROP PROCEDURE IF EXISTS `CetakMR1C`;
DELIMITER //
CREATE PROCEDURE `CetakMR1C`(
	IN `PNORM` INT(11)
)
BEGIN 	
	SELECT *
		FROM (SELECT PNORM ID, mp.NAMA NAMAINSTANSI, ai.PPK, CONCAT(mp.ALAMAT,', Kode Pos ', IFNULL(mp.KODEPOS,' '),', Telp. ', IFNULL(mp.TELEPON,' '),', Fax. ',IF(mp.FAX IS NULL OR mp.FAX='','',mp.FAX)) ALAMATINSTANSI, IFNULL(w.DESKRIPSI, mp.DESWILAYAH) KOTA, DATE_FORMAT(SYSDATE(),'%d') TGL, `master`.getBulanIndo(SYSDATE()) BULAN, DATE_FORMAT(SYSDATE(),'%Y') TAHUN
						FROM aplikasi.instansi ai
							, master.ppk mp
							  LEFT JOIN master.wilayah w ON mp.WILAYAH=w.ID AND w.JENIS=2
						WHERE ai.PPK=mp.ID) inst
				LEFT JOIN ( SELECT p.NORM, `master`.getFormatNorm(p.NORM, '-') FORMAT_NORM , `master`.getNamaLengkap(p.NORM) NAMA
							 		, IF(p.JENIS_KELAMIN=1,1,0) LAKI, IF(p.JENIS_KELAMIN=2,1,0) PEREMPUAN
									, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
							 		, IF(p.AGAMA=1,1,0) ISLAM, IF(p.AGAMA=2,1,0) KRISTEN, IF(p.AGAMA=3,1,0) KATOLIK, IF(p.AGAMA=4,1,0) HINDU, IF(p.AGAMA=5,1,0) BUDHA, IF(p.AGAMA IN (6,7),1,0) AGAMALAIN 
									, p.ALAMAT, kip.ALAMAT ALAMATKTP, kip.RT, kip.RW, IFNULL(kip.KODEPOS,'') KODEPOS, kip.WILAYAH
							 		, IF(p.SUKU=0,'',sk.DESKRIPSI) SUKU
									, IF(p.STATUS_PERKAWINAN=1,1,0) BELUMKAWIN, IF(p.STATUS_PERKAWINAN=2,1,0) KAWIN, IF(p.STATUS_PERKAWINAN IN (3,4) AND p.JENIS_KELAMIN=2,1,0) JANDA , IF(p.STATUS_PERKAWINAN IN (3,4) AND p.JENIS_KELAMIN=1,1,0) DUDA
									, IF(p.PENDIDIKAN=1,0,0) TDKSEKOLAH, IF(p.PENDIDIKAN=1,0,0) BELUMSEKOLAH, IF(p.PENDIDIKAN=1,0,0) TK, IF(p.PENDIDIKAN IN (2,3),0,0) SD
									, IF(p.PENDIDIKAN=4,1,0) SLTP, IF(p.PENDIDIKAN=5,1,0) SLTA, IF(p.PENDIDIKAN IN (6,7),1,0) AKADEMI, IF(p.PENDIDIKAN=8,1,0) S1
									, IF(p.PENDIDIKAN=9,1,0) S2, IF(p.PENDIDIKAN=10,1,0) S3
									, IF(p.PEKERJAAN=3,1,0) PELAJAR, IF(p.PEKERJAAN=4,1,0) PENSIUNAN, IF(p.PEKERJAAN=5,1,0) PNS, IF(p.PEKERJAAN=1,1,0) TIDAKBEKERJA
									, IF(p.PEKERJAAN=2,1,0) IRT, IF(p.PEKERJAAN IN (6,7),1,0) TNI, IF(p.PEKERJAAN=88,1,0) WIRASWASTA, 0 PEGAWAISWASTA, 0 PROFESIONAL, 0 PEKERJAANLAINNYA
									, IF(p.BAHASA=1,'',bhs.DESKRIPSI) BAHASA
									, kp.NOMOR NOTELP
									, IFNULL(`master`.getWilayah(p.WILAYAH, 1),'') PROPINSI
									, IFNULL(`master`.getWilayah(p.WILAYAH, 2),'') KABUPATEN
									, IFNULL(`master`.getWilayah(p.WILAYAH, 3),'') KECAMATAN
									, IFNULL(`master`.getWilayah(p.WILAYAH, 4),'') KELURAHAN
								FROM master.pasien p
									  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
									  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
									  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
									  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
									  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
									  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
									  LEFT JOIN master.referensi sk ON p.SUKU=sk.ID AND sk.JENIS=140
									  LEFT JOIN master.referensi bhs ON p.BAHASA=bhs.ID AND bhs.JENIS=177
									  LEFT JOIN master.kontak_pasien kp ON p.NORM=kp.NORM AND kp.JENIS=3
									  LEFT JOIN master.kartu_identitas_pasien kip ON p.NORM=kip.NORM AND kip.JENIS=1
									  LEFT JOIN master.keluarga_pasien ayah ON p.NORM=ayah.NORM AND ayah.JENIS_KELAMIN=1 AND ayah.SHDK=7
									  LEFT JOIN master.referensi rpkayah ON ayah.PEKERJAAN=rpkayah.ID AND rpkayah.JENIS=4 AND ayah.SHDK=7
									  LEFT JOIN master.keluarga_pasien ibu ON p.NORM=ibu.NORM AND ibu.JENIS_KELAMIN=2 AND ibu.SHDK=7
									  LEFT JOIN master.referensi rpkibu ON ibu.PEKERJAAN=rpkibu.ID AND rpkibu.JENIS=4 AND ibu.SHDK=7
									  LEFT JOIN master.keluarga_pasien si ON p.NORM=si.NORM AND si.SHDK IN (2,3)
									  LEFT JOIN master.referensi rpksi ON si.PEKERJAAN=rpksi.ID AND rpksi.JENIS=4 AND si.SHDK IN (2,3)
								WHERE p.NORM=PNORM) ab ON ab.NORM=inst.ID;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
