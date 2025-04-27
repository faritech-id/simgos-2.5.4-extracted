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

-- membuang struktur untuk procedure medicalrecord.ListInstrumen
DROP PROCEDURE IF EXISTS `ListInstrumen`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `ListInstrumen`(
	IN `PKUNJUNGAN` VARCHAR(19)










)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, if(rjk.DESKRIPSI='Perempuan','P','L') JENISKELAMIN
		, p.RT
		, p.RW
		, IF((SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM)='',p.ALAMAT,CONCAT(p.ALAMAT,' - (',(SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM),')')) ALAMAT
		, pp.NORM, pk.NOMOR
		, DATE_FORMAT(pk.MASUK,'%d-%m-%Y') TGLMASUK
		, DATE_FORMAT(pk.MASUK,'%H:%i:%s') JAMMASUK
		, r.DESKRIPSI KMROP
		, CONCAT(rr.DESKRIPSI,' / ',rk.KAMAR,' / ',kelas.DESKRIPSI) RRAWAT
		, master.getNamaLengkapPegawai(dok.NIP) DPJP
		FROM pendaftaran.kunjungan pk
		LEFT JOIN pendaftaran.konsul ks on pk.REF=ks.NOMOR AND ks.`STATUS`!=0
		LEFT JOIN pendaftaran.kunjungan ri on ks.KUNJUNGAN=ri.NOMOR AND ri.`STATUS`!=0
		LEFT JOIN layanan.tindakan_medis tm on pk.NOMOR=tm.KUNJUNGAN
		LEFT JOIN layanan.petugas_tindakan_medis ptm on tm.ID=ptm.TINDAKAN_MEDIS
		LEFT JOIN master.dokter dok on ptm.MEDIS=dok.ID
 		LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
      LEFT JOIN master.ruangan rr ON ri.RUANGAN=rr.ID AND rr.JENIS=5
  		LEFT JOIN master.ruang_kamar_tidur rkt ON ri.RUANG_KAMAR_TIDUR=rkt.ID
   	LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
	   LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		, pendaftaran.pendaftaran pp
		, master.pasien p
	   LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
	   LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
	   LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
	   LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
	   LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
	   LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		, (SELECT mp.NAMA, ai.PPK 
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pk.`STATUS`!=0 AND pp.`STATUS`!=0 AND pp.NORM=p.NORM AND pk.NOMOR=PKUNJUNGAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
