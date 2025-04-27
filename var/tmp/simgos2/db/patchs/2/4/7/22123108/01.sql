-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6557
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakLapOperasi
DROP PROCEDURE IF EXISTS `CetakLapOperasi`;
DELIMITER //
CREATE PROCEDURE `CetakLapOperasi`(
	IN `PID` INT
)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI,LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
			, master.getNamaLengkapPegawai(mpdok.NIP) DOKTEROPERATOR, mpdok.NIP
			, master.getNamaLengkapPegawai(mpanas.NIP) DOKTERANASTESI
			, ja.DESKRIPSI JENISANASTESI, gol.DESKRIPSI GOLONGANOPERASI, jop.DESKRIPSI JENISOPERASI
			, IF(op.PA=1,'Ya','Tidak') PEMERIKSAANPA
			, DATE_FORMAT(op.TANGGAL,'%d-%m-%Y') TGLOPERASI
			, CONCAT('Bagian/SMF : ',r.DESKRIPSI,' / ',smf.DESKRIPSI) SMF
			, DATE_FORMAT(op.DIBUAT_TANGGAL,'%d-%m-%Y') DBUATTANGGAL
			, pk.NOPEN, pk.MASUK TGLREG,  r.DESKRIPSI UNITPENGANTAR
			, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=3 AND jbr.ID=4) KODEMR1
			, op.*, rt.DESKRIPSI JNSTRANSFUSI
		FROM medicalrecord.operasi op
			  LEFT JOIN master.dokter dok ON op.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
			  LEFT JOIN master.dokter_smf dsmf ON dok.ID=dsmf.DOKTER
			  LEFT JOIN master.referensi smf ON dsmf.SMF=smf.ID AND smf.JENIS=26
			  LEFT JOIN master.dokter anas ON op.ANASTESI=anas.ID
			  LEFT JOIN master.pegawai mpanas ON anas.NIP=mpanas.NIP
			  LEFT JOIN master.referensi ja ON op.JENIS_ANASTESI=ja.ID AND ja.JENIS=52
			  LEFT JOIN master.referensi gol ON op.GOLONGAN_OPERASI=gol.ID AND gol.JENIS=53
			  LEFT JOIN master.referensi jop ON op.JENIS_OPERASI=jop.ID AND jop.JENIS=87
			  LEFT JOIN master.referensi rt ON op.JENIS_TRANSFUSI=rt.ID AND rt.JENIS=213
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN pendaftaran.konsul ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan rasal ON kj.RUANGAN=rasal.ID AND rasal.JENIS=5
			  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT mp.NAMA, ai.PPK  
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND op.KUNJUNGAN=pk.NOMOR AND op.`STATUS`=1
		AND op.ID=PID;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
