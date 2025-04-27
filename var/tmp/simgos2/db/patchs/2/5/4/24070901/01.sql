USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakTriage
DROP PROCEDURE IF EXISTS `CetakTriage`;
DELIMITER //
CREATE PROCEDURE `CetakTriage`(
	IN `PID` CHAR(10)
)
BEGIN
				SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT ALAMAT_INSTANSI, inst.KOTA KOTA
			  , IFNULL(INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-'),trg.NORM) NORM, pp.NOMOR NOPEN
		     , IFNULL(master.getNamaLengkap(pp.NORM),trg.NAMA) NAMAPASIEN
			  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',rjk.DESKRIPSI,')') TGLLHR
			  , IFNULL(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),DATE_FORMAT(trg.TANGGAL_LAHIR,'%d-%m-%Y')) TANGGAL_LAHIR, IF(wl.ID IS NULL,p.TEMPAT_LAHIR,wl.DESKRIPSI) TEMPATLHR
			  , IFNULL(rjk.DESKRIPSI,tjk.DESKRIPSI) JENIS_KELAMIN
		     , pk.NOMOR KUNJUNGAN
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK
		     , (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=2) KODEMR1
		     , r.DESKRIPSI UNIT
		     , trg.NORM TRG_NORM, trg.NIK TRG_NIK, trg.NAMA TRG_NAMA
		     , trg.TANGGAL_LAHIR TRG_TGL_LAHIR, trg.JENIS_KELAMIN TRG_JK
		     , trg.KEDATANGAN
		     , DATE_FORMAT(JSON_UNQUOTE(trg.KEDATANGAN->'$.TANGGAL'),'%d-%m-%Y') DATANG_TANGGAL
		     , DATE_FORMAT(JSON_UNQUOTE(trg.KEDATANGAN->'$.TANGGAL'),'%H:%m:%i') DATANG_JAM
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.ALAT_TRANSPORTASI') DATANG_ALAT_TRANSPORTASI
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.JENIS') DATANG_JENIS
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.PENGANTAR') DATANG_PENGANTAR
		     , jns_rjk.ID DATANG_ASAL_RUJUKAN
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.SISRUTE') DATANG_SISRUTE
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.KEPOLISIAN') DATANG_KEPOLISIAN
		     , JSON_UNQUOTE(trg.KEDATANGAN->'$.VISUM') DATANG_VISUM
            , trg.KASUS
            , JSON_UNQUOTE(trg.KASUS->'$.JENIS') KASUS_JENIS
            , JSON_UNQUOTE(trg.KASUS->'$.LAKA_LANTAS') KASUS_LAKA_LANTAS
            , JSON_UNQUOTE(trg.KASUS->'$.KECELAKAAN_KERJA') KASUS_KECELAKAAN_KERJA
            , JSON_UNQUOTE(trg.KASUS->'$.UPPA') KASUS_UPPA
            , JSON_UNQUOTE(trg.KASUS->'$.ENDEMIS') KASUS_ENDEMIS
            , JSON_UNQUOTE(trg.KASUS->'$.DIMANA') KASUS_DIMANA
            , trg.ANAMNESE
            , JSON_UNQUOTE(trg.ANAMNESE->'$.KELUHAN_UTAMA') ANAMNESE_KELUHAN_UTAMA
            , JSON_UNQUOTE(trg.ANAMNESE->'$.TERPIMPIN') ANAMNESE_TERPIMPIN
		     , trg.TANDA_VITAL
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.SISTOLE') TV_SISTOLE
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.DIASTOLE') TV_DIASTOLE
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.FREK_NAFAS') TV_FREK_NAFAS
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.FREK_NADI') TV_FREK_NADI
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.SUHU') TV_SUHU
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.SKALA_NYERI') TV_SKALA_NYERI
		     , JSON_UNQUOTE(trg.TANDA_VITAL->'$.METODE_UKUR') TV_METODE_UKUR
			  , trg.OBGYN
			  , JSON_UNQUOTE(trg.OBGYN->'$.USIA_GESTASI') OBG_USIA_GESTASI
			  , JSON_UNQUOTE(trg.OBGYN->'$.DETAK_JANTUNG') OBG_DETAK_JANTUNG
			  , JSON_UNQUOTE(trg.OBGYN->'$.JANIN') OBG_JANIN
			  , JSON_UNQUOTE(trg.OBGYN->'$.KONTRAKSI_UTERUS') OBG_KONTRAKSI_UTERUS
			  , JSON_UNQUOTE(trg.OBGYN->'$.DILATASI_SERVIKS') OBG_DILATASI_SERVIKS
			  , trg.KEBUTUHAN_KHUSUS
			  , IF(JSON_UNQUOTE(trg.KEBUTUHAN_KHUSUS->'$.AIRBONE') = '','',JSON_UNQUOTE(trg.KEBUTUHAN_KHUSUS->'$.AIRBONE')) AIRBORNE
			  , IF(JSON_UNQUOTE(trg.KEBUTUHAN_KHUSUS->'$.DEKONTAMINAN') = '','',JSON_UNQUOTE(trg.KEBUTUHAN_KHUSUS->'$.DEKONTAMINAN')) DEKONTAMINAN
			  , trg.KATEGORI_PEMERIKSAAN, kat_trg.DESKRIPSI DESK_KATEGORI_PEMERIKSAAN
			  , IF(JSON_UNQUOTE(trg.RESUSITASI->'$.CHECKED') = '1',1,0) RESUSITASI
	        , IF(JSON_UNQUOTE(trg.EMERGENCY->'$.CHECKED') = '1',1,0) EMERGENCY
	        , IF(JSON_UNQUOTE(trg.URGENT->'$.CHECKED') = '1',1,0) URGENT
	        , IF(JSON_UNQUOTE(trg.LESS_URGENT->'$.CHECKED') = '1',1,0) LESS_URGENT
	        , IF(JSON_UNQUOTE(trg.NON_URGENT->'$.CHECKED') = '1',1,0)  NON_URGENT
	        , IF(JSON_UNQUOTE(trg.DOA->'$.CHECKED') = '1',1,0) DOA
	        , trg.KRITERIA, trg.HANDOVER, trg.PLAN
	        , DATE_FORMAT(trg.TANGGAL_FINAL,'%d-%m-%Y %H:%i:%s') TANGGAL_FINAL
	        , `master`.getNamaLengkapPegawai(us.NIP) PETUGAS_TRG
		   FROM medicalrecord.triage trg
		   	  LEFT JOIN pendaftaran.kunjungan pk ON trg.KUNJUNGAN = pk.NOMOR
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
			  	  LEFT JOIN master.referensi smf ON ds.SMF=smf.ID AND smf.JENIS=26
				  LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
		        LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
			     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.referensi tjk ON trg.JENIS_KELAMIN=tjk.ID AND tjk.JENIS=2
				  LEFT JOIN master.wilayah wl ON p.TEMPAT_LAHIR=wl.ID
				  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID
				  LEFT JOIN master.referensi kat_trg ON trg.KATEGORI_PEMERIKSAAN=kat_trg.ID AND kat_trg.JENIS=222
				  LEFT JOIN aplikasi.pengguna us ON trg.OLEH=us.ID
				  LEFT JOIN `master`.ppk perujuk ON JSON_UNQUOTE(trg.KEDATANGAN->'$.ASAL_RUJUKAN') = perujuk.ID
				  LEFT JOIN master.referensi jns_rjk ON perujuk.JENIS=jns_rjk.ID AND jns_rjk.JENIS=11	  
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE trg.ID = PID
			  GROUP BY trg.ID;
END//
DELIMITER ;