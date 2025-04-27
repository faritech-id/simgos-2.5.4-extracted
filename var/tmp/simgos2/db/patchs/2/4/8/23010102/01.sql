-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
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
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakMR2
DROP PROCEDURE IF EXISTS `CetakMR2`;
DELIMITER //
CREATE PROCEDURE `CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN 	
	SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.KOTA KOTA, inst.ALAMAT ALAMATINST
		, inst.TELEPON TLP, inst.FAX, inst.EMAIL, inst.WEBSITE 
		, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
		, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, rjk.DESKRIPSI JENISKELAMIN
		, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG
		, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG
		, DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLKELUAR
		, DATEDIFF(pl.TANGGAL, pd.TANGGAL) LAMADIRAWAT
		, u.DESKRIPSI RUANG_RAWAT_TERAKHIR
		, cr.DESKRIPSI CARA_BAYAR
		, rm.NOPEN,	an.DESKRIPSI ANAMNESIS, rpp.DESKRIPSI RPP, rps.DESKRIPSI RPS, ku.DESKRIPSI keluhan_utama, tv.KEADAAN_UMUM, tv.KESADARAN
		, CONCAT(tv.SISTOLIK,'/',tv.DISTOLIK) TEKANAN_DARAH, tv.FREKUENSI_NADI, tv.FREKUENSI_NAFAS, tv.SUHU, tv.SATURASI_O2
		, rt.DESKRIPSI RENCANA_TERAPI, ee.EDUKASI, ee.KEMBALI_KE_UGD, jd.NOMOR NOMOR_KONTROL
		, jd.TANGGAL TANGGAL_KONTROL, r.DESKRIPSI RUANG_KONTROL
		, IF(pl.DOKTER IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(mpdokdpjp.NIP)) DPJP
		, IF(pl.DOKTER IS NULL,drreg.NIP,mpdokdpjp.NIP) NIP
		, master.getJawabanKonsul(rm.NOPEN) KONSULTASI
		, kd.DESKRIPSI KEADAAN_KELUAR
		, IF(kd.ID=1,1,0) SEMBUH
		, IF(kd.ID=2,1,0) MEMBAIK
		, IF(kd.ID=3,1,0) BELUM_SEMBUH
		, IF(kd.ID=4,1,0) MENINGGAL_KURANG48
		, IF(kd.ID=5,1,0) MENINGGAL_LEBIH48
		, ck.DESKRIPSI CARA_KELUAR
		, IF(ck.ID=1,1,0) DIIJINKAN_PULANG
		, IF(ck.ID=2,1,0) PULANG_PAKSA
		, IF(ck.ID=3,1,0) DIRUJUK
		, IF(ck.ID=4,1,0) LAIN_LAIN
		, IF(ck.ID=5,1,0) PINDAH_RS
		, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
				FROM medicalrecord.riwayat_alergi ra 
					, pendaftaran.kunjungan kj
				WHERE ra.KUNJUNGAN=kj.NOMOR AND kj.`STATUS`!=0 AND ra.JENIS=1 AND ra.`STATUS`!=0
				AND kj.NOPEN=pd.NOMOR) ALERGI
		 , medicalrecord.getHasilLaboratoriumResume(rm.NOPEN) LAB
		 , medicalrecord.getHasilRadiologiResume(rm.NOPEN) RAD
		 , IFNULL(layanan.getResepPulang(PNOPEN),0) RESEPPULANG
		 , IFNULL(master.getKodeDiagnosa(PNOPEN,1),0) STS_DIAG_UTAMA
		 , IFNULL(master.getKodeDiagnosa(PNOPEN,2),0) STS_DIAG_SEKUNDER
		 , IFNULL(master.getKodeICD9CM(PNOPEN),0) STS_PROSEDUR 
		 , CONCAT(IFNULL((SELECT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
				(pf1.DESKRIPSI,'font-family: &quot;Open Sans&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif;','')
				,'Open Sans, Helvetica Neue, Helvetica, ','')
				,'face="open sans"','')
				,'style="font-family:','style="font-face:'),' style=""',''))
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pd.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1),''),'; ',' \r'
			, IFNULL(CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ','Kesadaran : ',tv.KESADARAN,'; ','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ','Nadi : ',tv.FREKUENSI_NADI,'; ','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ','Suhu Tubuh : ',tv.SUHU)
			, (SELECT CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ','Kesadaran : ',tv.KESADARAN,'; ','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ','Nadi : ',tv.FREKUENSI_NADI,'; ','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ','Suhu Tubuh : ',tv.SUHU)
				FROM medicalrecord.tanda_vital tv
				LEFT JOIN pendaftaran.kunjungan ptv ON ptv.NOMOR=tv.KUNJUNGAN
				WHERE ptv.NOPEN=pd.NOMOR 
				ORDER BY tv.WAKTU_PEMERIKSAAN DESC LIMIT 1))) FISIK
	FROM medicalrecord.`resume` rm
	     LEFT JOIN medicalrecord.anamnesis an ON rm.ANAMNESIS=an.ID AND an.`STATUS`!=0
	     LEFT JOIN medicalrecord.rpp  ON rm.RPP=rpp.ID AND rpp.`STATUS`!=0
	     LEFT JOIN medicalrecord.rps  ON rm.RPS=rps.ID AND rps.`STATUS`!=0
	     LEFT JOIN medicalrecord.keluhan_utama ku  ON rm.KELUHAN_UTAMA=ku.ID AND ku.`STATUS`!=0
	     LEFT JOIN medicalrecord.tanda_vital tv  ON rm.TANDA_VITAL=tv.ID AND tv.`STATUS`!=0
	     LEFT JOIN medicalrecord.rencana_terapi rt  ON rm.RENCANA_TERAPI=rt.ID AND rt.`STATUS`!=0
	     LEFT JOIN medicalrecord.edukasi_emergency ee  ON rm.EDUKASI_EMERGENCY=ee.ID AND ee.`STATUS`!=0
	     LEFT JOIN medicalrecord.jadwal_kontrol jd  ON rm.JADWAL_KONTROL=jd.ID AND jd.`STATUS`!=0
	     LEFT JOIN `master`.ruangan r ON jd.RUANGAN=r.ID AND r.`STATUS`!=0
	   , pendaftaran.pendaftaran pd
	     LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN AND pl.`STATUS`=1
	     LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
		  LEFT JOIN pendaftaran.kunjungan pk ON pl.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
		  LEFT JOIN master.ruangan u ON pk.RUANGAN=u.ID AND u.JENIS=5
		  LEFT JOIN master.dokter dokdpjp ON pl.DOKTER=dokdpjp.ID
		  LEFT JOIN master.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
		  LEFT JOIN master.referensi kd ON pl.KEADAAN=kd.ID AND kd.JENIS=46
		  LEFT JOIN master.referensi ck ON pl.CARA=ck.ID AND ck.JENIS=45
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pd.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan rg ON tp.RUANGAN=rg.ID AND rg.JENIS=5
		  LEFT JOIN master.dokter drreg ON tp.DOKTER=drreg.ID
	   ,  master.pasien p
	     LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
	     , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT , mp.TELEPON, mp.FAX
					, ai.EMAIL, ai.WEBSITE
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
	WHERE rm.NOPEN=PNOPEN AND rm.NOPEN=pd.NOMOR AND pd.`STATUS`!=0 AND pd.NORM=p.NORM AND p.`STATUS`!=0
		AND pd.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
	GROUP BY pd.NOMOR;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
