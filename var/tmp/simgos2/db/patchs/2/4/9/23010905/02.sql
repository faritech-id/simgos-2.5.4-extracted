-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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
		, rm.NOPEN
		, IFNULL(an.DESKRIPSI,(SELECT a.DESKRIPSI FROM medicalrecord.anamnesis a WHERE a.PENDAFTARAN=pd.NOMOR LIMIT 1)) ANAMNESIS
		, IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rpp rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR LIMIT 1)) RPP
		, IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR LIMIT 1)) RPS
		, IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				FROM medicalrecord.keluhan_utama ku
				LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
				WHERE pku.NOPEN=pd.NOMOR AND pku.REF IS NULL LIMIT 1)) keluhan_utama
		, tv.KEADAAN_UMUM, tv.KESADARAN
		, CONCAT(ROUND(tv.SISTOLIK),'/',ROUND(tv.DISTOLIK)) TEKANAN_DARAH, ROUND(tv.FREKUENSI_NADI) FREKUENSI_NADI
		, ROUND(tv.FREKUENSI_NAFAS) FREKUENSI_NAFAS, ROUND(tv.SUHU) SUHU, ROUND(tv.SATURASI_O2) SATURASI_O2
		, rt.DESKRIPSI RENCANA_TERAPI
		, IFNULL(ee.EDUKASI, (SELECT e.EDUKASI 
					FROM medicalrecord.edukasi_emergency e
						, pendaftaran.kunjungan pk
					WHERE e.KUNJUNGAN=pk.NOMOR AND e.`STATUS`!=0 
					AND pk.NOPEN=pd.NOMOR
					ORDER BY e.TANGGAL DESC LIMIT 1)) EDUKASI
		, IFNULL(ee.KEMBALI_KE_UGD, (SELECT e.KEMBALI_KE_UGD 
					FROM medicalrecord.edukasi_emergency e
						, pendaftaran.kunjungan pk
					WHERE e.KUNJUNGAN=pk.NOMOR AND e.`STATUS`!=0 
					AND pk.NOPEN=pd.NOMOR
					ORDER BY e.TANGGAL DESC LIMIT 1)) KEMBALI_KE_UGD
		, jd.NOMOR NOMOR_KONTROL
		, jd.TANGGAL TANGGAL_KONTROL, r.DESKRIPSI RUANG_KONTROL, '' KET_KONTROL
		, jd.NOMOR_REFERENSI
		, IF(jd.NOMOR IS NOT NULL,1,0) POLIKLINIK_RS
		, (SELECT pri.DESKRIPSI
			FROM medicalrecord.perencanaan_rawat_inap pri 
				, pendaftaran.kunjungan k
				, pendaftaran.pendaftaran d
			WHERE pri.KUNJUNGAN=k.NOMOR AND pri.`STATUS`!=0 AND k.`STATUS`!=0
			 AND k.NOPEN=d.NOMOR AND d.`STATUS`!=0 AND d.NORM=pd.NORM AND d.TANGGAL < pd.TANGGAL
			ORDER BY d.TANGGAL DESC
			LIMIT 1) INDIKASI_RAWAT_INAP
		, IF(pl.DOKTER IS NULL,`master`.getDPJP(pd.NOMOR, 2),master.getNamaLengkapPegawai(mpdokdpjp.NIP)) DPJP
		, IF(pl.DOKTER IS NULL,`master`.getDPJP(pd.NOMOR, 1),mpdokdpjp.NIP) NIP
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
		, (SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) 
				  FROM medicalrecord.`resume` r, 
				        JSON_TABLE(r.HASIL_LAB,
				         '$[*]' COLUMNS(
				                ID CHAR(12) PATH '$.ID'
				            )   
				       ) AS hl
				     , layanan.hasil_lab hlab
				       LEFT JOIN master.parameter_tindakan_lab ptl ON hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
						 LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
				WHERE r.NOPEN=PNOPEN AND hl.ID=hlab.ID AND hlab.`STATUS`!=0) t
		, rm.ALERGI_REAKSI_OBAT ALERGI
	   , IF(rm.DESKRIPSI_HASIL_LAB='',(SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) 
				  FROM medicalrecord.`resume` r, 
				        JSON_TABLE(r.HASIL_LAB,
				         '$[*]' COLUMNS(
				                ID CHAR(12) PATH '$.ID'
				            )   
				       ) AS hl
				     , layanan.hasil_lab hlab
				       LEFT JOIN master.parameter_tindakan_lab ptl ON hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
						 LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
				WHERE r.NOPEN=PNOPEN AND hl.ID=hlab.ID AND hlab.`STATUS`!=0), rm.DESKRIPSI_HASIL_LAB) LAB
		 
		 , IF(rm.DESKRIPSI_HASIL_RAD='',(SELECT GROUP_CONCAT(t.NAMA,' = ',hr.KESAN)
				  FROM medicalrecord.`resume` r, 
				        JSON_TABLE(r.HASIL_RAD,
				         '$[*]' COLUMNS(
				                ID INT PATH '$.ID'
									
				            )   
				       ) AS hl
				     , layanan.hasil_rad hr
				     , layanan.tindakan_medis tm
				     , `master`.tindakan t
				WHERE r.NOPEN=PNOPEN AND hl.ID=hr.ID AND hr.`STATUS`!=0 AND hr.TINDAKAN_MEDIS=tm.ID AND tm.`STATUS`!=0
					AND tm.TINDAKAN=t.ID), rm.DESKRIPSI_HASIL_RAD) RAD
		 , IFNULL(layanan.getResepPulang(PNOPEN),0) RESEPPULANG
		 , IFNULL((SELECT jt.ID  IDDIAGNOSA
					  FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
					         '$[*]' COLUMNS(
					                ID INT PATH '$.ID',
					                UTAMA INT PATH '$.UTAMA',
					                NESTED PATH '$.PROSEDUR[*]' 
										 COLUMNS (
					                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
					                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
										  )
					            )   
					       ) AS jt
					WHERE r.NOPEN=pd.NOMOR AND UTAMA=1
					LIMIT 1),0) STS_DIAG_UTAMA
		 , IFNULL((SELECT jt.ID  IDDIAGNOSA
					  FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
					         '$[*]' COLUMNS(
					                ID INT PATH '$.ID',
					                UTAMA INT PATH '$.UTAMA',
					                NESTED PATH '$.PROSEDUR[*]' 
										 COLUMNS (
					                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
					                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
										  )
					            )   
					       ) AS jt
					WHERE r.NOPEN=pd.NOMOR AND UTAMA=2
					LIMIT 1),0) STS_DIAG_SEKUNDER
		 , IFNULL(master.getKodeICD9CM(PNOPEN),0) STS_PROSEDUR 
		 , UPPER((master.getDiagnosa(PNOPEN,1))) DIAGNOSAUTAMA, (master.getKodeDiagnosa(PNOPEN,1)) KODEDIAGNOSAUTAMA
		 , (master.getDiagnosa(PNOPEN,2)) DIAGNOSASEKUNDER, (master.getKodeDiagnosa(PNOPEN,2)) KODEDIAGNOSASEKUNDER
		 , (SELECT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
				(pf1.DESKRIPSI,'font-family: &quot;Open Sans&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif;','')
				,'Open Sans, Helvetica Neue, Helvetica, ','')
				,'face="open sans"','')
				,'style="font-family:','style="font-face:'),' style=""',''))
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pd.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1) FISIK
	FROM pendaftaran.pendaftaran pd
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
		 LEFT JOIN medicalrecord.`resume` rm ON rm.NOPEN=pd.NOMOR
	     LEFT JOIN medicalrecord.anamnesis an ON rm.ANAMNESIS=an.ID AND an.`STATUS`!=0
	     LEFT JOIN medicalrecord.rpp  ON rm.RPP=rpp.ID AND rpp.`STATUS`!=0
	     LEFT JOIN medicalrecord.rps  ON rm.RPS=rps.ID AND rps.`STATUS`!=0
	     LEFT JOIN medicalrecord.keluhan_utama ku  ON rm.KELUHAN_UTAMA=ku.ID AND ku.`STATUS`!=0
	     LEFT JOIN medicalrecord.tanda_vital tv  ON rm.TANDA_VITAL=tv.ID AND tv.`STATUS`!=0
	     LEFT JOIN medicalrecord.rencana_terapi rt  ON rm.RENCANA_TERAPI=rt.ID AND rt.`STATUS`!=0
	     LEFT JOIN medicalrecord.edukasi_emergency ee  ON rm.EDUKASI_EMERGENCY=ee.ID AND ee.`STATUS`!=0
	     LEFT JOIN medicalrecord.jadwal_kontrol jd  ON rm.JADWAL_KONTROL=jd.ID AND jd.`STATUS`!=0
	     LEFT JOIN `master`.ruangan r ON jd.RUANGAN=r.ID AND r.`STATUS`!=0
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
	WHERE pd.NOMOR=PNOPEN AND pd.`STATUS`!=0 AND pd.NORM=p.NORM AND p.`STATUS`!=0
		AND pd.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
	GROUP BY pd.NOMOR;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
