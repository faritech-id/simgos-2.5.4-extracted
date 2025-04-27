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

-- membuang struktur untuk procedure medicalrecord.PemberianInfo
DROP PROCEDURE IF EXISTS `PemberianInfo`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `PemberianInfo`(
	IN `PNOPEN` VARCHAR(10)






)
BEGIN
			SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, p.RT
		, p.RW
		
		, IF((SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM)='',p.ALAMAT,CONCAT(p.ALAMAT,' - (',(SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM),')')) ALAMAT
		, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALKUNJUNGAN
		, LPAD(DAY(pd.TANGGAL),2,'0') HARI, LPAD(MONTH(pd.TANGGAL),2,'0') BULAN, YEAR(pd.TANGGAL) THN
		, DATE_FORMAT(pd.TANGGAL,'%H:%i:%s') JAM
		, DATE_FORMAT(plg.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALPULANG
		, rjk.DESKRIPSI JENISKELAMIN
		, rpd.DESKRIPSI PENDIDIKAN
		, rpk.DESKRIPSI PEKERJAAN
		, CONCAT(rpd.DESKRIPSI,' / ',rpk.DESKRIPSI) PNDPKJ
		, rsk.DESKRIPSI STATUSKAWIN
		, rag.DESKRIPSI AGAMA
		, gol.DESKRIPSI GOLDARAH
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y') TGLREG
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN
		, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=1) KODEMR1
		, (SELECT IF(r.JENIS_KUNJUNGAN=1,'Melalui IRJ','Melalui IRD') 
					FROM pendaftaran.pendaftaran tpd
						, pendaftaran.tujuan_pasien tp
					   , master.ruangan r 
					WHERE tpd.NOMOR=tp.NOPEN AND tp.RUANGAN=r.ID AND r.JENIS=5 AND tpd.TANGGAL < pd.TANGGAL
							AND r.JENIS=5 AND r.JENIS_KUNJUNGAN IN (1,2) AND tpd.NORM=pd.NORM
					ORDER BY tpd.TANGGAL DESC
					LIMIT 1) CARAPENERIMAAN
		, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
		, sm.DESKRIPSI SMF
		, CONCAT(rr.DESKRIPSI,' / ',rk.KAMAR,' / ',kelas.DESKRIPSI) KAMAR		
	FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
		  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
		  LEFT JOIN layanan.pasien_pulang plg on pd.NOMOR=plg.NOPEN
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.ruangan rr ON tp.RUANGAN=rr.ID AND rr.JENIS=5
		  LEFT JOIN master.referensi sm ON sm.ID=tp.SMF AND sm.JENIS=26
		  LEFT JOIN pendaftaran.reservasi res ON tp.RESERVASI=res.NOMOR
		  LEFT JOIN master.ruang_kamar_tidur rkt ON res.RUANG_KAMAR_TIDUR=rkt.ID
		  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
		  LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		, (SELECT mp.NAMA, ai.PPK 
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=PNOPEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
