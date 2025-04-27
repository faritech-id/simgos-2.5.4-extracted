-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.4.0.6659
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

-- Dumping structure for procedure medicalrecord.CetakSummaryList
DROP PROCEDURE IF EXISTS `CetakSummaryList`;
DELIMITER //
CREATE PROCEDURE `CetakSummaryList`(
	IN `PNORM` CHAR(10)
)
BEGIN 	
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
		, LPAD(p.NORM,8,'0') NORM, kip.NOMOR KTP
	   , master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, CONCAT(p.RT,'/',p.RW) RTRW
		, p.RT, p.RW
		, (SELECT GROUP_CONCAT(kp.NOMOR) 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM) KONTAK 	
		, (SELECT CONCAT(IF(p.WILAYAH='' OR p.WILAYAH IS NULL,''
				, CONCAT('Kel/Desa .',kel.DESKRIPSI,' '
				, 'Kec. ',kec.DESKRIPSI,' '
				, 'Kab/Kota. ',kab.DESKRIPSI,' '
				, 'prov. ',prov.DESKRIPSI)))
			  FROM master.pasien p
				  LEFT JOIN master.wilayah kel ON kel.ID=p.WILAYAH
				  LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
				  LEFT JOIN master.wilayah kab ON kab.ID = LEFT(p.WILAYAH, 4)
				  LEFT JOIN master.wilayah prov ON prov.ID = LEFT(p.WILAYAH, 2)
				 WHERE p.NORM = PNORM) PSALAMAT1
		, p.ALAMAT PSALAMAT
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
		, suku.DESKRIPSI SUKU
		, kb.DESKRIPSI NEGARA
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
		, CONCAT(rk.KAMAR,' / ',kelas.DESKRIPSI) KAMAR
		, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
									FROM medicalrecord.riwayat_alergi ra
										, pendaftaran.kunjungan pk1
										, pendaftaran.pendaftaran pp2
									WHERE ra.KUNJUNGAN=pk1.NOMOR AND ra.STATUS!=0 AND pk1.STATUS!=0
									  AND pk1.NOPEN=pp2.NOMOR AND pp2.`STATUS`!=0 AND ra.DESKRIPSI!=''
									  AND pp2.NORM=pd.NORM) RIWAYATALERGI
	FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		  LEFT JOIN master.referensi suku ON p.SUKU=suku.ID AND suku.JENIS=140
		  LEFT JOIN master.wilayah kb ON p.KEWARGANEGARAAN=kb.ID
		  LEFT JOIN master.kartu_identitas_pasien kip ON p.NORM=kip.NORM AND kip.JENIS=1		  
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.NORM=srp.NORM AND pd.RUJUKAN=srp.NOMOR AND srp.`STATUS`!=0
		  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID		  
		  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.referensi sm ON sm.ID=tp.SMF AND sm.JENIS=26
		  LEFT JOIN pendaftaran.reservasi res ON tp.RESERVASI=res.NOMOR
		  LEFT JOIN master.ruang_kamar_tidur rkt ON res.RUANG_KAMAR_TIDUR=rkt.ID
		  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
		  LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		, (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND p.NORM=PNORM
	GROUP BY p.NORM
	;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.DetailSummaryList
DROP PROCEDURE IF EXISTS `DetailSummaryList`;
DELIMITER //
CREATE PROCEDURE `DetailSummaryList`(
	IN `PNORM` CHAR(10)
)
BEGIN 	
	SELECT p.NOMOR, k.NOMOR, r.DESKRIPSI RUANGAN, DATE_FORMAT(k.MASUK,'%d-%m-%Y %H:%i:%s') TGL
		, `master`.getNamaLengkapPegawai(d.NIP) DPJP
		, IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=k.NOMOR  LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=k.NOMOR  LIMIT 1))) RIWAYATPENYAKIT
		, CONCAT(IF(master.getDiagnosaPasien(p.NOMOR) IS NULL,IFNULL(dg.DIAGNOSIS,''),master.getDiagnosaPasien(p.NOMOR)),'\r',
							IFNULL((SELECT ass.ASSESMENT
							FROM medicalrecord.cppt ass
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
							WHERE pkrp.NOMOR=k.NOMOR 
							ORDER BY ass.TANGGAL DESC LIMIT 1),'')) DIAGNOSIS
		, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
									FROM medicalrecord.riwayat_alergi ra
										, pendaftaran.kunjungan pk1
										, pendaftaran.pendaftaran pp2
									WHERE ra.KUNJUNGAN=pk1.NOMOR AND ra.STATUS!=0 AND pk1.STATUS!=0
									  AND pk1.NOPEN=pp2.NOMOR AND pp2.`STATUS`!=0 AND ra.DESKRIPSI!=''
									  AND pp2.NORM=p.NORM) RIWAYATALERGI
		, rcnt.DESKRIPSI RNCTERAPI
FROM pendaftaran.kunjungan k
	  LEFT JOIN `master`.dokter d ON k.DPJP=d.ID
	  LEFT JOIN medicalrecord.rpp rpp ON k.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
	  LEFT JOIN medicalrecord.rencana_terapi rcnt ON k.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
	  LEFT JOIN medicalrecord.diagnosis dg ON k.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
	, pendaftaran.pendaftaran p
	, `master`.ruangan r
		 WHERE k.NOPEN=p.NOMOR AND k.`STATUS` !=0 AND p.`STATUS` !=0
		 AND r.ID=k.RUANGAN AND r.JENIS_KUNJUNGAN=1
		 AND p.NORM=PNORM
		 ORDER BY k.MASUK DESC;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
