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

-- membuang struktur untuk procedure medicalrecord.CetakMR1
DROP PROCEDURE IF EXISTS `CetakMR1`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakMR1`(IN `PNOPEN` CHAR(10))
BEGIN 	
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') TGL_LAHIR
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
		, rjk.DESKRIPSI JENISKELAMIN
		, rpd.DESKRIPSI PENDIDIKAN
		, rpk.DESKRIPSI PEKERJAAN
		, CONCAT(rpd.DESKRIPSI,' / ',rpk.DESKRIPSI) PNDPKJ
		, rsk.DESKRIPSI STATUSKAWIN
		, rag.DESKRIPSI AGAMA
		, gol.DESKRIPSI GOLDARAH
		, ayah.NAMA NAMAAYAH
		, rpkayah.DESKRIPSI PEKERJAANAYAH
		, ibu.NAMA NAMAIBU
		, rpkibu.DESKRIPSI PEKERJAANIBU
		, si.NAMA SUAMIISTRI
		, rpksi.DESKRIPSI PEKERJAANSUAMIISTRI
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y') TGLREG
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN
		, IF(IF(pp.SHDK IN (9,10,11), pp.NAMA, kp.NAMA) IS NULL,'',IF(pp.SHDK IN (9,10,11), pp.NAMA, kp.NAMA)) PENANGGUNGJAWAB
		, IF(pp.SHDK IN (9,10,11), pp.ALAMAT, kp.ALAMAT) ALAMATPJ
		, IF(IF(pp.SHDK=7 AND pp.JENIS_KELAMIN=1,CONCAT(rpj.DESKRIPSI,' (Ayah)')
	  		,IF(pp.SHDK=7 AND pp.JENIS_KELAMIN=2,CONCAT(rpj.DESKRIPSI,' (Ibu)')
			, rpj.DESKRIPSI)) IS NULL,'',IF(pp.SHDK=7 AND pp.JENIS_KELAMIN=1,CONCAT(rpj.DESKRIPSI,' (Ayah)')
	  		,IF(pp.SHDK=7 AND pp.JENIS_KELAMIN=2,CONCAT(rpj.DESKRIPSI,' (Ibu)')
			, rpj.DESKRIPSI))) HUBUNGANKELUARGA
		, IF(pp.SHDK IN (9,10,11), rpdpj.DESKRIPSI, rpdkp.DESKRIPSI) PENDIDIKANPJ
		, IF(pp.SHDK IN (9,10,11), rpkpj.DESKRIPSI, rpkkp.DESKRIPSI) PEKERJAANPJ
		, rpjjk.DESKRIPSI JENISKELAMINPJ
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
		, CONCAT(rk.KAMAR,' / ',kelas.DESKRIPSI) KAMAR
	FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		  LEFT JOIN master.keluarga_pasien ayah ON p.NORM=ayah.NORM AND ayah.JENIS_KELAMIN=1 AND ayah.SHDK=7
		  LEFT JOIN master.referensi rpkayah ON ayah.PEKERJAAN=rpkayah.ID AND rpkayah.JENIS=4 AND ayah.SHDK=7
		  LEFT JOIN master.keluarga_pasien ibu ON p.NORM=ibu.NORM AND ibu.JENIS_KELAMIN=2 AND ibu.SHDK=7
		  LEFT JOIN master.referensi rpkibu ON ibu.PEKERJAAN=rpkibu.ID AND rpkibu.JENIS=4 AND ibu.SHDK=7
		  LEFT JOIN master.keluarga_pasien si ON p.NORM=si.NORM AND si.SHDK IN (2,3)
		  LEFT JOIN master.referensi rpksi ON si.PEKERJAAN=rpksi.ID AND rpksi.JENIS=4 AND si.SHDK IN (2,3)
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
		  LEFT JOIN pendaftaran.penanggung_jawab_pasien pp ON pd.NOMOR=pp.NOPEN
		  LEFT JOIN master.keluarga_pasien kp ON pp.SHDK=kp.SHDK AND pp.JENIS_KELAMIN=kp.JENIS_KELAMIN AND kp.NORM=pd.NORM 
		  LEFT JOIN master.referensi rpdpj ON pp.PENDIDIKAN=rpdpj.ID AND rpdpj.JENIS=3
		  LEFT JOIN master.referensi rpkpj ON pp.PEKERJAAN=rpkpj.ID AND rpkpj.JENIS=4
		  LEFT JOIN master.referensi rpdkp ON kp.PENDIDIKAN=rpdkp.ID AND rpdkp.JENIS=3
		  LEFT JOIN master.referensi rpkkp ON kp.PEKERJAAN=rpkkp.ID AND rpkkp.JENIS=4
		  LEFT JOIN master.referensi rpj ON pp.SHDK=rpj.ID AND rpj.JENIS=7 
		  LEFT JOIN master.referensi rpjjk ON pp.JENIS_KELAMIN=rpjjk.ID AND rpjjk.JENIS=2
		  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
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
