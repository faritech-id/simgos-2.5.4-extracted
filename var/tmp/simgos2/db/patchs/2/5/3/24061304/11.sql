USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakMR2
DROP PROCEDURE IF EXISTS `CetakMR2`;
DELIMITER //
CREATE PROCEDURE `CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SET SESSION group_concat_max_len = 1000000;
	
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_HASIL_LAB;
	CREATE TEMPORARY TABLE TEMP_DATA_HASIL_LAB ENGINE=MEMORY
		SELECT DISTINCT hl.ID
		  FROM medicalrecord.`resume` r, 
		        JSON_TABLE(r.HASIL_LAB,
		         '$[*]' COLUMNS(
		                ID CHAR(12) PATH '$.ID'
		            )   
		       ) AS hl
		 WHERE r.NOPEN = PNOPEN AND r.`STATUS`!=0;
					
	ALTER TABLE TEMP_DATA_HASIL_LAB 
	  CHANGE COLUMN ID ID CHAR(12) NOT NULL,
	   ADD PRIMARY KEY(ID);
   
	SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.KOTA KOTA, inst.ALAMAT ALAMATINST
		, inst.TELEPON TLP, inst.FAX, inst.EMAIL, inst.WEBSITE 
		, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
		, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, rjk.DESKRIPSI JENISKELAMIN
		, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG
		, DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLKELUAR
		, DATEDIFF(pl.TANGGAL, pd.TANGGAL) LAMADIRAWAT
		, u.DESKRIPSI RUANG_RAWAT_TERAKHIR
		, cr.DESKRIPSI CARA_BAYAR
		, rm.NOPEN
		, IF(IFNULL(an.DESKRIPSI,(SELECT a.DESKRIPSI 
				  FROM medicalrecord.anamnesis a, pendaftaran.kunjungan kg, `master`.ruangan rg 
				 WHERE a.PENDAFTARAN=pd.NOMOR AND a.KUNJUNGAN=kg.NOMOR AND  kg.RUANGAN=rg.ID AND kg.STATUS!=0 AND rg.JENIS_KUNJUNGAN=3
				ORDER BY a.TANGGAL DESC
				LIMIT 1))='-','Tidak Ada',
							IFNULL(an.DESKRIPSI,(SELECT a.DESKRIPSI 
				  FROM medicalrecord.anamnesis a, pendaftaran.kunjungan kg, `master`.ruangan rg 
				 WHERE a.PENDAFTARAN=pd.NOMOR AND a.KUNJUNGAN=kg.NOMOR AND  kg.RUANGAN=rg.ID AND kg.STATUS!=0 AND rg.JENIS_KUNJUNGAN=3
				ORDER BY a.TANGGAL DESC
				LIMIT 1))) ANAMNESIS	
		, IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rpp rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR ORDER BY rp.TANGGAL LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rpp rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR ORDER BY rp.TANGGAL LIMIT 1))) RPP
		, IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR ORDER BY rp.TANGGAL LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR ORDER BY rp.TANGGAL LIMIT 1))) RPS
		, IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				FROM medicalrecord.keluhan_utama ku
				LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
				WHERE pku.NOPEN=pd.NOMOR AND pku.REF IS NULL 
				ORDER BY ku.TANGGAL DESC LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				FROM medicalrecord.keluhan_utama ku
				LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
				WHERE pku.NOPEN=pd.NOMOR AND pku.REF IS NULL 
				ORDER BY ku.TANGGAL DESC LIMIT 1))) keluhan_utama
		, IF(ck.ID IN (6,7),'Tidak ada',(SELECT CONCAT(ROUND(pn.NYERI),' Metode : ',mny.DESKRIPSI)
				FROM medicalrecord.penilaian_nyeri pn
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN
				LEFT JOIN master.referensi mny ON pn.METODE=mny.ID AND mny.JENIS=71
				WHERE pkrp.NOPEN=pd.NOMOR LIMIT 1)) NYERI  
		, tv.KEADAAN_UMUM, tv.KESADARAN, rtv.DESKRIPSI TINGKAT_KESADARAN
		, CONCAT(ROUND(tv.SISTOLIK),'/',ROUND(tv.DISTOLIK)) TEKANAN_DARAH, ROUND(tv.FREKUENSI_NADI) FREKUENSI_NADI
		, ROUND(tv.FREKUENSI_NAFAS) FREKUENSI_NAFAS, ROUND(tv.SUHU) SUHU, ROUND(tv.SATURASI_O2) SATURASI_O2
		, rt.DESKRIPSI RENCANA_TERAPI
		, IF(kd.ID IN (4,5),'Tidak Ada',IFNULL(ee.EDUKASI, (SELECT e.EDUKASI 
					FROM medicalrecord.edukasi_emergency e
						, pendaftaran.kunjungan pk
					WHERE e.KUNJUNGAN=pk.NOMOR AND e.`STATUS`!=0 
					AND pk.NOPEN=pd.NOMOR
					ORDER BY e.TANGGAL DESC LIMIT 1))) EDUKASI
		, IF(kd.ID IN (4,5),'Tidak Ada',IFNULL(ee.KEMBALI_KE_UGD, (SELECT e.KEMBALI_KE_UGD 
					FROM medicalrecord.edukasi_emergency e
						, pendaftaran.kunjungan pk
					WHERE e.KUNJUNGAN=pk.NOMOR AND e.`STATUS`!=0 
					AND pk.NOPEN=pd.NOMOR
					ORDER BY e.TANGGAL DESC LIMIT 1))) KEMBALI_KE_UGD
		, IF(kd.ID IN (4,5),'Tidak Ada',jd.NOMOR) NOMOR_KONTROL
		, IF(kd.ID IN (4,5),null,jd.TANGGAL) TANGGAL_KONTROL
		, IF(kd.ID IN (4,5),'Tidak Ada',r.DESKRIPSI) RUANG_KONTROL
		, '' KET_KONTROL
		, IF(kd.ID IN (4,5),'Tidak Ada',jd.NOMOR_REFERENSI) NOMOR_REFERENSI
		, IF(kd.ID IN (4,5),0,IF(jd.NOMOR IS NOT NULL,1,0)) POLIKLINIK_RS
		, IF(rm.INDIKASI_RAWAT_INAP='',(SELECT pri.DESKRIPSI
			FROM pendaftaran.kunjungan k
				  LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON pri.KUNJUNGAN=k.NOMOR AND pri.`STATUS`!=0
				, pendaftaran.pendaftaran d
				, `master`.ruangan r
			WHERE   k.NOPEN=d.NOMOR AND k.`STATUS`!=0 AND k.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN NOT IN (0,3,4,5,6,11,13,14)
			  AND d.`STATUS`!=0 AND d.NORM=pd.NORM AND d.TANGGAL < pd.TANGGAL
			ORDER BY d.TANGGAL DESC
			LIMIT 1),IFNULL(CONCAT((SELECT pri.DESKRIPSI
			FROM pendaftaran.kunjungan k
				  LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON pri.KUNJUNGAN=k.NOMOR AND pri.`STATUS`!=0
				, pendaftaran.pendaftaran d
				, `master`.ruangan r
			WHERE   k.NOPEN=d.NOMOR AND k.`STATUS`!=0 AND k.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN NOT IN (0,3,4,5,6,11,13,14)
			  AND d.`STATUS`!=0 AND d.NORM=pd.NORM AND d.TANGGAL < pd.TANGGAL
			ORDER BY d.TANGGAL DESC
			LIMIT 1),'\r',rm.INDIKASI_RAWAT_INAP),rm.INDIKASI_RAWAT_INAP)) INDIKASI_RAWAT_INAP
		, IF(pl.DOKTER IS NULL,`master`.getDPJP(pd.NOMOR, 2),master.getNamaLengkapPegawai(mpdokdpjp.NIP)) DPJP
		, IF(pl.DOKTER IS NULL,`master`.getDPJP(pd.NOMOR, 1),mpdokdpjp.NIP) NIP
		, IF(IF(rm.DESKRIPSI_KONSUL='-' OR rm.DESKRIPSI_KONSUL='', master.getJawabanKonsul(rm.NOPEN), rm.DESKRIPSI_KONSUL)='','Tidak Ada'
			, IF(rm.DESKRIPSI_KONSUL='-' OR rm.DESKRIPSI_KONSUL='', master.getJawabanKonsul(rm.NOPEN), rm.DESKRIPSI_KONSUL)) KONSULTASI
	
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
	   , IF(rm.ALERGI_REAKSI_OBAT='-' OR rm.ALERGI_REAKSI_OBAT='','Tidak Ada',rm.ALERGI_REAKSI_OBAT) ALERGI
	   , IF(rm.DESKRIPSI_HASIL_LAB=''
				,(SELECT REPLACE(GROUP_CONCAT(hasil SEPARATOR ';'),';','\r')
					 FROM (
							SELECT CONCAT('Tgl Hasil ',DATE_FORMAT(hlab.TANGGAL,'%d-%m-%Y'),', ', GROUP_CONCAT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) hasil			  
								FROM TEMP_DATA_HASIL_LAB r
									       , layanan.hasil_lab hlab
									       LEFT JOIN master.parameter_tindakan_lab ptl ON hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
											 LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
									WHERE hlab.ID=r.ID AND hlab.`STATUS`!=0
									GROUP BY DATE(hlab.TANGGAL)
							) gh), rm.DESKRIPSI_HASIL_LAB) LAB
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
				WHERE r.NOPEN=PNOPEN AND hl.ID=hr.ID AND hr.`STATUS`!=0 AND hr.TINDAKAN_MEDIS=tm.ID AND tm.`STATUS`!=0 AND r.`STATUS`!=0
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
					WHERE r.NOPEN=pd.NOMOR AND UTAMA=1 AND r.`STATUS`!=0
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
					WHERE r.NOPEN=pd.NOMOR AND UTAMA=2 AND r.`STATUS`!=0
					LIMIT 1),0) STS_DIAG_SEKUNDER
		 , IFNULL(master.getKodeICD9CM(PNOPEN),0) STS_PROSEDUR 
		 , UPPER((master.getDiagnosa(PNOPEN,1))) DIAGNOSAUTAMA, (master.getKodeDiagnosa(PNOPEN,1)) KODEDIAGNOSAUTAMA
		 , (master.getDiagnosa(PNOPEN,2)) DIAGNOSASEKUNDER, (master.getKodeDiagnosa(PNOPEN,2)) KODEDIAGNOSASEKUNDER
		 , IFNULL((SELECT REPLACE(REPLACE(REPLACE(REPLACE
				 (master.getReplaceFont((pf2.DESKRIPSI))
					,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')
			   FROM medicalrecord.pemeriksaan_fisik pf2
				WHERE pf2.KUNJUNGAN=pk.NOMOR
				ORDER BY pf2.TANGGAL DESC LIMIT 1),(SELECT REPLACE(REPLACE(REPLACE(REPLACE
				 (master.getReplaceFont((pf1.DESKRIPSI))
					,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pd.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1)) FISIK
		, IF(DESKRIPSI_HASIL_PENUNJANG_LAINYA='','Tidak Ada',DESKRIPSI_HASIL_PENUNJANG_LAINYA) DESKRIPSI_HASIL_PENUNJANG_LAINYA
		, IF(kd.ID IN (4,5),'Tidak Ada',IF(RENCANA_DIET='','Tidak Ada',RENCANA_DIET)) RENCANA_DIET
	FROM pendaftaran.pendaftaran pd
	     LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN AND pl.`STATUS`=1
	     LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		 LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
		 LEFT JOIN pendaftaran.kunjungan pk ON pl.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
		 LEFT JOIN medicalrecord.penilaian_nyeri pny ON pk.NOMOR=pny.KUNJUNGAN
		 LEFT JOIN master.referensi mny ON pny.METODE=mny.ID AND mny.JENIS=71
		 LEFT JOIN master.ruangan u ON pk.RUANGAN=u.ID AND u.JENIS=5
		 LEFT JOIN master.dokter dokdpjp ON pl.DOKTER=dokdpjp.ID
		 LEFT JOIN master.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
		 LEFT JOIN master.referensi kd ON pl.KEADAAN=kd.ID AND kd.JENIS=46
		 LEFT JOIN master.referensi ck ON pl.CARA=ck.ID AND ck.JENIS=45
		 LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pd.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
		 LEFT JOIN medicalrecord.`resume` rm ON rm.NOPEN=pd.NOMOR AND rm.`STATUS`!=0
	     LEFT JOIN medicalrecord.anamnesis an ON rm.ANAMNESIS=an.ID AND an.`STATUS`!=0
	     LEFT JOIN medicalrecord.rpp  ON rm.RPP=rpp.ID AND rpp.`STATUS`!=0
	     LEFT JOIN medicalrecord.rps  ON rm.RPS=rps.ID AND rps.`STATUS`!=0
	     LEFT JOIN medicalrecord.keluhan_utama ku  ON rm.KELUHAN_UTAMA=ku.ID AND ku.`STATUS`!=0
	     LEFT JOIN medicalrecord.tanda_vital tv ON rm.TANDA_VITAL=tv.ID AND tv.`STATUS`!=0
	     LEFT JOIN master.referensi rtv ON tv.TINGKAT_KESADARAN=rtv.ID AND rtv.JENIS=179
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
	WHERE pd.NOMOR=PNOPEN AND pd.`STATUS`!=0 AND pd.NORM=p.NORM
		AND pd.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
	GROUP BY pd.NOMOR;

END//
DELIMITER ;