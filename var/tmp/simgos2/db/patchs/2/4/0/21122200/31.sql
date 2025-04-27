-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping database structure for bpjs
USE `bpjs`;

-- Dumping structure for procedure bpjs.RujukanKeluar
DROP PROCEDURE IF EXISTS `RujukanKeluar`;
DELIMITER //
CREATE PROCEDURE `RujukanKeluar`(
	IN `PNOPEN` VARCHAR(10)
)
BEGIN
	SELECT inst.ID IDPPK, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATPPK
		, IF(pj.JENIS = 2, ruj.noRujukan, CONCAT(inst.KODE, rj.NOMOR)) NORUJUKAN, pj.JENIS CARABAYAR
		, IF(rj.JENIS = 2,
			CONCAT('== ', ref.DESKRIPSI, ' ', IFNULL(psr.prolanisPRB, '(Non PRB)'), ' == '),
			CONCAT('== Rujukan ', ref.DESKRIPSI, ' ==')
		) JENISRUJUKAN
		, ref.ID IDJNSRUJUKAN, psr.nmProvider PPKASAL
		, IF(pj.JENIS = 2, kap.NOMOR, '-') NOKARTUBPJS, ppk.NAMA TUJUAN, IF(pj.JENIS = 2, psr.nama, master.getNamaLengkap(p.NORM)) NAMAPASIEN
		, IF(pj.JENIS = 2, psr.tglLahir, p.TANGGAL_LAHIR) TGLLAHIR
		, IF(p.JENIS_KELAMIN = 1, 'Laki-laki', 'Perempuan') JENISKELAMIN
		, rj.KETERANGAN, rrj.DESKRIPSI TUJUANRUANGAN, rrj.REF_ID RUANGAN_PENJAMIN, 'Rawat Jalan' JENISKUNJUNGAN
		, CONCAT(mr.CODE, ' - ', mr.STR) DIAGNOSA
		, master.getNamaLengkapPegawai(dok.NIP) NAMADOKTER, rj.TANGGAL TGLRUJUKAN
		, DATE_ADD(rj.TANGGAL, INTERVAL 90 DAY) MASABERLAKU, CONCAT('Tgl. Cetak ',DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i %p')) TGLCETAK
	FROM pendaftaran.rujukan_keluar rj
		  LEFT JOIN master.referensi ref ON ref.ID = rj.JENIS AND ref.JENIS = 86
		  LEFT JOIN master.ppk ppk ON rj.TUJUAN = ppk.ID
		  LEFT JOIN master.referensi rrj ON rrj.JENIS = 70 AND rrj.ID = rj.TUJUAN_RUANGAN
		  LEFT JOIN master.dokter dok ON rj.DOKTER = dok.ID
		  LEFT JOIN master.mrconso mr ON rj.DIAGNOSA = mr.CODE AND mr.SAB = 'ICD10_1998' AND TTY IN ('PX', 'PT')
		, pendaftaran.pendaftaran pp
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR = pj.NOPEN
		  LEFT JOIN bpjs.rujukan ruj ON pj.NOMOR = ruj.noSep AND ruj.`status` = 1
		, master.pasien p
		  LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM = kap.NORM AND kap.JENIS = 2
		  LEFT JOIN bpjs.peserta psr ON kap.NOMOR=psr.noKartu
		, (SELECT ai.PPK ID, mp.NAMA, mp.KODE, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK = mp.ID) inst
	WHERE rj.NOPEN = pp.NOMOR AND rj.`STATUS` != 0 AND pp.`STATUS` != 0
	  AND pp.NORM = p.NORM AND pp.NOMOR = PNOPEN
	GROUP BY pp.NOMOR;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
