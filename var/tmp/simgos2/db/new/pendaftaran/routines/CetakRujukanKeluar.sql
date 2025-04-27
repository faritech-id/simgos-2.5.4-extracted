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

-- membuang struktur untuk procedure pendaftaran.CetakRujukanKeluar
DROP PROCEDURE IF EXISTS `CetakRujukanKeluar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakRujukanKeluar`(
	IN `PNOPEN` VARCHAR(10)
)
BEGIN
	SELECT inst.ID IDPPK, inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATPPK, IF(pj.JENIS=2, ruj.noRujukan, CONCAT(inst.KODE, rj.NOMOR)) NORUJUKAN
		, pj.JENIS CARABAYAR, IF(rj.JENIS=2,ref.DESKRIPSI,CONCAT('== Rujukan ',ref.DESKRIPSI,' ==')) JENISRUJUKAN
		, IF(pj.JENIS=2,kap.NOMOR,'-') NOKARTUBPJS, ppk.NAMA TUJUAN, IF(pj.JENIS=2,psr.nama, master.getNamaLengkap(p.NORM)) NAMAPASIEN
		, IF(pj.JENIS=2,psr.tglLahir,p.TANGGAL_LAHIR) TGLLAHIR
		, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
		, rj.KETERANGAN, rrj.DESKRIPSI TUJUANRUANGAN, rrj.REF_ID RUANGAN_PENJAMIN, 'Rawat Jalan' JENISKUNJUNGAN
		, CONCAT(mr.CODE,' - ',mr.STR) DIAGNOSA
		, master.getNamaLengkapPegawai(dok.NIP) NAMADOKTER, rj.TANGGAL TGLRUJUKAN
		, DATE_ADD(rj.TANGGAL, INTERVAL 90 DAY) MASABERLAKU, CONCAT('Tgl. Cetak ',DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i %p')) TGLCETAK
	FROM pendaftaran.rujukan_keluar rj
		  LEFT JOIN master.referensi ref ON ref.ID=rj.JENIS AND ref.JENIS=86
		  LEFT JOIN master.ppk ppk ON rj.TUJUAN=ppk.ID
		  LEFT JOIN master.referensi rrj ON rrj.JENIS = 70 AND rrj.ID = rj.TUJUAN_RUANGAN
		  LEFT JOIN master.dokter dok ON rj.DOKTER=dok.ID
		  LEFT JOIN master.mrconso mr ON rj.DIAGNOSA=mr.CODE AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
		, pendaftaran.pendaftaran pp
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN bpjs.rujukan ruj ON pj.NOMOR=ruj.noSep AND ruj.`status`=1
		, master.pasien p
		  LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
		  LEFT JOIN bpjs.peserta psr ON kap.NOMOR=psr.noKartu
		, (SELECT ai.PPK ID, mp.NAMA, mp.KODE, mp.ALAMAT
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE rj.NOPEN=pp.NOMOR AND rj.`STATUS`!=0 AND pp.`STATUS`!=0
	  AND pp.NORM=p.NORM AND pp.NOMOR=PNOPEN
	GROUP BY pp.NOMOR;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
