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

-- membuang struktur untuk procedure pendaftaran.CetakSEP
DROP PROCEDURE IF EXISTS `CetakSEP`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakSEP`(
	IN `PSEP` VARCHAR(20)


)
BEGIN
	SELECT inst.NAMA NAMAINSTANSI,k.noSEP NOMORSEP, DATE_FORMAT(k.tglSEP,'%d-%m-%Y') TGLSEP
		  , CONCAT(p.noKartu, '  ( MR. ',p.norm,' )') NOMORKARTU, p.norm NORM, pl.nama poliTujuan, k.klsRawat, mr.DESKRIPSI UNITPELAYANAN
		 , IF(k.jmlCetak > 1,CONCAT('*Cetakan Ke ',k.jmlCetak),'') CETAKAN , k.catatan CATATAN
		 , p.nmJenisPeserta PESERTA, p.nama NAMALENGKAP, CONCAT(DATE_FORMAT(p.tglLahir,'%d-%m-%Y'), '  Kelamin : ',IF(p.sex='L','Laki-laki','Perempuan')) TGL_LAHIR
		 , IF(k.jenisPelayanan=1,'Rawat Inap','Rawat Jalan') JENISRAWAT
		 , IF(p.sex='L','Laki-laki','Perempuan') JENISKELAMIN, p.nmKelas KELAS
		 , CONCAT(r.CODE,' (',r.STR,')') DIAGNOSA, rp.NAMA RUJUKAN
		 , p.prolanisPRB PRB, penj.DESKRIPSI PENJAMIN
		 , IF(k.cob=0,'-','Ya') COB, k.noTelp NOTELP
		 , IF(k.katarak=1,'* PASIEN OPERASI KATARAK','') KATARAK
	FROM bpjs.kunjungan k
		  LEFT JOIN bpjs.peserta p ON k.noKartu = p.noKartu
		  LEFT JOIN master.ppk rp ON k.ppkRujukan = rp.BPJS
		  LEFT JOIN master.mrconso r ON k.diagAwal = r.CODE AND r.SAB='ICD10_1998' AND r.TTY !='HT' AND r.TTY !='PS'
		  LEFT JOIN pendaftaran.penjamin pp ON k.noSEP=pp.NOMOR
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOPEN=tp.NOPEN
		  LEFT JOIN master.ruangan mr ON tp.RUANGAN=mr.ID AND mr.JENIS=5
		  LEFT JOIN master.referensi penj ON k.penjamin=penj.ID AND penj.JENIS=80
		  LEFT JOIN bpjs.poli pl ON k.poliTujuan=pl.kode
		, (SELECT mp.NAMA 
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE k.cetak= 0 AND k.noSEP=PSEP
	GROUP BY k.noSEP;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
