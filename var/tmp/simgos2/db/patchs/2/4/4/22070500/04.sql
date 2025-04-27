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


-- Membuang struktur basisdata untuk medicalrecord
CREATE DATABASE IF NOT EXISTS `medicalrecord`;
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakSuratSakit
DROP PROCEDURE IF EXISTS `CetakSuratSakit`;
DELIMITER //
CREATE PROCEDURE `CetakSuratSakit`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, rjk.DESKRIPSI AS  JENISKELAMIN
		, p.RT
		, p.RW
		, p.ALAMAT
		, pp.NORM, pk.NOMOR
		, DATE_FORMAT(pk.MASUK,'%d-%m-%Y') TGLMASUK
		, DATE_FORMAT(pk.MASUK,'%H:%i:%s') JAMMASUK
		, r.DESKRIPSI KMROP
		, CONCAT(rr.DESKRIPSI,' / ',rk.KAMAR,' / ',kelas.DESKRIPSI) RRAWAT
		, master.getNamaLengkapPegawai(dok.NIP) DPJP
		, skt.NOMOR AS NOMORSURAT
		, DATE_FORMAT(skt.TANGGAL,'%d-%m-%Y') AS TANGGAL_AKHIR
		, DATE_FORMAT(skt.DIBUAT_TANGGAL,'%d-%m-%Y') AS DIBUAT_TANGGAL
		, skt.DESKRIPSI AS KETERANGAN
		, wlyh.DESKRIPSI AS DESA
		, wly.DESKRIPSI AS KECAMATAN
		, DATEDIFF(skt.TANGGAL,skt.DIBUAT_TANGGAL) AS JMLHARI
		, rpk.DESKRIPSI AS PEKERJAAN
		FROM pendaftaran.kunjungan pk
		LEFT JOIN pendaftaran.konsul ks on pk.REF=ks.NOMOR AND ks.`STATUS`!=0
		LEFT JOIN pendaftaran.kunjungan ri on ks.KUNJUNGAN=ri.NOMOR AND ri.`STATUS`!=0
		LEFT JOIN layanan.tindakan_medis tm on pk.NOMOR=tm.KUNJUNGAN
		LEFT JOIN master.dokter dok on pk.DPJP=dok.ID
 		LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
      LEFT JOIN master.ruangan rr ON ri.RUANGAN=rr.ID AND rr.JENIS=5
  		LEFT JOIN master.ruang_kamar_tidur rkt ON ri.RUANG_KAMAR_TIDUR=rkt.ID
   	LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	   LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
	   LEFT JOIN medicalrecord.surat_sakit skt ON skt.KUNJUNGAN=pk.NOMOR
		, pendaftaran.pendaftaran pp
		LEFT JOIN master.pasien ps ON ps.NORM=pp.NORM
		LEFT JOIN master.wilayah wly ON wly.ID=LEFT(ps.WILAYAH,6)
		, master.pasien p
	   LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
	   LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
	   LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
	   LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
	   LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
	   LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
	   LEFT JOIN master.wilayah wlyh ON wlyh.ID=p.WILAYAH
		, (SELECT mp.NAMA, ai.PPK 
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pk.`STATUS`!=0 AND pp.`STATUS`!=0 AND pp.NORM=p.NORM AND pk.NOMOR=PKUNJUNGAN;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
