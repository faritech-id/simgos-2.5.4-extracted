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

-- Dumping database structure for bpjs
USE `bpjs`;

-- Dumping structure for procedure bpjs.CetakSEP
DROP PROCEDURE IF EXISTS `CetakSEP`;
DELIMITER //
CREATE PROCEDURE `CetakSEP`(
	IN `PSEP` VARCHAR(20)
)
BEGIN
	SELECT inst.NAMA NAMAINSTANSI,k.noSEP NOMORSEP, DATE_FORMAT(k.tglSEP,'%d-%m-%Y') TGLSEP
		  , CONCAT(p.noKartu, '  ( MR. ',p.norm,' )') NOMORKARTU, p.norm NORM, pl.nama poliTujuan, k.klsRawat, mr.DESKRIPSI UNITPELAYANAN
		 , IF(k.jmlCetak > 0,CONCAT('*Cetakan Ke ',k.jmlCetak, ' ',DATE_FORMAT(k.tglSEP,'%d-%m-%Y %H:%i:%s')),'') CETAKAN , k.catatan CATATAN
		 , p.nmJenisPeserta PESERTA, p.nama NAMALENGKAP, CONCAT(DATE_FORMAT(p.tglLahir,'%d-%m-%Y'), '  Kelamin : ',IF(p.sex='L','Laki-laki','Perempuan')) TGL_LAHIR
		 , IF(k.jenisPelayanan=1,'Rawat Inap','Rawat Jalan') JENISRAWAT
		 , tjk.deskripsi TJKUNJ, proc.deskripsi PROC, kdp.deskripsi PENUNJANG, assp.deskripsi ASPEL
		 , IF(p.sex='L','Laki-laki','Perempuan') JENISKELAMIN, p.nmKelas KELAS
		 , CONCAT(r.CODE,' (',r.STR,')') DIAGNOSA, rp.NAMA RUJUKAN
		 , p.prolanisPRB PRB, penj.DESKRIPSI PENJAMIN
		 , IF(k.cob=0,'-','Ya') COB, k.noTelp NOTELP
		 , IF(k.katarak=1,'* PASIEN OPERASI KATARAK','') KATARAK
		 , dr.nama DOKTER
		 , (SELECT ref.DESKRIPSI
				FROM pendaftaran.kunjungan kj1
					 LEFT JOIN master.ruang_kamar_tidur rkt ON kj1.RUANG_KAMAR_TIDUR=rkt.ID
					 LEFT JOIN master.ruang_kamar rk ON rk.ID=rkt.RUANG_KAMAR
				    LEFT JOIN master.referensi ref ON rk.KELAS=ref.ID AND ref.JENIS=19
			   WHERE kj1.NOPEN=tp.NOPEN AND kj1.RUANG_KAMAR_TIDUR!=0 
				AND kj1.`STATUS`!=0 ORDER BY kj1.MASUK DESC LIMIT 1) KLSRAWAT
		 , 0 POLIPERUJUK
	FROM bpjs.kunjungan k
		  LEFT JOIN bpjs.peserta p ON k.noKartu = p.noKartu
		  LEFT JOIN master.ppk rp ON k.ppkRujukan = rp.BPJS
		  LEFT JOIN master.mrconso r ON k.diagAwal = r.CODE AND r.SAB='ICD10_1998' AND r.TTY !='HT' AND r.TTY !='PS'
		  LEFT JOIN pendaftaran.penjamin pp ON k.noSEP=pp.NOMOR
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOPEN=tp.NOPEN
		  LEFT JOIN master.ruangan mr ON tp.RUANGAN=mr.ID AND mr.JENIS=5
		  LEFT JOIN master.referensi penj ON k.penjamin=penj.ID AND penj.JENIS=80
		  LEFT JOIN bpjs.poli pl ON k.poliTujuan=pl.kode
		  LEFT JOIN bpjs.dpjp dr ON k.dpjpSKDP=dr.kode
		  LEFT JOIN bpjs.referensi tjk ON k.tujuanKunj=tjk.kode AND tjk.jenis_referensi_id=7
		  LEFT JOIN bpjs.referensi proc ON k.flagProcedure =proc.kode AND proc.jenis_referensi_id=8
		  LEFT JOIN bpjs.referensi kdp ON k.kdPenunjang=kdp.kode AND kdp.jenis_referensi_id=9
		  LEFT JOIN bpjs.referensi assp ON k.assesmentPel=assp.kode AND assp.jenis_referensi_id=10
		, (SELECT mp.NAMA 
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE k.cetak= 0 AND k.noSEP=PSEP
	GROUP BY k.noSEP;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
