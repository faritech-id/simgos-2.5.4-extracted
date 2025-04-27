USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CatatanMedik
DROP PROCEDURE IF EXISTS `CatatanMedik`;
DELIMITER //
CREATE PROCEDURE `CatatanMedik`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
SET @sqlText = CONCAT(
	'SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI, inst.PROP
	, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
	, master.getNamaLengkap(p.NORM) NAMALENGKAP
    , master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
    , DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'') TANGGAL_LAHIR
    , master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) UMUR
    , CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),'', '',DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'')) TTL
    , IF((SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
          FROM master.kontak_pasien kp 
          WHERE kp.NORM=p.NORM)='''',p.ALAMAT,CONCAT(p.ALAMAT,'' - ('',(SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
          FROM master.kontak_pasien kp 
          WHERE kp.NORM=p.NORM),'')'')) ALAMAT
    , DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALKUNJUNGAN
    , DATE_FORMAT(pd.TANGGAL,''%H:%i:%s'') JAM
    , if(rjk.DESKRIPSI=''Perempuan'',''P'',''L'') JK
    , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLREG
    , (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=1) KODEMR1
    , master.getNamaLengkapPegawai(dok.NIP) DPJP
    , CONCAT(rr.DESKRIPSI,'' / '',rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR
    , CONCAT(IF(dm.DIAGNOSA is NULL,'''',dm.DIAGNOSA), IF(dm.ICD is NULL,'''',CONCAT(''('',dm.ICD,'')''))) DIAGNOSAMASUK
    , CONCAT(DATEDIFF(plg.TANGGAL,pk.MASUK),'' hari'') LOS
    , CONCAT( UPPER((master.getDiagnosaMR1(pd.NOMOR,1)))) DIAGNOSAUTAMA
	 , CONCAT((master.getDiagnosaMR1(pd.NOMOR,2))) DIAGNOSASEKUNDER
	 , kip.NOMOR KTP
  FROM master.pasien p
      LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
    , pendaftaran.pendaftaran pd
      LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
      LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
      LEFT JOIN master.diagnosa_masuk dm on pd.DIAGNOSA_MASUK=dm.ID
      LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=pd.NOMOR
      LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
      LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
      LEFT JOIN master.referensi sm ON sm.ID=tp.SMF AND sm.JENIS=26
      LEFT JOIN layanan.pasien_pulang plg on pd.NOMOR=plg.NOPEN
      LEFT JOIN master.kartu_identitas_pasien kip ON kip.NORM=pd.NORM AND kip.JENIS=1
    , pendaftaran.kunjungan pk
      LEFT JOIN master.ruangan rr ON pk.RUANGAN=rr.ID AND rr.JENIS=5
      LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
      LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
      LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
    , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT,IF(w.DESKRIPSI IS NULL,wp.DESKRIPSI,CONCAT(w.DESKRIPSI,'' - '',wp.DESKRIPSI)) PROP
          FROM aplikasi.instansi ai
            , master.ppk mp
              LEFT JOIN master.wilayah w ON LEFT(mp.WILAYAH,4)=w.ID
              LEFT JOIN master.wilayah wp ON LEFT(mp.WILAYAH,2)=wp.ID
          WHERE ai.PPK=mp.ID 
          LIMIT 1) inst
  WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=''',PNOPEN,''' AND pd.NOMOR=pk.NOPEN AND pd.STATUS!=0 AND pk.STATUS!=0 
   	',IF(PKUNJUNGAN = 0,CONCAT(' AND pk.REF IS NULL' ) ,'' ),'
		',IF(PKUNJUNGAN = 0,'' , CONCAT(' AND pk.NOMOR =''',PKUNJUNGAN,'''' )),' 
  ');
	
 
  PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakAsuhanKeperawatan
DROP PROCEDURE IF EXISTS `CetakAsuhanKeperawatan`;
DELIMITER //
CREATE PROCEDURE `CetakAsuhanKeperawatan`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT pd.NORM, k.NOPEN, k.NOMOR KUNJUNGAN 
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, sbj.SUBJECKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.SUBJECKTIF,
				         "$[*]"
				         COLUMNS(
				           SUBJECKTIF VARCHAR(250) PATH "$"
				         )
				       ) sbj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON sbj.SUBJECKTIF=ik.ID AND ik.JENIS=1
				WHERE kp.KUNJUNGAN=k.NOMOR),'') SUBJEKTIF
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obj.OBJEKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBJEKTIF,
				         "$[*]"
				         COLUMNS(
				           OBJEKTIF VARCHAR(250) PATH "$"
				         )
				       ) obj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obj.OBJEKTIF=ik.ID AND ik.JENIS=2
				WHERE kp.KUNJUNGAN=k.NOMOR),'') OBJEKTIF
			, IFNULL(dk.DESKRIPSI,'') DIAGNOSA_KEPERAWATAN
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, pyb.PENYEBAB) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.PENYEBAP,
				         "$[*]"
				         COLUMNS(
				           PENYEBAB VARCHAR(250) PATH "$"
				         )
				       ) pyb
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON pyb.PENYEBAB=ik.ID AND ik.JENIS=3
				WHERE kp.KUNJUNGAN=k.NOMOR),'') PENYEBAB
			, IFNULL(tj.DESKRIPSI,'') TUJUAN
			, IFNULL(iv.DESKRIPSI,'') INTERVENSI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR),'') OBSERVASI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR),'') THEURAPEUTIC
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR),'') EDUKASI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR),'') KOLABORASI
			 , CONCAT('INTERVENSI : ',IFNULL(iv.DESKRIPSI,''),'\r',
			 	'OBSERVASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',				
				'THEURAPEUTIC : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',				
				'EDUKASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',
			 	'KOLABORASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR),'')) RENCANA
		FROM pendaftaran.kunjungan k
		     , medicalrecord.asuhan_keperawatan ak 
		     LEFT JOIN medicalrecord.diagnosa_keperawatan dk ON ak.DIAGNOSA=dk.ID
		     LEFT JOIN medicalrecord.indikator_keperawatan tj ON ak.TUJUAN=tj.ID AND tj.JENIS=4
		     LEFT JOIN medicalrecord.indikator_keperawatan iv ON ak.INTERVENSI=iv.ID AND iv.JENIS=5
			, pendaftaran.pendaftaran pd
		WHERE pd.NOMOR=PNOPEN AND k.NOPEN=pd.NOMOR AND k.`STATUS`!=0 AND pd.`STATUS`!=0
			AND k.NOMOR=ak.KUNJUNGAN AND ak.`STATUS`!=0
		ORDER BY ak.TANGGAL ASC
		LIMIT 1
		;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakBarthelIndex
DROP PROCEDURE IF EXISTS `CetakBarthelIndex`;
DELIMITER //
CREATE PROCEDURE `CetakBarthelIndex`(
	IN `PNOPEN` CHAR(10)
)
BEGIN 	
	SET @brs=0;
SELECT @brs:=@brs+1 BARIS, NORM, NAMA_PASIEN, TANGGAL_LAHIR, JENIS_KELAMIN, KUNJUNGAN, RUANGAN, PENDAFTARAN
		, IF(@brs=1, 'Sebelum Sakit', IF(@brs=2, 'Saat Masuk RS', DATE_FORMAT(TANGGAL,'%d-%m-%Y'))) TANGGAL
		, KENDALI_RANGSANG_DEFEKASI, KET_KENDALI_RANGSANG_DEFEKASI
		, KENDALI_RANGSANG_KEMIH, KET_KENDALI_RANGSANG_KEMIH
		, BERSIH_DIRI, KET_BERSIH_DIRI
		, PENGGUNAAN_JAMBAN, KET_PENGGUNAAN_JAMBAN
		, MAKAN, KET_MAKAN
		, PERUBAHAN_SIKAP, KET_PERUBAHAN_SIKAP
		, PINDAH_JALAN, KET_PINDAH_JALAN
		, PAKAI_BAJU, KET_PAKAI_BAJU
		, NAIK_TURUN_TANGGA, KET_NAIK_TURUN_TANGGA
		, MANDI, KET_MANDI
		, @TOTAL:=(KENDALI_RANGSANG_DEFEKASI+KENDALI_RANGSANG_KEMIH+BERSIH_DIRI+PENGGUNAAN_JAMBAN+MAKAN+PERUBAHAN_SIKAP+PINDAH_JALAN+PAKAI_BAJU+NAIK_TURUN_TANGGA+MANDI) TOTAL
		, IF(@TOTAL>125,'Mandiri',IF(@TOTAL>64,'Ketergantungan sebagian','Ketergantungan Total')) KETERANGAN
		, PETUGAS, IDPETUGAS
	FROM (
SELECT p.NORM, `master`.getNamaLengkap(pd.NORM) NAMA_PASIEN, p.TANGGAL_LAHIR, IF(p.JENIS_KELAMIN=1,'Laki-Laki','Perempuan') JENIS_KELAMIN
		, bi.KUNJUNGAN, r.DESKRIPSI RUANGAN, bi.PENDAFTARAN
	   ,  DATE_FORMAT(bi.TANGGAL,'%d-%m-%Y') TANGGAL
		,  IFNULL(krd.SCORING,0) KENDALI_RANGSANG_DEFEKASI
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=232) KET_KENDALI_RANGSANG_DEFEKASI
		, IFNULL(krk.SCORING,0) KENDALI_RANGSANG_KEMIH
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=233) KET_KENDALI_RANGSANG_KEMIH
		, IFNULL(bd.SCORING,0) BERSIH_DIRI
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=234) KET_BERSIH_DIRI
		, IFNULL(pj.SCORING,0) PENGGUNAAN_JAMBAN
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=235) KET_PENGGUNAAN_JAMBAN
		, IFNULL(mk.SCORING,0) MAKAN
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=236) KET_MAKAN
		, IFNULL(ps.SCORING,0) PERUBAHAN_SIKAP
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=237) KET_PERUBAHAN_SIKAP
		, IFNULL(jl.SCORING,0) PINDAH_JALAN
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=238) KET_PINDAH_JALAN
		, IFNULL(pb.SCORING,0) PAKAI_BAJU
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=239) KET_PAKAI_BAJU
		, IFNULL(tr.SCORING,0) NAIK_TURUN_TANGGA
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=239) KET_NAIK_TURUN_TANGGA
		, IFNULL(mn.SCORING,0) MANDI
		, (SELECT REPLACE(GROUP_CONCAT(CONCAT(f.SCORING,'=',f.DESKRIPSI) SEPARATOR ';'),';','\r') FROM `master`.referensi f WHERE f.JENIS=239) KET_MANDI
		, `master`.getNamaLengkapPegawai(pg.NIP) PETUGAS, pg.ID IDPETUGAS
	FROM medicalrecord.penilaian_barthel_index bi
	     LEFT JOIN aplikasi.pengguna pg ON bi.OLEH=pg.ID
	     LEFT JOIN `master`.referensi krd ON krd.JENIS=232 AND bi.KENDALI_RANGSANG_DEFEKASI=krd.ID
	     LEFT JOIN `master`.referensi krk ON krk.JENIS=233 AND bi.KENDALI_RANGSANG_KEMIH=krk.ID
	     LEFT JOIN `master`.referensi bd ON bd.JENIS=234 AND bi.BERSIH_DIRI=bd.ID
	     LEFT JOIN `master`.referensi pj ON pj.JENIS=235 AND bi.PENGGUNAAN_JAMBAN=pj.ID
	     LEFT JOIN `master`.referensi mk ON mk.JENIS=236 AND bi.MAKAN=mk.ID
	     LEFT JOIN `master`.referensi ps ON ps.JENIS=237 AND bi.PERUBAHAN_SIKAP=ps.ID
	     LEFT JOIN `master`.referensi jl ON jl.JENIS=238 AND bi.PINDAH_JALAN=jl.ID
	     LEFT JOIN `master`.referensi pb ON pb.JENIS=239 AND bi.PAKAI_BAJU=pb.ID
	     LEFT JOIN `master`.referensi tr ON tr.JENIS=240 AND bi.NAIK_TURUN_TANGGA=tr.ID 
	     LEFT JOIN `master`.referensi mn ON mn.JENIS=241 AND bi.MANDI=mn.ID
		, pendaftaran.kunjungan k
		, `master`.ruangan r
		, pendaftaran.pendaftaran pd
		, `master`.pasien p
	WHERE pd.NOMOR=PNOPEN AND bi.`STATUS`!=0
	  AND bi.KUNJUNGAN=k.NOMOR AND k.`STATUS`!=0
	  AND k.NOPEN=pd.NOMOR AND pd.`STATUS`!=0
	  AND k.RUANGAN=r.ID AND pd.NORM=p.NORM
	ORDER BY bi.SEBELUM_SAKIT DESC, bi.TANGGAL ASC
) ab;

END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakCPPT
DROP PROCEDURE IF EXISTS `CetakCPPT`;
DELIMITER //
CREATE PROCEDURE `CetakCPPT`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
  SET @sqlText = CONCAT(
			'SELECT CONCAT(DATE_FORMAT(cp.TANGGAL,''%d-%m-%Y''), '' \r'', TIME(cp.TANGGAL)) TANGGAL
		,CONCAT(''S/: '', cp.SUBYEKTIF,'' \r'',''O/: '',  cp.OBYEKTIF,'' \r'',''A/: '',  cp.ASSESMENT,'' \r'',''P/: '',  cp.PLANNING) CATATAN
		, IF(ref.REF_ID = "4", master.getNamaLengkapPegawai(d.NIP),'''') DOKTER
		, IF(ref.REF_ID = "6", master.getNamaLengkapPegawai(pr.NIP),IF(ref.REF_ID NOT IN ("6","4"), master.getNamaLengkapPegawai(p.NIP),'''')) PERAWAT
		, cp.INSTRUKSI
		, ref.DESKRIPSI JNSPPA
		, CONCAT(IF(ref.REF_ID = "4", master.getNamaLengkapPegawai(d.NIP), IF(ref.REF_ID = "6", master.getNamaLengkapPegawai(pr.NIP)
			, IF(ref.REF_ID NOT IN ("6","4"), master.getNamaLengkapPegawai(p.NIP),""))),'' \r'',IF(cp.STATUS_TBAK_SBAR=1,IF(cp.INSTRUKSI='''',''( SBAR )'',''( TBAK )''),'''')) PPA
		, CONCAT(DATE_FORMAT(vcp.TANGGAL,''%d-%m-%Y''), '' \r'', TIME(vcp.TANGGAL)) TGLVERIFIKASI
		, master.getNamaLengkapPegawai(vr.NIP) VERIFIKATOR
		, CONCAT(master.getNamaLengkapPegawai(vr.NIP),'' \r'',DATE_FORMAT(vcp.TANGGAL,''%d-%m-%Y''), '' \r'', TIME(vcp.TANGGAL)) VERIFIKASI
		, IF(cp.STATUS_TBAK_SBAR=1,IF(cp.INSTRUKSI='''',''SBAR'',''TBAK''),'''') TBAK_SBAR
		FROM medicalrecord.cppt cp
		  LEFT JOIN master.referensi ref ON cp.JENIS = ref.ID AND ref.JENIS = 32
		  LEFT JOIN master.pegawai p ON cp.TENAGA_MEDIS=p.ID
		  LEFT JOIN master.dokter d ON cp.TENAGA_MEDIS=d.ID
		  LEFT JOIN master.perawat pr ON cp.TENAGA_MEDIS=pr.ID
		  LEFT JOIN medicalrecord.verifikasi_cppt vcp ON cp.VERIFIKASI=vcp.ID
		  LEFT JOIN aplikasi.pengguna vr ON vcp.OLEH = vr.ID
	     , pendaftaran.kunjungan pk
		 WHERE cp.KUNJUNGAN=pk.NOMOR AND pk.STATUS!=0 AND cp.`STATUS`!=0	AND pk.NOPEN=''',PNOPEN,'''
		 ',IF(PKUNJUNGAN = 0 OR PKUNJUNGAN = '''','' , CONCAT(' AND cp.KUNJUNGAN =''',PKUNJUNGAN,'''' )),' 
		  ORDER BY cp.TANGGAL
		  
		  ');
			
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakHasilEEG
DROP PROCEDURE IF EXISTS `CetakHasilEEG`;
DELIMITER //
CREATE PROCEDURE `CetakHasilEEG`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT INST.*
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT, DATE_FORMAT(eeg.TANGGAL_INPUT, '%d-%m-%Y %H:%i:%s') TGLPEREKAMAN, eeg.KUNJUNGAN
	  , eeg.HASIL, eeg.HASIL_SEBELUMNYA, eeg.MRI_KEPALA, eeg.HASIL_PEREKAMAN, eeg.KESIMPULAN, eeg.SARAN
	  , master.getNamaLengkapPegawai(md.NIP) DPJP, md.NIP
	FROM medicalrecord.pemeriksaan_eeg eeg
		 LEFT JOIN pendaftaran.kunjungan pkj ON eeg.KUNJUNGAN=pkj.NOMOR
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	  , master.pasien p
	    LEFT JOIN master.kontak_pasien kp ON p.NORM = kp.NORM
	  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE eeg.KUNJUNGAN=PKUNJUNGAN 
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY eeg.KUNJUNGAN;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakHasilEMG
DROP PROCEDURE IF EXISTS `CetakHasilEMG`;
DELIMITER //
CREATE PROCEDURE `CetakHasilEMG`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
SELECT INST.*
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT
	  , emg.KELUHAN
	  , emg.PENGOBATAN
	  , CONCAT(emg.TD, ' mmhg') TD 
	  , CONCAT(emg.RR, ' kali/menit') RR
	  , CONCAT(emg.HR, ' kali/menit') HR
	  , CONCAT(emg.DERAJAT_CELCIUS, ' ''C') SUHU
	  , emg.GCS
	  , emg.NPRS
	  , emg.FKL
	  , CONCAT(emg.NN_CRANIALIS, ' mm ODS') NN_CRANIALIS 
	  , CONCAT(emg.RCT_RCTL, ' ODS') RCT_RCTL 
	  , emg.NN_CR_LAIN
	  , emg.MOTORIK, emg.PERGERAKAN, emg.KEKUATAN, emg.EXTREMITAS_SUPERIOR, emg.EXTREMITAS_INFERIOR, emg.TONUS, emg.REFLEKS_FISOLOGIS
	  , emg.REFLEKS_PATOLOGIS, emg.SENSORIK, emg.OTONOM, emg.NVC_AND_EMG_FINDINGS, emg.IMPRESSION, emg.DIBUAT_TANGGAL, emg.OLEH
	  , `master`.getNamaLengkapPegawai(demg.NIP) DOKTER, demg.NIP
	  , CONCAT(n.TINGGI_BADAN, ' cm') TINGGI_BADAN, CONCAT(n.BERAT_BADAN, ' kg') BERAT_BADAN
	FROM medicalrecord.pemeriksaan_emg emg		 
		 LEFT JOIN pendaftaran.kunjungan pkj ON emg.KUNJUNGAN=pkj.NOMOR
		 LEFT JOIN `master`.dokter demg ON pkj.DPJP = demg.ID
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	    LEFT JOIN medicalrecord.nutrisi n ON pk.NOMOR=n.KUNJUNGAN
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	  , master.pasien p
	    LEFT JOIN master.kontak_pasien kp ON p.NORM = kp.NORM
	  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE emg.KUNJUNGAN=PKUNJUNGAN 
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY emg.KUNJUNGAN;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakLapOperasi
DROP PROCEDURE IF EXISTS `CetakLapOperasi`;
DELIMITER //
CREATE PROCEDURE `CetakLapOperasi`(
	IN `PID` INT
)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI,LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
			, IFNULL(pg.NIP,mpdok.NIP) NIP, r.ID IDRUANG
			, CONCAT('Bagian/SMF : ',r.DESKRIPSI,' / ',IFNULL(smf1.DESKRIPSI,smf.DESKRIPSI)) SMF
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 1),master.getNamaLengkapPegawai(mpdok.NIP)) DOKTEROPERATOR
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 2),op.ASISTEN_DOKTER) ASISTEN_DOKTER
			, master.`getPelaksanaOperasi`(op.ID, 3) DRPERFUSI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 4),master.getNamaLengkapPegawai(mpanas.NIP)) DOKTERANASTESI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 5),op.ASISTEN_ANASTESI) ASISTEN_ANASTESI
			, master.`getPelaksanaOperasi`(op.ID, 6) PENATA
			, master.`getPelaksanaOperasi`(op.ID, 7) SCRUB
			, master.`getPelaksanaOperasi`(op.ID, 8) SIRKULER
			, master.`getPelaksanaOperasi`(op.ID, 9) PERFUSI
			, master.`getPelaksanaOperasi`(op.ID, 10) DRTAMU
			, master.`getPelaksanaOperasi`(op.ID, 11) RADIOGRAFER
			, ja.DESKRIPSI JENISANASTESI, gol.DESKRIPSI GOLONGANOPERASI, jop.DESKRIPSI JENISOPERASI
			, IF(op.PA=1,'Ya','Tidak') PEMERIKSAANPA
			, DATE_FORMAT(op.TANGGAL,'%d-%m-%Y') TGLOPERASI
			, DATE_FORMAT(op.DIBUAT_TANGGAL,'%d-%m-%Y') DBUATTANGGAL
			, pk.NOPEN, pk.MASUK TGLREG,  r.DESKRIPSI UNITPENGANTAR
			, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=3 AND jbr.ID=4) KODEMR1
			, op.*, rt.DESKRIPSI JNSTRANSFUSI
			, REPLACE(op.PRA_BEDAH,'<div>','<br><div>') PRA_BEDAH1
			, REPLACE(op.PASCA_BEDAH,'<div>','<br><div>') PASCA_BEDAH1
			, REPLACE(REPLACE(op.LAPORAN_OPERASI,'<div>','<br><div>'),'<p','<br><p') LAPORAN_OPERASI1
			, IF(op.JUMLAH_TRANSFUSI=0,'Tidak ada',CONCAT(REPLACE(ROUND(op.JUMLAH_TRANSFUSI,2),'.',','),' Mililiter')) JML_TRANSFUSI
		FROM medicalrecord.operasi op
			  LEFT JOIN master.dokter dok ON op.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
			  LEFT JOIN master.dokter_smf dsmf ON dok.ID=dsmf.DOKTER
			  LEFT JOIN master.referensi smf ON dsmf.SMF=smf.ID AND smf.JENIS=26
			  LEFT JOIN master.dokter anas ON op.ANASTESI=anas.ID
			  LEFT JOIN master.pegawai mpanas ON anas.NIP=mpanas.NIP
			  LEFT JOIN master.referensi ja ON op.JENIS_ANASTESI=ja.ID AND ja.JENIS=52
			  LEFT JOIN master.referensi gol ON op.GOLONGAN_OPERASI=gol.ID AND gol.JENIS=53
			  LEFT JOIN master.referensi jop ON op.JENIS_OPERASI=jop.ID AND jop.JENIS=87
			  LEFT JOIN master.referensi rt ON op.JENIS_TRANSFUSI=rt.ID AND rt.JENIS=213
			  LEFT JOIN medicalrecord.pelaksana_operasi po ON po.OPERASI_ID=op.ID AND po.JENIS=1 AND po.`STATUS`=1
		     LEFT JOIN master.pegawai pg ON po.PELAKSANA=pg.ID
		     LEFT JOIN master.referensi smf1 ON pg.SMF=smf1.ID AND smf1.JENIS=26
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN pendaftaran.konsul ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan rasal ON kj.RUANGAN=rasal.ID AND rasal.JENIS=5
			  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT mp.NAMA, ai.PPK  
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND op.KUNJUNGAN=pk.NOMOR AND op.`STATUS` IN (1, 2)
		AND op.ID=PID
	GROUP BY op.ID;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR2
DROP PROCEDURE IF EXISTS `CetakMR2`;
DELIMITER //
CREATE PROCEDURE `CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
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
				LIMIT 1))) anamnesis	
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
		 , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pd.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1) FISIK
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

-- Dumping structure for procedure medicalrecord.CetakMR2Diagnosa
DROP PROCEDURE IF EXISTS `CetakMR2Diagnosa`;
DELIMITER //
CREATE PROCEDURE `CetakMR2Diagnosa`(
	IN `PNOPEN` CHAR(10),
	IN `PUTAMA` TINYINT
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_PROSEDUR;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_FARMASI;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_FARMASI_TEMP;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_ALL;
	
   SET @id=0;
	SET @idd=0;
	SET @idf=0;
	SET @iddf=0;
	
	SET @id1=0;
	SET @idd1=0;
	SET @idf1=0;
	SET @iddf1=0;
	
	SET @idg=0;
	
	
	CREATE TEMPORARY TABLE TEMP_DATA ENGINE=MEMORY
	SELECT NOPEN, BARIS, IDDIAGNOSA
		FROM (
		SELECT r.NOPEN, IF(@idd1!=jt.ID,@id1:=1, @id1:=@id1+1) BARIS, @idd1:=jt.ID  IDDIAGNOSA, jt.UTAMA
			  FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
			         '$[*]' COLUMNS(
			                ID INT(10) PATH '$.ID',
			                UTAMA TINYINT(4) PATH '$.UTAMA',
			                NESTED PATH '$.PROSEDUR[*]' 
								 COLUMNS (
			                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
			                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
								  )
			            )   
			       ) AS jt
			WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		UNION ALL
		SELECT r.NOPEN, IF(@iddf1!=jt.ID,@idf1:=1, @idf1:=@idf1+1) BARIS, @iddf1:=jt.ID  IDDIAGNOSA, jt.UTAMA
				     FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_FARMASI,
					         '$[*]' COLUMNS(
					                ID INT(10) PATH '$.ID',
			                		 UTAMA TINYINT(4) PATH '$.UTAMA',
					                NESTED PATH '$.FARMASI[*]' 
										 COLUMNS (
					                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
					                )
					            )   
					       ) AS jt
		   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		) cd
		GROUP BY IDDIAGNOSA, BARIS;
	
	ALTER TABLE TEMP_DATA 
	   CHANGE COLUMN NOPEN NOPEN CHAR(10) NOT NULL,
	   CHANGE COLUMN BARIS BARIS SMALLINT(4) NOT NULL,
		CHANGE COLUMN IDDIAGNOSA IDDIAGNOSA INT(11) NOT NULL,
	   ADD INDEX(NOPEN, BARIS, IDDIAGNOSA);
			
	CREATE TEMPORARY TABLE TEMP_DATA_ALL ENGINE=MEMORY
	SELECT NOPEN, IDDIAGNOSA
		FROM (
		SELECT r.NOPEN, jt.ID  IDDIAGNOSA, jt.UTAMA
			  FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
			         '$[*]' COLUMNS(
			                ID INT(10) PATH '$.ID',
			                UTAMA TINYINT(4) PATH '$.UTAMA',
			                NESTED PATH '$.PROSEDUR[*]' 
								 COLUMNS (
			                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
			                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
								  )
			            )   
			       ) AS jt
			WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		UNION ALL
		SELECT r.NOPEN,  jt.ID  IDDIAGNOSA, jt.UTAMA
				     FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_FARMASI,
					         '$[*]' COLUMNS(
					                ID INT(10) PATH '$.ID',
			                		 UTAMA TINYINT(4) PATH '$.UTAMA',
					                NESTED PATH '$.FARMASI[*]' 
										 COLUMNS (
					                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
					                )
					            )   
					       ) AS jt
		   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		) cd
		GROUP BY IDDIAGNOSA;
	
	ALTER TABLE TEMP_DATA_ALL
		CHANGE COLUMN NOPEN NOPEN CHAR(10) NOT NULL,
	   CHANGE COLUMN IDDIAGNOSA IDDIAGNOSA INT(11) NOT NULL,
	   ADD INDEX(NOPEN, IDDIAGNOSA);
			
	CREATE TEMPORARY TABLE TEMP_DATA_PROSEDUR ENGINE=MEMORY
   SELECT r.NOPEN, IF(@idd!=jt.ID,@id:=1, @id:=@id+1) BARIS, @idd:=jt.ID  IDDIAGNOSA, jt.UTAMA UTAMA, jt.TINDAKANMEDIS, jt.IDPROSEDUR
	  FROM medicalrecord.`resume` r, 
	        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
	         '$[*]' COLUMNS(
	                ID INT(10) PATH '$.ID',
			          UTAMA TINYINT(4) PATH '$.UTAMA',
	                NESTED PATH '$.PROSEDUR[*]' 
						 COLUMNS (
	                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
	                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
						  )
	            )   
	       ) AS jt
	WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA;
	
	ALTER TABLE TEMP_DATA_PROSEDUR
	   CHANGE COLUMN NOPEN NOPEN CHAR(10) NOT NULL,
	   CHANGE COLUMN BARIS BARIS SMALLINT(4) NOT NULL,
		CHANGE COLUMN IDDIAGNOSA IDDIAGNOSA INT(11) NOT NULL,
		CHANGE COLUMN TINDAKANMEDIS TINDAKANMEDIS CHAR(11) NOT NULL,
	   ADD INDEX(NOPEN, BARIS, IDDIAGNOSA,TINDAKANMEDIS, IDPROSEDUR);
	   
   CREATE TEMPORARY TABLE TEMP_DATA_FARMASI ENGINE=MEMORY
   SELECT r.NOPEN, jt.ID  IDDIAGNOSA, jt.UTAMA UTAMA, jt.IDFARMASI
		     FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_FARMASI,
			         '$[*]' COLUMNS(
			                ID INT(10) PATH '$.ID',
			                UTAMA TINYINT(4) PATH '$.UTAMA',
			                NESTED PATH '$.FARMASI[*]' 
								 COLUMNS (
			                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
			                )
			            )   
			       ) AS jt
   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA;
	
	ALTER TABLE TEMP_DATA_FARMASI
	   CHANGE COLUMN NOPEN NOPEN CHAR(10) NOT NULL,
	  	CHANGE COLUMN IDFARMASI IDFARMASI CHAR(11) NOT NULL,
		CHANGE COLUMN IDDIAGNOSA IDDIAGNOSA INT(11) NOT NULL,
	   ADD INDEX(NOPEN, IDDIAGNOSA, IDFARMASI);
	
	CREATE TEMPORARY TABLE TEMP_DATA_FARMASI_TEMP ENGINE=MEMORY
   SELECT NOPEN, IF(@iddf!=ef.IDDIAGNOSA,@idf:=1, @idf:=@idf+1) BARIS, @iddf:=ef.IDDIAGNOSA  IDDIAGNOSA, ef.UTAMA UTAMA, ef.IDFARMASI, ef.NAMABARANG
	FROM (SELECT fr.NOPEN, fr.IDDIAGNOSA, fr.UTAMA, fr.IDFARMASI, ib.NAMA NAMABARANG	     
				FROM TEMP_DATA_FARMASI fr
		           LEFT JOIN layanan.farmasi f ON fr.IDFARMASI=f.ID AND f.`STATUS`!=0
					  LEFT JOIN inventory.barang ib ON f.FARMASI=ib.ID
   			WHERE fr.NOPEN=PNOPEN AND fr.UTAMA=PUTAMA
				GROUP BY fr.IDDIAGNOSA, ib.ID
			) ef;
	
	ALTER TABLE TEMP_DATA_FARMASI_TEMP
	   CHANGE COLUMN NOPEN NOPEN CHAR(10) NOT NULL,
	   CHANGE COLUMN BARIS BARIS SMALLINT(4) NOT NULL,
		CHANGE COLUMN IDFARMASI IDFARMASI CHAR(11) NOT NULL,
		CHANGE COLUMN IDDIAGNOSA IDDIAGNOSA INT(11) NOT NULL,
	   ADD INDEX(NOPEN, BARIS, IDDIAGNOSA, IDFARMASI);
		   
			SELECT *
				FROM (
		  	SELECT NOPEN, BARIS, TINDAKANMEDIS, IDPROSEDUR, IDFARMASI
							, IF(@idg!=IDDIAGNOSA,KODE_DIAGNOSA, '') KODE_DIAGNOSA
							, IF(@idg!=IDDIAGNOSA,DESKRIPSI_DIAGNOSA,'') DESKRIPSI_DIAGNOSA, @idg:=IDDIAGNOSA IDDIAGNOSA, DIAGNOSA
							, NAMATINDAKAN, KODE_PROSEDUR, DESKRIPSI_PROSEDUR,  NAMABARANG
							
						FROM (
							SELECT d.NOPEN,  d.BARIS, p.TINDAKANMEDIS, p.IDPROSEDUR, frs.IDFARMASI
											, dg.KODE KODE_DIAGNOSA
											, `master`.getDeskripsiICD(dg.KODE)  DESKRIPSI_DIAGNOSA
											, d.IDDIAGNOSA IDDIAGNOSA
											, dg.DIAGNOSA
											, t.NAMA NAMATINDAKAN, pr.KODE KODE_PROSEDUR, `master`.getDeskripsiICD(pr.KODE) DESKRIPSI_PROSEDUR
											, frs.NAMABARANG
									  FROM TEMP_DATA d
											 LEFT JOIN TEMP_DATA_PROSEDUR p ON d.NOPEN=p.NOPEN AND d.IDDIAGNOSA=p.IDDIAGNOSA AND d.BARIS=p.BARIS
											 LEFT JOIN TEMP_DATA_FARMASI_TEMP frs ON d.NOPEN=frs.NOPEN AND d.IDDIAGNOSA=frs.IDDIAGNOSA AND d.BARIS=frs.BARIS
											 LEFT JOIN layanan.tindakan_medis tm ON p.TINDAKANMEDIS=tm.ID AND tm.`STATUS`!=0
										    LEFT JOIN `master`.tindakan t ON tm.TINDAKAN=t.ID
										    LEFT JOIN medicalrecord.prosedur pr ON p.IDPROSEDUR=pr.ID AND pr.`STATUS`!=0 AND pr.INA_GROUPER=0
										    , medicalrecord.diagnosa dg
									WHERE d.IDDIAGNOSA=dg.ID AND d.NOPEN=dg.NOPEN AND dg.`STATUS`!=0 AND dg.INA_GROUPER=0 AND dg.NOPEN=PNOPEN AND dg.UTAMA=PUTAMA AND dg.INACBG=1
									ORDER BY IDDIAGNOSA, BARIS
							) ab 
			UNION ALL
				SELECT ds.NOPEN, 1 BARIS, null TINDAKAMEDIS, null IDPROSEDUR, null IDFARMASI, ds.KODE KODE_DIAGNOSA
					, `master`.getDeskripsiICD(ds.KODE)  DESKRIPSI_DIAGNOSA, ds.ID IDDIAGNOSA, ds.DIAGNOSA
					, null NAMATINDAKAN, null KODE_PROSEDUR, null DESKRIPSI_PROSEDUR, null NAMABARANG
					FROM medicalrecord.diagnosa ds
					WHERE ds.NOPEN=PNOPEN AND ds.UTAMA=PUTAMA AND ds.`STATUS`!=0 AND ds.INA_GROUPER=0 AND ds.INACBG=1
					AND ds.ID NOT IN (SELECT IDDIAGNOSA FROM TEMP_DATA_ALL WHERE IDDIAGNOSA=ds.ID)
	
				) cd
		WHERE KODE_DIAGNOSA!='' OR NAMATINDAKAN IS NOT NULL OR NAMABARANG IS NOT NULL
	
		;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR2Obat
DROP PROCEDURE IF EXISTS `CetakMR2Obat`;
DELIMITER //
CREATE PROCEDURE `CetakMR2Obat`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT  pk.NOPEN, ib.NAMA NAMAOBAT, lf.JUMLAH, f.FREKUENSI, lf.DOSIS
		, lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
		FROM layanan.farmasi lf
			  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
			  LEFT JOIN master.frekuensi_aturan_resep f ON lf.FREKUENSI=f.ID AND f.`STATUS`!=0
			, pendaftaran.kunjungan pk
		     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
		     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
			  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
			  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
		     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
		   , pendaftaran.pendaftaran pp
			  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
			, inventory.barang ib
			, pembayaran.rincian_tagihan rt
		WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
			AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG=1
			AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'
		ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR2ProsedurLain
DROP PROCEDURE IF EXISTS `CetakMR2ProsedurLain`;
DELIMITER //
CREATE PROCEDURE `CetakMR2ProsedurLain`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_PROSEDUR;
	CREATE TEMPORARY TABLE TEMP_DATA_PROSEDUR ENGINE=MEMORY
    SELECT r.NOPEN, jt.IDPROSEDUR
        FROM medicalrecord.`resume` r, 
                JSON_TABLE(r.DIAGNOSA_PROSEDUR,
                '$[*]' COLUMNS(
                        ID INT PATH '$.ID',
                        UTAMA INT PATH '$.UTAMA',
                        NESTED PATH '$.PROSEDUR[*]' 
                            COLUMNS (
                            IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR'
                            )
                    )   
            ) AS jt
        WHERE r.NOPEN=PNOPEN;

	SELECT pr.NOPEN,  pr.KODE KODE_PROSEDUR, IFNULL(`master`.getDeskripsiICD(pr.KODE),pr.TINDAKAN) DESKRIPSI_PROSEDUR
		FROM medicalrecord.prosedur pr
			 LEFT JOIN TEMP_DATA_PROSEDUR p ON pr.NOPEN=p.NOPEN AND pr.ID=p.IDPROSEDUR
	WHERE pr.`STATUS`!=0 AND pr.INA_GROUPER=0 AND pr.NOPEN=PNOPEN AND p.IDPROSEDUR IS NULL AND pr.INACBG=1 ;	 	
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR4
DROP PROCEDURE IF EXISTS `CetakMR4`;
DELIMITER //
CREATE PROCEDURE `CetakMR4`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
		SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, pp.NOMOR NOPEN
		     , master.getNamaLengkap(pp.NORM) NAMAPASIEN, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR , rjk.DESKRIPSI JENISKELAMIN
		     , pk.NOMOR KUNJUNGAN, p.ALAMAT ALAMATPASIEN, ref.DESKRIPSI CARABAYAR, rsk.DESKRIPSI STATUSKAWIN 
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK, rpd.DESKRIPSI PENDIDIKAN, rag.DESKRIPSI AGAMA
		     , r.DESKRIPSI UNIT, an.DESKRIPSI ANAMNESIS
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
				   FROM medicalrecord.penilaian_fisik pf1
					WHERE pf1.KUNJUNGAN=pk.NOMOR
					ORDER BY pf1.TANGGAL DESC LIMIT 1) NILAIFISIK
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
				   FROM medicalrecord.pemeriksaan_fisik pf1
					WHERE pf1.KUNJUNGAN=pk.NOMOR
					ORDER BY pf1.TANGGAL DESC LIMIT 1) FISIK
		     , IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				   FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOMOR=pk.NOMOR AND pku.REF IS NULL LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
					FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOMOR=pk.NOMOR AND pku.REF IS NULL LIMIT 1))) KELUHAN
		     , tv.KEADAAN_UMUM, CONCAT(tv.SISTOLIK,'/', tv.DISTOLIK) DARAH, tv.FREKUENSI_NADI, tv.FREKUENSI_NAFAS, tv.SUHU
		     , nu.BERAT_BADAN, nu.TINGGI_BADAN, nu.INDEX_MASSA_TUBUH, nu.LINGKAR_KEPALA
		     , fu.ALAT_BANTU, fu.PROTHESA, fu.CACAT_TUBUH, DATE_FORMAT(ku.TANGGAL,'%H:%i:%s') JAM
		     , master.getNamaLengkapPegawai(pg.NIP) PERAWAT
		     , IF(pn.NYERI=1,'Ya','Tidak') NYERI
			  , IF(pn.ONSET=1,'Akut',IF(pn.ONSET=2,'Kronis','')) ONSET, pn.SKALA, mt.DESKRIPSI METODE, pn.PENCETUS, pn.GAMBARAN, pn.DURASI, pn.LOKASI
			  , IF(master.getDiagnosa(pp.NOMOR, 1) IS NULL,dg.DIAGNOSIS,CONCAT(master.getKodeDiagnosa(pp.NOMOR, 1),'-',master.getDiagnosa(pp.NOMOR, 1))) DIAGNOSIS
			  , CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL
			  , IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR LIMIT 1))) RIWAYATPENYAKIT
			 , IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR LIMIT 1))) RPS			  
			  , IF(ks.MARAH IS NULL, 0, ks.MARAH) MARAH
			  , IF(ks.CEMAS IS NULL, 0, ks.CEMAS) CEMAS
			  , IF(ks.TAKUT IS NULL, 0, ks.TAKUT) TAKUT
			  , IF(ks.BUNUH_DIRI IS NULL, 0, ks.BUNUH_DIRI) BUNUH_DIRI
			  , IF(ks.SEDIH IS NULL, 0, ks.SEDIH) SEDIH
			  , ks.LAINNYA
			  , ks.MASALAH_PERILAKU
			  , IF(pgz.BERAT_BADAN_SIGNIFIKAN=1,'Ya','Tidak') BERAT_BADAN_SIGNIFIKAN
			  , IF(pgz.PERUBAHAN_BERAT_BADAN=1,'0,5-5 kg'
			  		,IF(pgz.PERUBAHAN_BERAT_BADAN=2,'>5-10 kg'
					  ,IF(pgz.PERUBAHAN_BERAT_BADAN=3,'>10-15 kg'
					  	  ,IF(pgz.PERUBAHAN_BERAT_BADAN=4,'>15 kg','')))) PERUBAHAN_BERAT_BADAN
			  , IF(pgz.INTAKE_MAKANAN=1,'Ya','Tidak Dalam 3 hari terakhir') INTAKE_MAKANAN
			  , pgz.KONDISI_KHUSUS
			  , pgz.SKOR, IF(pgz.STATUS_SKOR=1,'Ya','Tidak') STATUS_SKOR
			  , IF(epk.KESEDIAAN=1,'Ya','Tidak') KESEDIAAN
			  , IF(epk.HAMBATAN=1,'Ya','Tidak') HAMBATAN
			  , IF(epk.HAMBATAN_PENDENGARAN IS NULL, 0, epk.HAMBATAN_PENDENGARAN) HAMBATAN_PENDENGARAN
			  , IF(epk.HAMBATAN_PENGLIHATAN IS NULL, 0, epk.HAMBATAN_PENGLIHATAN) HAMBATAN_PENGLIHATAN
			  , IF(epk.HAMBATAN_KOGNITIF IS NULL, 0, epk.HAMBATAN_KOGNITIF) HAMBATAN_KOGNITIF
			  , IF(epk.HAMBATAN_FISIK IS NULL, 0, epk.HAMBATAN_FISIK) HAMBATAN_FISIK
			  , IF(epk.HAMBATAN_BUDAYA IS NULL, 0, epk.HAMBATAN_BUDAYA) HAMBATAN_BUDAYA
			  , IF(epk.HAMBATAN_EMOSI IS NULL, 0, epk.HAMBATAN_EMOSI) HAMBATAN_EMOSI
			  , IF(epk.HAMBATAN_BAHASA IS NULL, 0, epk.HAMBATAN_BAHASA) HAMBATAN_BAHASA
			  , epk.HAMBATAN_LAINNYA, epk.PENERJEMAH
			  , epk.BAHASA
			  , IF(epk.EDUKASI_DIAGNOSA IS NULL, 0, epk.EDUKASI_DIAGNOSA) EDUKASI_DIAGNOSA
			  , epk.EDUKASI_PENYAKIT
			  , IF(epk.EDUKASI_REHAB_MEDIK IS NULL, 0, epk.EDUKASI_REHAB_MEDIK) EDUKASI_REHAB_MEDIK
			  , IF(epk.EDUKASI_HKP IS NULL, 0, epk.EDUKASI_HKP) EDUKASI_HKP
			  , IF(epk.EDUKASI_OBAT IS NULL, 0, epk.EDUKASI_OBAT) EDUKASI_OBAT
			  , IF(epk.EDUKASI_NYERI IS NULL, 0, epk.EDUKASI_NYERI) EDUKASI_NYERI
			  , IF(epk.EDUKASI_NUTRISI IS NULL, 0, epk.EDUKASI_NUTRISI) EDUKASI_NUTRISI
			  , IF(epk.EDUKASI_PENGGUNAAN_ALAT IS NULL, 0, epk.EDUKASI_PENGGUNAAN_ALAT) EDUKASI_PENGGUNAAN_ALAT
			  , IF(spe.STATUS_PEDIATRIC=1,'GIZI KURANG',IF(spe.STATUS_PEDIATRIC=2,'GIZI CUKUP',IF(spe.STATUS_PEDIATRIC=3,'LENGKAP',''))) STATUS_PEDIATRIC
			  , (SELECT  REPLACE(GROUP_CONCAT(DISTINCT(ib.NAMA)),',','; ')
						FROM layanan.farmasi lf
							  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
							, pendaftaran.kunjungan pk
						     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
						     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
							  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
							  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
							  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
						     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
						   , pendaftaran.pendaftaran pp1
							  LEFT JOIN master.pasien ps ON pp1.NORM=ps.NORM
							, inventory.barang ib
							, pembayaran.rincian_tagihan rt
						WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
							AND pk.NOPEN=pp1.NOMOR AND lf.FARMASI=ib.ID
							AND pp1.NORM=pp.NORM AND pp1.NOMOR!=pp.NOMOR
							AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') RIWAYATOBAT
					, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
									FROM medicalrecord.riwayat_alergi ra
										, pendaftaran.kunjungan pk1
										, pendaftaran.pendaftaran pp2
									WHERE ra.KUNJUNGAN=pk1.NOMOR AND ra.STATUS!=0 AND pk1.STATUS!=0
									  AND pk1.NOPEN=pp2.NOMOR AND pp2.`STATUS`!=0 AND ra.DESKRIPSI!=''
									  AND pp2.NORM=pp.NORM) RIWAYATALERGI
					, rcnt.DESKRIPSI RNCTERAPI
					, master.getJawabanKonsul(pp.NOMOR) KONSUL
					, IF(master.getNamaLengkapPegawai(dpjp.NIP) IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(dpjp.NIP)) DOKTER
					, IF(dpjp.NIP IS NULL,drreg.NIP,dpjp.NIP) NIP
					, IFNULL(DATE_FORMAT(rps.TANGGAL,'%d-%m-%Y %H:%i:%s'),(SELECT DATE_FORMAT(rp.TANGGAL,'%d-%m-%Y %H:%i:%s')
						FROM medicalrecord.rps rp
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR LIMIT 1)) TGLPERIKSA
					, DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%d-%m-%Y %H:%i:%s') TGLASUHAN
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
				  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
				  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
				, pendaftaran.kunjungan pk
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN medicalrecord.rps rps ON pk.NOMOR=rps.KUNJUNGAN AND rps.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_fisik pf ON pk.NOMOR=pf.KUNJUNGAN AND pf.`STATUS`!=0
				  LEFT JOIN medicalrecord.kondisi_sosial ks ON pk.NOMOR=ks.KUNJUNGAN AND ks.`STATUS`!=0
				  LEFT JOIN medicalrecord.permasalahan_gizi pgz ON pk.NOMOR=pgz.KUNJUNGAN AND pgz.`STATUS`!=0
				  LEFT JOIN medicalrecord.edukasi_pasien_keluarga epk ON pk.NOMOR=epk.KUNJUNGAN AND epk.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_pediatric spe ON pk.NOMOR=spe.KUNJUNGAN AND spe.`STATUS`!=0
				  LEFT JOIN medicalrecord.anamnesis an ON pk.NOMOR=an.KUNJUNGAN AND an.`STATUS`!=0
				  LEFT JOIN medicalrecord.pemeriksaan_fisik pfs ON pk.NOMOR=pfs.KUNJUNGAN AND pfs.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
				, master.ruangan r
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pp.NORM=p.NORM AND pk.RUANGAN=r.ID
			  AND pk.NOPEN=PNOPEN AND pk.NOMOR=PKUNJUNGAN
			GROUP BY pk.NOMOR;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR4RDRI
DROP PROCEDURE IF EXISTS `CetakMR4RDRI`;
DELIMITER //
CREATE PROCEDURE `CetakMR4RDRI`(
	IN `PNOPEN` CHAR(10)
)
SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, pp.NOMOR NOPEN
		     , master.getNamaLengkap(pp.NORM) NAMAPASIEN, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR , rjk.DESKRIPSI JENISKELAMIN, ROUND(DATEDIFF(pp.TANGGAL,p.TANGGAL_LAHIR)/365) USIATAHUN
		     , pk.NOMOR KUNJUNGAN, p.ALAMAT ALAMATPASIEN, ref.DESKRIPSI CARABAYAR, rsk.DESKRIPSI STATUSKAWIN 
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK, rpd.DESKRIPSI PENDIDIKAN, rag.DESKRIPSI AGAMA_DESKRIPSI, p.AGAMA IDAGAMA, p.PEKERJAAN IDPEKERJAAN
		     , r.DESKRIPSI UNIT
			  , (SELECT an.DESKRIPSI 
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) ANAMNESIS
			  , (SELECT an.OLEH 
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) IDDOKTERKAJI
			  , (SELECT master.getNamaLengkapPegawai(md.NIP) 
							FROM medicalrecord.anamnesis an
							LEFT JOIN aplikasi.pengguna pan ON an.OLEH=pan.ID
							LEFT JOIN master.dokter md ON pan.NIP=md.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) DOKTERKAJI
			  , (SELECT DATE_FORMAT(an.TANGGAL,'%d-%m-%Y %H:%i:%s')  
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) TGLKAJI 
			  , (SELECT anm.AUTOANAMNESIS
							FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) AUTOANAMNESIS
			  , (SELECT anm.ALLOANAMNESIS 
			  				FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) ALLOANAMNESIS
			  , (SELECT anm.DARI
			  				FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) DIPEROLEH_SECARA
		     , (SELECT fr.HIPERTENSI 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_HIPERTENSI
			  , (SELECT fr.DIABETES_MELITUS 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_DIABETES_MELITUS
			  , (SELECT fr.PENYAKIT_JANTUNG 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_PENYAKIT_JANTUNG
			  , (SELECT fr.ASMA 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ASMA
			  , (SELECT fr.STROKE 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_STROKE
			  , (SELECT fr.LIVER 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_LIVER
			  , (SELECT fr.GINJAL 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_GINJAL
			  , (SELECT fr.TUBERCULOSIS_PARU 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_TB_PARU
			  , (SELECT fr.ROKOK 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ROKOK
			  , (SELECT fr.MINUM_ALKOHOL 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ALKOHOL
			  , (SELECT fr.LAIN_LAIN 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_LAINNYA
			  , (SELECT fr.PERNAH_DIRAWAT_TIDAK AND fr.`STATUS` !=0
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_TIDAK
			  , (SELECT fr.PERNAH_DIRAWAT_YA
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_YA
			  , (SELECT DATE_FORMAT(fr.PERNAH_DIRAWAT_KAPAN,'%d-%m-%Y') 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_KAPAN
		     , (SELECT fr.PERNAH_DIRAWAT_DIMANA
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_DIMANA
			  , (SELECT fr.PERNAH_DIRAWAT_DIAGNOSIS
							FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_DIAGNOSIS
		     , (SELECT rpk.HIPERTENSI
		     				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_HIPERTENSI
			  , (SELECT rpk.DIABETES_MELITUS
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_DIABETES_MELITUS
			  , (SELECT rpk.PENYAKIT_JANTUNG
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_PENYAKIT_JANTUNG
			  , (SELECT rpk.ASMA
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_ASMA
			  , (SELECT rpk.LAINNYA
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_LAINNYA
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
						   FROM medicalrecord.penilaian_fisik pf1
						   LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pf1.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pf1.`STATUS` !=0
							ORDER BY pf1.TANGGAL ASC LIMIT 1) NILAIFISIK
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
						   FROM medicalrecord.pemeriksaan_fisik pf1
						   LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pf1.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pf1.`STATUS` !=0
							ORDER BY pf1.TANGGAL ASC LIMIT 1) FISIK
		     , (SELECT ku.DESKRIPSI
						   FROM medicalrecord.keluhan_utama ku
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ku.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND ku.`STATUS` !=0
							ORDER BY ku.TANGGAL ASC LIMIT 1) KELUHAN			 	
		     , (SELECT tv.KEADAAN_UMUM
		     				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) KEADAAN_UMUM
			  , (SELECT tv.KESADARAN
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) KESADARAN
			  , (SELECT rtv.DESKRIPSI
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							LEFT JOIN `master`.referensi rtv ON tv.TINGKAT_KESADARAN=rtv.ID AND rtv.JENIS=179
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TINGKAT_KESADARAN
			  , (SELECT CONCAT(tv.SISTOLIK,'/', tv.DISTOLIK, ' mmHg') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) DARAH
			  , (SELECT CONCAT(tv.FREKUENSI_NADI, ' X/Menit') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) FREKUENSI_NADI
			  , (SELECT CONCAT(tv.FREKUENSI_NAFAS, ' X/Menit')
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) FREKUENSI_NAFAS
			  , (SELECT CONCAT(tv.SUHU, ' °C') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) SUHU
			  , (SELECT tv.EYE
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_EYE
			  , (SELECT tv.MOTORIK
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_MOTORIK
			  , (SELECT tv.VERBAL
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_VERBAL
			  , (SELECT tv.GCS
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_GCS
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
			  				FROM medicalrecord.tanda_vital tv
			  				LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  			LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) PERAWAT
			  , (SELECT DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%d-%m-%Y %H:%i:%s')
			  				FROM medicalrecord.tanda_vital tv		  				
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TGLASUHAN
			  , (SELECT pmt.ANEMIS
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_ANEMIS
			  , (SELECT pmt.IKTERUS
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_IKTERUS
			  , (SELECT pmt.PUPIL_ISOKOR
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_PUPIL_ISOKOR
			  , (SELECT pmt.PUPIL_ANISOKOR
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_PUPIL_ANISOKOR
			  , (SELECT pmt.DIAMETER_ISIAN
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DIAMETER_ISIAN
			  , (SELECT pmt.DIAMETER_MM
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DIAMETER_MM
			  , (SELECT pmt.UDEM
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_UDEM
			  , (SELECT rmt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							LEFT JOIN `master`.referensi rmt ON pmt.ADA_KELAINAN=rmt.ID AND rmt.JENIS=178
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_KELAINAN_MATA
			  , (SELECT pmt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DESK_MATA
			  , (SELECT pts.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_tonsil pts
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pts.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pts.`STATUS` !=0
							ORDER BY pts.TANGGAL ASC LIMIT 1) PTS_KELAINAN_TONSIL
			  , (SELECT pts.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_tonsil pts
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pts.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pts.`STATUS` !=0
							ORDER BY pts.TANGGAL ASC LIMIT 1) PTS_DESK_TONSIL
			  , (SELECT pfr.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_faring pfr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pfr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pfr.`STATUS` !=0
							ORDER BY pfr.TANGGAL ASC LIMIT 1) PFR_KELAINAN_FARING
			  , (SELECT pfr.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_faring pfr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pfr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pfr.`STATUS` !=0
							ORDER BY pfr.TANGGAL ASC LIMIT 1) PFR_DESK_FARING
			  , (SELECT pld.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_lidah pld
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pld.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pld.`STATUS` !=0
							ORDER BY pld.TANGGAL ASC LIMIT 1) PLD_KELAINAN_LIDAH
			  , (SELECT pld.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_lidah pld
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pld.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pld.`STATUS` !=0
							ORDER BY pld.TANGGAL ASC LIMIT 1) PLD_DESK_LIDAH
			  , (SELECT pbr.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_bibir pbr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pbr.`STATUS` !=0
							ORDER BY pbr.TANGGAL ASC LIMIT 1) PBR_KELAINAN_BIBIR
			  , (SELECT pbr.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_bibir pbr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pbr.`STATUS` !=0
							ORDER BY pbr.TANGGAL ASC LIMIT 1) PBR_DESK_BIBIR
			  , (SELECT plh.JVP 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_JVP
			  , (SELECT plh.PKL 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_PKL
			  , (SELECT plh.PKL_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_PKL_DESKRIPSI
			  , (SELECT plh.KAKUDUK 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KAKUDUK
			  , (SELECT plh.KAKUDUK_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KAKUDUK_DESKRIPSI
			  , (SELECT plh.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KELAINAN_LEHER
			  , (SELECT plh.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_DESK_LEHER
			  , (SELECT pdd.THORAKS_SIMETRIS 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_SIMETRIS
			  , (SELECT pdd.THORAKS_ASIMETRIS
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_ASIMETRIS
			  , (SELECT pdd.THORAKS_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_DESKRIPSI
			  , (SELECT pdd.COR 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_COR
			  , (SELECT pdd.REGULER 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_REGULER
			  , (SELECT pdd.IREGULER 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_IREGULER
			  , (SELECT pdd.MURMUR 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_MURMUR
			  , (SELECT pdd.LAIN_LAIN 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_LAINLAIN
			  , (SELECT pdd.PULMO_SUARA_NAFAS 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_PULMO_SUARA_NAFAS
			  , (SELECT pdd.RONCHI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_RONCHI
			  , (SELECT pdd.RONCHI_DEKSRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_RONCHI_DESKRIPSI
			  , (SELECT pdd.WHEEZING 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_WHEEZING
			  , (SELECT pdd.WHEEZING_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_WHEEZING_DESKRIPSI
			  , (SELECT pdd.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_KELAINAN_PDD
			  , (SELECT pdd.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_DESK_PDD
			  , (SELECT prt.ABDOMEN_DISTENDED 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ABDOMEN_DISTENDED
			  , (SELECT prt.ABDOMEN_METEORISMUS 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ABDOMEN_METEORISMUS
			  , (SELECT prt.PERISTALTIK_NORMAL 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_NORMAL
			  , (SELECT prt.PERISTALTIK_MENINGKAT 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_MENINGKAT
			  , (SELECT prt.PERISTALTIK_MENURUN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_MENURUN
			  , (SELECT prt.PERISTALTIK_TIDAK_ADA 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_TIDAK_ADA
			  , (SELECT prt.ASITES 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ASITES
			  , (SELECT prt.NYERI_TEKAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_NYERI_TEKAN
			  , (SELECT prt.NYERI_TEKAN_LOKASI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_NYERI_TEKAN_LOKASI
			  , (SELECT prt.HEPAR 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_HEPAR
			  , (SELECT prt.LIEN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_LIEN
			  , (SELECT prt.EXTREMITAS_HANGAT 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_EXTREMITAS_HANGAT
			  , (SELECT prt.EXTREMITAS_DINGIN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_EXTREMITAS_DINGIN
			  , (SELECT prt.UDEM 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM
			  , (SELECT prt.UDEM_DEKSRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM_DEKSRIPSI
			  , (SELECT prt.LAIN_LAIN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM_LAINLAIN
			  , (SELECT prt.DEFEKASI_ANUS 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS 
			  , (SELECT prt.DEFEKASI_ANUS_FREKUENSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS_FREKUENSI
			  , (SELECT prt.DEFEKASI_ANUS_KONSISTENSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS_KONSISTENSI
			  , (SELECT prt.DEFEKASI_STOMA 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_STOMA
			  , (SELECT prt.DEFEKASI_STOMA_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_STOMA_DESKRIPSI
			  , (SELECT prt.URIN_SPONTAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_SPONTAN
			  , (SELECT prt.URIN_KATETER 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_KATETER
			  , (SELECT prt.URIN_CYTOSTOMY 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_CYTOSTOMY
			  , (SELECT prt.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_KELAINAN_PERUT
			  , (SELECT prt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DESK_PERUT
			  , (SELECT kss.TIDAK_ADA_KELAINAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TDK_ADA_KELAINAN
			  , (SELECT kss.MARAH 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_MARAH
			  , (SELECT kss.CEMAS 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_CEMAS
			  , (SELECT kss.TAKUT 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TAKUT
			  , (SELECT kss.BUNUH_DIRI 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_BUNUH_DIRI
			  , (SELECT kss.SEDIH 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_SEDIH
			  , (SELECT kss.LAINNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_LAINNYA
			  , (SELECT kss.STATUS_MENTAL 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_STATUS_MENTAL
			  , (SELECT kss.MASALAH_PERILAKU 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_MASALAH_PERILAKU
			  , (SELECT kss.PERILAKU_KEKERASAN_DIALAMI_SEBELUMNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PERILAKU_KEKERASAN_DIALAMI_SEBELUMNYA
			  , (SELECT kss.HUBUNGAN_PASIEN_DENGAN_KELUARGA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_HUBUNGAN_PASIEN_DENGAN_KELUARGA
			  , (SELECT kss.TEMPAT_TINGGAL 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TEMPAT_TINGGAL
			  , (SELECT kss.TEMPAT_TINGGAL_LAINNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TEMPAT_TINGGAL_LAINNYA
			  , (SELECT kss.KEBIASAAN_BERIBADAH_TERATUR 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_KEBIASAAN_BERIBADAH_TERATUR
			  , (SELECT kss.NILAI_KEPERCAYAAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_NILAI_KEPERCAYAAN
			  , (SELECT kss.NILAI_KEPERCAYAAN_DESKRIPSI 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_NILAI_KEPERCAYAAN_DESKRIPSI
			  , (SELECT kss.PENGAMBIL_KEPUTUSAN_DALAM_KELUARGA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PENGAMBIL_KEPUTUSAN_DALAM_KELUARGA
			  , (SELECT kss.PENGHASILAN_PERBULAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PENGHASILAN_PERBULAN
			  , (SELECT dpf.PASIEN_TINGGAL_SENDIRI 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_TINGGAL_SENDIRI
			  , (SELECT dpf.PASIEN_KHAWATIR_KETIKA_DIRUMAH 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_KHAWATIR_KETIKA_DIRUMAH
			  , (SELECT dpf.PASIEN_TAK_ADA_YANG_MERAWAT 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_TAK_ADA_YANG_MERAWAT
			  , (SELECT dpf.PASIEN_DILANTAI_ATAS 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_DILANTAI_ATAS
			  , (SELECT dpf.PERAWATAN_LANJUTAN_PASIEN 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PERAWATAN_LANJUTAN_PASIEN
			  , (SELECT dpf.PENGAJUAN_PENDAMPINGAN_PASIEN 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PENGAJUAN_PENDAMPINGAN_PASIEN
			  , (SELECT dpf.REASSESSMENT
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_REASSESSMENT
			  , (SELECT DATE_FORMAT(dpf.TANGGAL_REASSESSMENT,'%d-%m-%Y')
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_TANGGAL_REASSESSMENT
			  , (SELECT DATE_FORMAT(dpf.TANGGAL_REASSESSMENT,'%H:%i:%s')
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_JAM_REASSESSMENT			  
			  , (SELECT dpf.USER
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_USER
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
			  				LEFT JOIN aplikasi.pengguna us ON dpf.USER_REASSESSMENT=us.ID
				  			LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_USER_REASSESSMENT	
			  , (SELECT dps.KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB
			  , (SELECT dps.KPB_RAWAT_LUKA
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_RAWAT_LUKA
			  , (SELECT dps.KPB_HIV
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_HIV
			  , (SELECT dps.KPB_TB
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_TB
			  , (SELECT dps.KPB_DM
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_DM
			  , (SELECT dps.KPB_DM_TERAPI_INSULIN
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_DM_TERAPI_INSULIN
			  , (SELECT dps.KPB_STROKE
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_STROKE
			  , (SELECT dps.KPB_PPOK
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_PPOK
			  , (SELECT dps.KPB_CKD
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_CKD
			  , (SELECT dps.KPB_PASIEN_KEMO
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_PASIEN_KEMO
			  , (SELECT dps.PENGGUNAAN_ALAT_MEDIS_PAM
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PENGGUNAAN_ALAT_MEDIS_PAM
			  , (SELECT dps.PAM_KATETER_URIN
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_KATETER_URIN
			  , (SELECT dps.PAM_NGT
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_NGT
			  , (SELECT dps.PAM_TRAECHOSTOMY
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_TRAECHOSTOMY
			  , (SELECT dps.PAM_COLOSTOMY
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_COLOSTOMY
			  , (SELECT dps.PAM_LAINNYA
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_LAINNYA	
		     , (SELECT nu.BERAT_BADAN 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_BERAT_BADAN
			  , (SELECT nu.TINGGI_BADAN 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_TINGGI_BADAN
			  , (SELECT nu.INDEX_MASSA_TUBUH 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_INDEX_MASSA
			  , (SELECT nu.LINGKAR_KEPALA 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_LINGKAR_KEPALA
		     , (SELECT fu.ALAT_BANTU
		     				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_ALAT_BANTU
			  , (SELECT fu.PROTHESA
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_PROTHESA
			  , (SELECT fu.CACAT_TUBUH
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_CACAT_TUBUH
			  , (SELECT DATE_FORMAT(fu.TANGGAL,'%H:%i:%s')
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_JAM			
		     , (SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0))
							FROM medicalrecord.penilaian_dekubitus pdek
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdek.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pdek.KONDISI_FISIK=krd.ID AND krd.JENIS=181
							LEFT JOIN master.referensi krk ON pdek.KESADARAN=krk.ID AND krk.JENIS=182
							LEFT JOIN master.referensi bd ON pdek.AKTIVITAS=bd.ID AND bd.JENIS=183
							LEFT JOIN master.referensi pjn ON pdek.MOBILITAS=pjn.ID AND pjn.JENIS=184
							LEFT JOIN master.referensi mk ON pdek.INKONTINENSIA=mk.ID AND mk.JENIS=185
							WHERE pkrp.NOPEN=pp.NOMOR AND pdek.`STATUS` !=0
							ORDER BY pdek.TANGGAL ASC LIMIT 1) NILAIDEKUBITUS
		     , (SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+
			  					IFNULL(ps.SCORING,0)+IFNULL(pjl.SCORING,0)+IFNULL(pb.SCORING,0)+IFNULL(ntt.SCORING,0)+IFNULL(mn.SCORING,0))
							FROM medicalrecord.penilaian_barthel_index pbi
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbi.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pbi.KENDALI_RANGSANG_DEFEKASI=krd.ID AND krd.JENIS=232
							LEFT JOIN master.referensi krk ON pbi.KENDALI_RANGSANG_KEMIH=krk.ID AND krk.JENIS=233
							LEFT JOIN master.referensi bd ON pbi.BERSIH_DIRI=bd.ID AND bd.JENIS=234
							LEFT JOIN master.referensi pjn ON pbi.PENGGUNAAN_JAMBAN=pjn.ID AND pjn.JENIS=235
							LEFT JOIN master.referensi mk ON pbi.MAKAN=mk.ID AND mk.JENIS=236
							LEFT JOIN master.referensi ps ON pbi.PERUBAHAN_SIKAP=ps.ID AND ps.JENIS=237
							LEFT JOIN master.referensi pjl ON pbi.PINDAH_JALAN=pjl.ID AND pjl.JENIS=238
							LEFT JOIN master.referensi pb ON pbi.PAKAI_BAJU=pb.ID AND pb.JENIS=239
							LEFT JOIN master.referensi ntt ON pbi.NAIK_TURUN_TANGGA=ntt.ID AND ntt.JENIS=240
							LEFT JOIN master.referensi mn ON pbi.MANDI=mn.ID AND mn.JENIS=241
							WHERE pkrp.NOPEN=pp.NOMOR AND pbi.`STATUS` !=0
							ORDER BY pbi.TANGGAL ASC LIMIT 1) SKORBARTHELINDEX
				, @SKORMORSE:=(SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+IFNULL(ps.SCORING,0))
							FROM medicalrecord.penilaian_skala_morse psm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=psm.KUNJUNGAN
							LEFT JOIN master.referensi krd ON psm.RIWAYAT_JATUH=krd.ID AND krd.JENIS=186
							LEFT JOIN master.referensi krk ON psm.DIAGNOSIS=krk.ID AND krk.JENIS=187
							LEFT JOIN master.referensi bd ON psm.ALAT_BANTU=bd.ID AND bd.JENIS=188
							LEFT JOIN master.referensi pjn ON psm.HEPARIN=pjn.ID AND pjn.JENIS=189
							LEFT JOIN master.referensi mk ON psm.GAYA_BERJALAN=mk.ID AND mk.JENIS=190
							LEFT JOIN master.referensi ps ON psm.KESADARAN=ps.ID AND ps.JENIS=191
							WHERE pkrp.NOPEN=pp.NOMOR AND psm.`STATUS` !=0
							ORDER BY psm.TANGGAL ASC LIMIT 1) SKORMORSE
			  , @SKORHUMPTYDUMPTY:=(SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+IFNULL(ps.SCORING,0)+IFNULL(pjl.SCORING,0))
							FROM medicalrecord.penilaian_skala_humpty_dumpty pshd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pshd.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pshd.UMUR=krd.ID AND krd.JENIS=192
							LEFT JOIN master.referensi krk ON pshd.JENIS_KELAMIN=krk.ID AND krk.JENIS=193
							LEFT JOIN master.referensi bd ON pshd.DIAGNOSA=bd.ID AND bd.JENIS=194
							LEFT JOIN master.referensi pjn ON pshd.GANGGUAN_KONGNITIF=pjn.ID AND pjn.JENIS=195
							LEFT JOIN master.referensi mk ON pshd.FAKTOR_LINGKUNGAN=mk.ID AND mk.JENIS=196
							LEFT JOIN master.referensi ps ON pshd.RESPON=ps.ID AND ps.JENIS=197
							LEFT JOIN master.referensi pjl ON pshd.PENGGUNAAN_OBAT=pjl.ID AND pjl.JENIS=198
							WHERE pkrp.NOPEN=pp.NOMOR AND pshd.`STATUS` !=0
							ORDER BY pshd.TANGGAL ASC LIMIT 1) SKORHUMPTYDUMPTY
			  , @MORSE_TIDAK_ADA:=IF(@SKORMORSE = 0, 1,0) MORSE_TIDAK_ADA
			  , @MORSE_RENDAH:=IF(@SKORMORSE BETWEEN 1 AND 24, 1,0) MORSE_RENDAH
			  , @MORSE_SEDANG:=IF(@SKORMORSE BETWEEN 25 AND 44, 1,0) MORSE_SEDANG
			  , @MORSE_TINGGI:=IF(@SKORMORSE >= 45, 1,0) MORSE_TINGGI
			  , @HUMPTY_TIDAK_ADA:=IF(@SKORHUMPTYDUMPTY < 7 , 1,0) HUMPTY_TIDAK_ADA
			  , @HUMPTY_RENDAH:=IF(@SKORHUMPTYDUMPTY BETWEEN 7 AND 11, 1,0) HUMPTY_RENDAH
			  , @HUMPTY_TINGGI:=IF(@SKORHUMPTYDUMPTY > 11, 1,0) HUMPTY_TINGGI
			  , IF(@SKORMORSE IS NULL, @HUMPTY_TIDAK_ADA, @MORSE_TIDAK_ADA) RESIKO_TIDAK_ADA
			  , IF(@SKORMORSE IS NULL, @HUMPTY_RENDAH, @MORSE_RENDAH) RESIKO_RENDAH
			  , @MORSE_SEDANG RESIKO_SEDANG
			  , IF(@SKORMORSE IS NULL, @HUMPTY_TINGGI, @MORSE_TINGGI) RESIKO_TINGGI
		     , IF((SELECT pn.NYERI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1)=1,'Ya','Tidak') NYERI
			  , IF((SELECT pn.ONSET
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1)=1,'Akut','Kronis') ONSET
           , (SELECT pn.SKALA
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) SKALA
	        , (SELECT mt.DESKRIPSI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) METODE
	        , (SELECT pn.PENCETUS
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) PENCETUS
	        , (SELECT pn.GAMBARAN
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) GAMBARAN
	        , (SELECT pn.DURASI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) DURASI
	        , (SELECT pn.LOKASI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) LOKASI
			  , CONCAT(IFNULL(master.getDiagnosaPasien(pp.NOMOR),''),'\r',
							IFNULL((SELECT ass.ASSESMENT
							FROM medicalrecord.cppt ass
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN 
							WHERE pkrp.NOMOR=pk.NOMOR AND pk.NOPEN=pp.NOMOR
							AND ass.JENIS !=3 AND ass.`STATUS` !=0
							ORDER BY ass.TANGGAL ASC LIMIT 1),'')) DIAGNOSIS
			  , CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL
			  , IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))) RIWAYATPENYAKIT
			 , IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))) rps
			 , (SELECT ask.OLEH
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) IDASK
			 , (SELECT master.getNamaLengkapPegawai(askep.NIP)
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN aplikasi.pengguna askep ON ask.OLEH=askep.ID 
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN 
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) PASK	
			 , (SELECT DATE_FORMAT(ask.TANGGAL,'%d-%m-%Y %H:%i:%s')
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN aplikasi.pengguna askep ON ask.OLEH=askep.ID 
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN 
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) TASK			 	  
			  , (SELECT IF(ks.MARAH IS NULL, 0, ks.MARAH)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) MARAH
			  , (SELECT IF(ks.CEMAS IS NULL, 0, ks.CEMAS)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) CEMAS
			  , (SELECT IF(ks.TAKUT IS NULL, 0, ks.TAKUT)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) TAKUT
			  , (SELECT IF(ks.BUNUH_DIRI IS NULL, 0, ks.BUNUH_DIRI)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) BUNUH_DIRI
			  , (SELECT IF(ks.SEDIH IS NULL, 0, ks.SEDIH)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) SEDIH
			  , (SELECT ks.LAINNYA
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) LAINNYA
			  , (SELECT ks.MASALAH_PERILAKU
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) MASALAH_PERILAKU
			  , (SELECT pgz.BERAT_BADAN_SIGNIFIKAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) BERAT_BADAN_SIGNIFIKAN	
				, (SELECT pgz.INTAKE_MAKANAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) INTAKE_MAKANAN
				, (SELECT pgz.KONDISI_KHUSUS
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) KONDISI_KHUSUS
				, (SELECT pgz.SKOR
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) SKOR
				, IF((SELECT pgz.STATUS_SKOR
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=1,'Ya','Tidak') STATUS_SKOR
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=1,1,0) PBB1
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=2,2,0) PBB2
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=3,3,0) PBB3
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=4,4,0) PBB4
				, (SELECT pgz.STATUS_VALIDASI
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) STATUS_VALIDASI	
				, (SELECT DATE_FORMAT(pgz.TANGGAL_VALIDASI,'%d-%m-%Y %H:%i:%s')
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) TANGGAL_VALIDASI
				, (SELECT master.getNamaLengkapPegawai(ugz.NIP)
			  				FROM medicalrecord.permasalahan_gizi pgz
			  				LEFT JOIN aplikasi.pengguna ugz ON pgz.USER_VALIDASI=ugz.ID
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) DIETISEN	  
			  , IF(pgz.PERUBAHAN_BERAT_BADAN=1,'0,5-5 kg'
			  		,IF(pgz.PERUBAHAN_BERAT_BADAN=2,'>5-10 kg'
					  ,IF(pgz.PERUBAHAN_BERAT_BADAN=3,'>10-15 kg'
					  	  ,IF(pgz.PERUBAHAN_BERAT_BADAN=4,'>15 kg','')))) PERUBAHAN_BERAT_BADAN
			  , (SELECT IF(epk.KESEDIAAN=1,'Ya','Tidak')
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) KESEDIAAN
			  , (SELECT IF(epk.HAMBATAN=1,'Ya','Tidak')
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN
			  , (SELECT IF(epk.HAMBATAN_PENDENGARAN IS NULL, 0, epk.HAMBATAN_PENDENGARAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_PENDENGARAN
			  , (SELECT IF(epk.HAMBATAN_PENGLIHATAN IS NULL, 0, epk.HAMBATAN_PENGLIHATAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_PENGLIHATAN
			  , (SELECT IF(epk.HAMBATAN_KOGNITIF IS NULL, 0, epk.HAMBATAN_KOGNITIF)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_KOGNITIF
			  , (SELECT IF(epk.HAMBATAN_FISIK IS NULL, 0, epk.HAMBATAN_FISIK)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_FISIK
			  , (SELECT IF(epk.HAMBATAN_BUDAYA IS NULL, 0, epk.HAMBATAN_BUDAYA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_BUDAYA
			  , (SELECT IF(epk.HAMBATAN_EMOSI IS NULL, 0, epk.HAMBATAN_EMOSI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_EMOSI
			  , (SELECT IF(epk.HAMBATAN_BAHASA IS NULL, 0, epk.HAMBATAN_BAHASA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_BAHASA
			  , (SELECT epk.HAMBATAN_LAINNYA
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_LAINNYA
			  , (SELECT epk.PENERJEMAH
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) PENERJEMAH
			  , (SELECT epk.BAHASA
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) BAHASA
			  , (SELECT IF(epk.EDUKASI_DIAGNOSA IS NULL, 0, epk.EDUKASI_DIAGNOSA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_DIAGNOSA
			  , (SELECT epk.EDUKASI_PENYAKIT
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENYAKIT
			  , (SELECT IF(epk.EDUKASI_REHAB_MEDIK IS NULL, 0, epk.EDUKASI_REHAB_MEDIK)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_REHAB_MEDIK
			  , (SELECT IF(epk.EDUKASI_HKP IS NULL, 0, epk.EDUKASI_HKP)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_HKP
			  , (SELECT IF(epk.EDUKASI_OBAT IS NULL, 0, epk.EDUKASI_OBAT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_OBAT
			  , (SELECT IF(epk.EDUKASI_NYERI IS NULL, 0, epk.EDUKASI_NYERI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_NYERI
			  , (SELECT IF(epk.EDUKASI_NUTRISI IS NULL, 0, epk.EDUKASI_NUTRISI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_NUTRISI
			  , (SELECT IF(epk.EDUKASI_PENGGUNAAN_ALAT IS NULL, 0, epk.EDUKASI_PENGGUNAAN_ALAT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENGGUNAAN_ALAT
			  , (SELECT IF(epk.EDUKASI_HAK_BERPARTISIPASI IS NULL, 0, epk.EDUKASI_HAK_BERPARTISIPASI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_HAK_BERPARTISIPASI
			  , (SELECT IF(epk.EDUKASI_PROSEDURE_PENUNJANG IS NULL, 0, epk.EDUKASI_PROSEDURE_PENUNJANG)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PROSEDURE_PENUNJANG
			  , (SELECT IF(epk.EDUKASI_PEMBERIAN_INFORMED_CONSENT IS NULL, 0, epk.EDUKASI_PEMBERIAN_INFORMED_CONSENT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PEMBERIAN_INFORMED_CONSENT
			  , (SELECT IF(epk.EDUKASI_PENUNDAAN_PELAYANAN IS NULL, 0, epk.EDUKASI_PENUNDAAN_PELAYANAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENUNDAAN_PELAYANAN
			  , (SELECT IF(epk.EDUKASI_KELAMBATAN_PELAYANAN IS NULL, 0, epk.EDUKASI_KELAMBATAN_PELAYANAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_KELAMBATAN_PELAYANAN
			  , (SELECT IF(epk.EDUKASI_CUCI_TANGAN IS NULL, 0, epk.EDUKASI_CUCI_TANGAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_CUCI_TANGAN
			  , (SELECT IF(epk.EDUKASI_BAHAYA_MEROKO IS NULL, 0, epk.EDUKASI_BAHAYA_MEROKO)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_BAHAYA_MEROKO
			  , (SELECT IF(epk.EDUKASI_RUJUKAN_PASIEN IS NULL, 0, epk.EDUKASI_RUJUKAN_PASIEN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_RUJUKAN_PASIEN
			  , (SELECT IF(epk.EDUKASI_PERENCANAAN_PULANG IS NULL, 0, epk.EDUKASI_PERENCANAAN_PULANG)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PERENCANAAN_PULANG
			  , (SELECT IF(epk.STATUS_LAIN IS NULL, 0, epk.STATUS_LAIN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) STATUS_LAIN
			  , (SELECT IF(epk.DESKRIPSI_LAINYA IS NULL, 0, epk.DESKRIPSI_LAINYA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) DESKRIPSI_LAINYA
			  , IF((SELECT rcnt.DESKRIPSI
			  				FROM medicalrecord.status_pediatric spe
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
							ORDER BY spe.TANGGAL ASC LIMIT 1)=1,'GIZI KURANG',
								IF((SELECT rcnt.DESKRIPSI
				  				FROM medicalrecord.status_pediatric spe
								LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
								WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
								ORDER BY spe.TANGGAL ASC LIMIT 1)=2,'GIZI CUKUP',
									IF((SELECT rcnt.DESKRIPSI
					  				FROM medicalrecord.status_pediatric spe
									LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
									WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
									ORDER BY spe.TANGGAL ASC LIMIT 1)=3,'LENGKAP',''))) STATUS_PEDIATRIC  		  
			  , (SELECT rcnt.DESKRIPSI
			  				FROM medicalrecord.rencana_terapi rcnt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rcnt.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND rcnt.`STATUS` !=0
							ORDER BY rcnt.TANGGAL ASC LIMIT 1) RNCTERAPI
			  , (SELECT ekg.KESIMPULAN
			  				FROM medicalrecord.pemeriksaan_ekg ekg
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ekg.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ekg.`STATUS` !=0
							ORDER BY ekg.DIBUAT_TANGGAL ASC LIMIT 1) EKG			  
			  , medicalrecord.getHasilPenunjang(pp.NOMOR) HASILPENUNJANG
			  , master.getJawabanKonsul(pp.NOMOR) KONSUL
			  , IF(master.getNamaLengkapPegawai(dpjp.NIP) IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(dpjp.NIP)) DOKTER
			  , IF(dpjp.NIP IS NULL,drreg.NIP,dpjp.NIP) NIP
			  , IFNULL(DATE_FORMAT(rps.TANGGAL,'%d-%m-%Y %H:%i:%s'),(SELECT DATE_FORMAT(rp.TANGGAL,'%d-%m-%Y %H:%i:%s')
					FROM medicalrecord.rps rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1)) TGLPERIKSA			  
			  , CONCAT(IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL(ib.NAMA,''))),',','; ')
						FROM layanan.farmasi lf
							  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
							, pendaftaran.kunjungan pk
						     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
						     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
							  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
							  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
							  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
						     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
						   , pendaftaran.pendaftaran pp1
							  LEFT JOIN master.pasien ps ON pp1.NORM=ps.NORM
							, inventory.barang ib
							, pembayaran.rincian_tagihan rt
						WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
							AND pk.NOPEN=pp1.NOMOR AND lf.FARMASI=ib.ID
							AND pp1.NORM=pp.NORM AND pp1.NOMOR!=pp.NOMOR
							AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'),''),'\r',
							IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL(rpo.OBAT,''))),',','; ')
							FROM medicalrecord.riwayat_pemberian_obat rpo
								, pendaftaran.kunjungan k
							WHERE rpo.KUNJUNGAN = k.NOMOR AND k.`STATUS` IN (1,2) AND rpo.`STATUS`!=0
									AND k.NOPEN=pp.NOMOR),'')) RIWAYATOBAT					
					, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
									FROM medicalrecord.riwayat_alergi ra
										, pendaftaran.kunjungan pk1
										, pendaftaran.pendaftaran pp2
									WHERE ra.KUNJUNGAN=pk1.NOMOR AND ra.STATUS!=0 AND pk1.STATUS!=0
									  AND pk1.NOPEN=pp2.NOMOR AND pp2.`STATUS`!=0 AND ra.DESKRIPSI!=''
									  AND pp2.NORM=pp.NORM
									  AND ra.`STATUS` !=0 ORDER BY ra.TANGGAL ASC LIMIT 1) RIWAYATALERGI
					, (SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) 
							FROM layanan.hasil_lab hlab,
								  layanan.tindakan_medis tm,
								  master.parameter_tindakan_lab ptl
								  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
								  master.tindakan mt
								  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN
								  LEFT JOIN master.group_lab kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.ID
								  LEFT JOIN master.group_lab ggl ON gtl.GROUP_LAB=ggl.ID,
								  pendaftaran.pendaftaran pp
								  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
								  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
								  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN,
								  pendaftaran.kunjungan pk 
								  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
								  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
								  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5								  
							WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
									AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`!=0
									AND tpp.TAGIHAN=tpdf.TAGIHAN
									AND (hlab.HASIL!='' AND hlab.HASIL IS NOT NULL)
									AND pp.`STATUS`!=0 AND pk.`STATUS`!=0 AND r.JENIS_KUNJUNGAN=4
							ORDER BY hlab.ID) LAB
					, (SELECT GROUP_CONCAT(t.NAMA,' = ',hrad.HASIL)
							FROM layanan.hasil_rad hrad
								, layanan.tindakan_medis tm
								  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
								, pendaftaran.pendaftaran pp
								  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN
								, pendaftaran.kunjungan pk 
						WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR 
							AND hrad.TINDAKAN_MEDIS=tm.ID
							AND tpp.TAGIHAN=tpdf.TAGIHAN
							AND hrad.`STATUS`!=0 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0) RAD		
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
		        LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pp.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
				  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
				  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
				, pendaftaran.kunjungan pk
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN `master`.referensi rtv ON tv.TINGKAT_KESADARAN=rtv.ID AND rtv.JENIS=179
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN medicalrecord.rps rps ON pk.NOMOR=rps.KUNJUNGAN AND rps.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_fisik pf ON pk.NOMOR=pf.KUNJUNGAN AND pf.`STATUS`!=0
				  LEFT JOIN medicalrecord.kondisi_sosial ks ON pk.NOMOR=ks.KUNJUNGAN AND ks.`STATUS`!=0
				  LEFT JOIN medicalrecord.permasalahan_gizi pgz ON pk.NOMOR=pgz.KUNJUNGAN AND pgz.`STATUS`!=0
				  LEFT JOIN medicalrecord.edukasi_pasien_keluarga epk ON pk.NOMOR=epk.KUNJUNGAN AND epk.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_pediatric spe ON pk.NOMOR=spe.KUNJUNGAN AND spe.`STATUS`!=0
				  LEFT JOIN medicalrecord.anamnesis an ON pk.NOMOR=an.KUNJUNGAN AND an.`STATUS`!=0
				  LEFT JOIN aplikasi.pengguna pga ON an.OLEH=pga.ID
				  LEFT JOIN medicalrecord.pemeriksaan_fisik pfs ON pk.NOMOR=pfs.KUNJUNGAN AND pfs.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN medicalrecord.anamnesis_diperoleh anm ON pk.NOMOR = anm.KUNJUNGAN AND anm.`STATUS` != 0
				  LEFT JOIN medicalrecord.faktor_risiko fr ON pk.NOMOR = fr.KUNJUNGAN AND fr.`STATUS` != 0
				  LEFT JOIN medicalrecord.riwayat_pemberian_obat rpo ON pk.NOMOR = rpo.KUNJUNGAN AND rpo.`STATUS` !=0
				  LEFT JOIN medicalrecord.riwayat_penyakit_keluarga rpk ON pk.NOMOR = rpk.KUNJUNGAN AND rpk.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_mata pmt ON pk.NOMOR=pmt.KUNJUNGAN AND pmt.`STATUS` !=0
				  LEFT JOIN `master`.referensi rmt ON pmt.ADA_KELAINAN=rmt.ID AND rmt.JENIS=178
				  LEFT JOIN medicalrecord.pemeriksaan_tonsil pts ON pk.NOMOR=pts.KUNJUNGAN AND pts.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_faring pfr ON pk.NOMOR=pfr.KUNJUNGAN AND pfr.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_lidah pld ON pk.NOMOR=pld.KUNJUNGAN AND pld.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_bibir pbr ON pk.NOMOR=pbr.KUNJUNGAN AND pbr.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_leher plh ON pk.NOMOR=plh.KUNJUNGAN AND plh.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_dada pdd ON pk.NOMOR=pdd.KUNJUNGAN AND pdd.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_perut prt ON pk.NOMOR=prt.KUNJUNGAN AND prt.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_dekubitus pdk ON pk.NOMOR=pdk.KUNJUNGAN AND pdk.`STATUS` !=0
				  LEFT JOIN medicalrecord.kondisi_sosial kss ON pk.NOMOR=kss.KUNJUNGAN AND kss.`STATUS` !=0
				  LEFT JOIN medicalrecord.discharge_planning_skrining dps ON pk.NOMOR=dps.KUNJUNGAN AND dps.`STATUS` !=0
				  LEFT JOIN medicalrecord.discharge_planning_faktor_risiko dpf ON pk.NOMOR=dpf.KUNJUNGAN AND dpf.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_skala_morse psm ON pk.NOMOR=psm.KUNJUNGAN AND psm.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_skala_humpty_dumpty pshd ON pk.NOMOR=pshd.KUNJUNGAN AND pshd.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_ekg ekg ON pk.NOMOR=ekg.KUNJUNGAN AND ekg.`STATUS` !=0
				  LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
			     LEFT JOIN aplikasi.pengguna ugz ON pgz.USER_VALIDASI=ugz.ID
				, master.ruangan r
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pp.NORM=p.NORM AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN IN (2,3)
			  AND pk.NOPEN=PNOPEN
			GROUP BY pk.NOPEN//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakMR5
DROP PROCEDURE IF EXISTS `CetakMR5`;
DELIMITER //
CREATE PROCEDURE `CetakMR5`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
		SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, pp.NOMOR NOPEN
		     , master.getNamaLengkap(pp.NORM) NAMAPASIEN, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',rjk.DESKRIPSI,')') TANGGAL_LAHIR
			  , DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGLLHR, IF(wl.ID IS NULL,p.TEMPAT_LAHIR,wl.DESKRIPSI) TEMPATLHR, IF(p.JENIS_KELAMIN=1,'L','P') JENIS_KELAMIN
		     , pk.NOMOR KUNJUNGAN
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK
		     , (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=2) KODEMR1
		     , r.DESKRIPSI UNIT
		     , nu.BERAT_BADAN, nu.TINGGI_BADAN, nu.INDEX_MASSA_TUBUH, nu.LINGKAR_KEPALA
		     , sfu.ALAT_BANTU, sfu.TANPA_ALAT_BANTU, sfu.TONGKAT, sfu.KURSI_RODA, sfu.BRANKARD, sfu.WALKER
			  , sfu.CACAT_TUBUH_TIDAK, sfu.CACAT_TUBUH_YA, sfu.KET_CACAT_TUBUH, fu.PROTHESA
			  , IF(pn.NYERI=1,'Ya','Tidak') NYERI
			  , IF(pn.ONSET=1,'Akut',IF(pn.ONSET=2,'Kronis','')) ONSET, pn.SKALA, mt.DESKRIPSI METODE, pn.PENCETUS, pn.GAMBARAN, pn.DURASI, pn.LOKASI
			  , rcnt.DESKRIPSI RNCTERAPI, anm.DESKRIPSI ANAMNESIS
			  , IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				   FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
					FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))) KELUHAN
			  , (SELECT tv.KEADAAN_UMUM
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) KEADAAN_UMUM
			  , (SELECT tv.FREKUENSI_NAFAS
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) FREKUENSI_NAFAS
			   , (SELECT tv.FREKUENSI_NADI
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) FREKUENSI_NADI
			  , (SELECT tv.SUHU
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0 
						ORDER BY tv.TANGGAL DESC LIMIT 1) SUHU
			  , CONCAT((SELECT tv.SISTOLIK
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1),'/'
			  , (SELECT tv.DISTOLIK
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1)) DARAH
			  , (SELECT DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%H:%i:%s')
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0 
						ORDER BY tv.TANGGAL DESC LIMIT 1) JAM
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
						LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP AND pg.PROFESI !=4
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) PERAWAT
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y') TGLPERIKSA ,DATE_FORMAT(pk.MASUK,'%H:%i:%s') JAMPERIKSA
			  , IF(master.getDiagnosaPasien(pp.NOMOR) IS NULL,dg.DIAGNOSIS,master.getDiagnosaPasien(pp.NOMOR)) DIAGNOSIS
			  , CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL
			  , IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))) RIWAYATPENYAKIT
			  , IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))) RPS
			 , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pp.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1) FISIK
			  , (SELECT  REPLACE(GROUP_CONCAT(DISTINCT(ib.NAMA)),',','; ')
						FROM layanan.farmasi lf
							  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
							, pendaftaran.kunjungan pk
						     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
						     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
							  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
							  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
							  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
						     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
						   , pendaftaran.pendaftaran pp1
							  LEFT JOIN master.pasien ps ON pp1.NORM=ps.NORM
							, inventory.barang ib
							, pembayaran.rincian_tagihan rt
						WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
							AND pk.NOPEN=pp1.NOMOR AND lf.FARMASI=ib.ID
							AND pp1.NORM=pp.NORM AND pp1.NOMOR!=pp.NOMOR
							AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') RIWAYATOBAT
				, (SELECT GROUP_CONCAT(CONCAT('=',ib.NAMA, '; ',ref.DESKRIPSI,'=')) 
					FROM layanan.farmasi lf
						  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
						, pendaftaran.kunjungan pk
					     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
					     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
						  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
						  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
						  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
					     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
					   , pendaftaran.pendaftaran pp
						  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
						, inventory.barang ib
						, pembayaran.rincian_tagihan rt
					WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
						AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
						AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG!=1
						AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') OBATRJ
				, CONCAT('Anamnesis / Riwayat Penyakit Sekarang : ',IFNULL(anm.DESKRIPSI,''),'\r',
							'Keluhan Utama : ',IFNULL(IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
							   FROM medicalrecord.keluhan_utama ku
								LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
								WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
								FROM medicalrecord.keluhan_utama ku
								LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
								WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))),''),'\r',
							'Riwayat Penyakit Terdahulu : ',IFNULL(rpp.DESKRIPSI,''),'\r',
							IFNULL((SELECT sub.SUBYEKTIF
							FROM medicalrecord.cppt sub
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=sub.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY sub.TANGGAL DESC LIMIT 1),'')) SUBYEKTIF
				, CONCAT('Pemeriksaan Umum : ','\r',
							'Keadaan Umum : ',IFNULL(tv.KEADAAN_UMUM,''),'; ','Kesadaran : ',IFNULL(tv.KESADARAN,''),'; ','Tekanan Darah : ',IFNULL(tv.SISTOLIK,''),'/',IFNULL(tv.DISTOLIK,''),
							'; ','Nadi : ',IFNULL(tv.FREKUENSI_NADI,''),'; ','Pernafasan : ',IFNULL(tv.FREKUENSI_NAFAS,''),'; ','Suhu Tubuh : ',IFNULL(tv.SUHU,''),'\r',
							IFNULL((SELECT REPLACE(REPLACE(IFNULL(pf1.DESKRIPSI,''),'<div','<br><div'),'<p','<br><p')
						   FROM medicalrecord.pemeriksaan_fisik pf1
							WHERE pf1.PENDAFTARAN=pp.NOMOR
							ORDER BY pf1.TANGGAL DESC LIMIT 1),''),'\r',
							IFNULL((SELECT oby.OBYEKTIF
							FROM medicalrecord.cppt oby
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=oby.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY oby.TANGGAL DESC LIMIT 1),'')) OBYEKTIF
				, CONCAT(IF(master.getDiagnosaPasien(pp.NOMOR) IS NULL,IFNULL(dg.DIAGNOSIS,''),master.getDiagnosaPasien(pp.NOMOR)),'\r',
							IFNULL((SELECT ass.ASSESMENT
							FROM medicalrecord.cppt ass
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY ass.TANGGAL DESC LIMIT 1),'')) ASSESMENT
				, CONCAT(IFNULL(rcnt.DESKRIPSI,''),'\r',
							IFNULL((SELECT pln.PLANNING
							FROM medicalrecord.cppt pln
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pln.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY pln.TANGGAL DESC LIMIT 1),'')) PLANNING
				, (SELECT ins.INSTRUKSI
					FROM medicalrecord.cppt ins
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR 
					ORDER BY ins.TANGGAL DESC LIMIT 1) INSTRUKSI
				, IF(master.getNamaLengkapPegawai(dpjp.NIP) IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(dpjp.NIP)) DOKTER
				, IF(dpjp.NIP IS NULL,drreg.NIP,dpjp.NIP) NIP
				, master.getJawabanKonsul(pk.NOPEN) KONSUL
				, master.getTindakanKunjungan(pk.NOMOR) TINDAKAN
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.wilayah wl ON p.TEMPAT_LAHIR=wl.ID
				, pendaftaran.kunjungan pk
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
			  	  LEFT JOIN master.referensi smf ON ds.SMF=smf.ID AND smf.JENIS=26
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_fungsional sfu ON pk.NOMOR=sfu.KUNJUNGAN AND sfu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.anamnesis anm ON pk.NOMOR=anm.KUNJUNGAN AND anm.`STATUS`!=0
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN medicalrecord.rps rps ON pk.NOMOR=rps.KUNJUNGAN AND rps.`STATUS`!=0
				  LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP AND pg.PROFESI !=4
				, master.ruangan r
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pp.NORM=p.NORM AND pk.RUANGAN=r.ID
			  AND pk.NOPEN=PNOPEN AND pk.NOMOR=PKUNJUNGAN
			  GROUP BY pk.NOMOR;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakObatRJ
DROP PROCEDURE IF EXISTS `CetakObatRJ`;
DELIMITER //
CREATE PROCEDURE `CetakObatRJ`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT  pk.NOPEN, ib.NAMA NAMAOBAT, lf.JUMLAH, IF(ref.DESKRIPSI IS NULL, lf.ATURAN_PAKAI, ref.DESKRIPSI) ATURANPAKAI
		, lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
		FROM layanan.farmasi lf
			  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
			, pendaftaran.kunjungan pk
		     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
		     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
			  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
			  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
		     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
		   , pendaftaran.pendaftaran pp
			  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
			, inventory.barang ib
			, pembayaran.rincian_tagihan rt
		WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
			AND pk.NOPEN=PNOPEN 
			AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'
		ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.CetakRavenTest
DROP PROCEDURE IF EXISTS `CetakRavenTest`;
DELIMITER //
CREATE PROCEDURE `CetakRavenTest`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT INST.*
	  , DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i:%s') TGLSKRG
	  , LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(pp.NORM) NAMALENGKAP, IF(p.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JENISKELAMIN
	  , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',master.getCariUmur(pk.MASUK,p.TANGGAL_LAHIR),')') TGL_LAHIR
	  , kp.NOMOR KONTAK, p.ALAMAT PSALAMAT, rvn.KUNJUNGAN, rvn.SKORING, rvn.PRESENTIL, rvn.INTERPRETASI, rvn.ANJURAN
	  , DATE_FORMAT(rvn.DIBUAT_TANGGAL, '%d-%m-%Y %H:%i:%s') TGLPEREKAMAN, rvn.OLEH
	  , master.getNamaLengkapPegawai(md.NIP) DPJP, md.NIP
	FROM medicalrecord.pemeriksaan_raven_test rvn
		 LEFT JOIN pendaftaran.kunjungan pkj ON rvn.KUNJUNGAN=pkj.NOMOR
	  , pendaftaran.kunjungan pk
	    LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
	    LEFT JOIN master.dokter md ON pk.DPJP=md.ID
	  , pendaftaran.pendaftaran pp
	    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	    LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	  , master.pasien p
	    LEFT JOIN master.kontak_pasien kp ON p.NORM = kp.NORM
	  , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE rvn.KUNJUNGAN=PKUNJUNGAN 
	AND pk.NOMOR = pkj.NOMOR 
	AND pk.NOPEN = pp.NOMOR 
	AND p.NORM = pp.NORM
	GROUP BY rvn.KUNJUNGAN;
END//
DELIMITER ;

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
		, kb.DESKRIPSI NEGARA, p.KEWARGANEGARAAN
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
		  LEFT JOIN master.negara kb ON p.KEWARGANEGARAAN=kb.ID
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

-- Dumping structure for procedure medicalrecord.cetakSuratKontrol
DROP PROCEDURE IF EXISTS `cetakSuratKontrol`;
DELIMITER //
CREATE PROCEDURE `cetakSuratKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT
		 , pj.JENIS IDPENJAMIN
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE(jk.DIBUAT_TANGGAL),DATE(pri.DIBUAT_TANGGAL)) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drk.NIP),master.getNamaLengkapPegawai(drso.NIP)) DOKTER
	    , IFNULL(drk.NIP,drso.NIP) NIP
	    , IFNULL(smf.DESKRIPSI,smfso.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING
	    , IF(master.getDiagnosa(p.NOMOR, 1) IS NULL,CONCAT(dms.CODE,' (',dms.STR,')'),CONCAT(master.getKodeDiagnosa(p.NOMOR,1),master.getDiagnosa(p.NOMOR, 1))) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, pri.DESKRIPSI KETSO, jk.DESKRIPSI KET
	    , rt.DESKRIPSI RENCANA_TERAPI
	    , IF(jk.RUANGAN IS NULL, CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR), CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)) NOSURAT
	    , IF(jk.RUANGAN IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(jk.RUANGAN IS NULL, 1 , 2) JENISKONTROL
	    , jrp.DESKRIPSI JENIS_RUANG_PERAWATAN, jp.DESKRIPSI JENIS_PERAWATAN
	    FROM pendaftaran.kunjungan k
	    LEFT JOIN master.dokter drso ON drso.ID=k.DPJP
	    LEFT JOIN master.dokter_smf ds ON ds.DOKTER=drso.ID
	    LEFT JOIN master.referensi smfso ON smfso.ID=ds.SMF AND smfso.JENIS=26
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
  		 LEFT JOIN `master`.ruangan r ON jk.RUANGAN = r.ID
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.dokter drk ON drk.ID=drtj.DPJP_RS
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0  
		 LEFT JOIN master.referensi jrp ON pri.JENIS_RUANG_PERAWATAN=jrp.ID AND jrp.JENIS=242
  		 LEFT JOIN master.referensi jp ON pri.JENIS_PERAWATAN=jp.ID AND jp.JENIS=243 		
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_1998','ICD10_2020') AND dms.TTY !='HT' AND dms.TTY !='PS'
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER       
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2
	GROUP BY k.NOMOR;
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
		 AND r.ID=k.RUANGAN AND r.JENIS_KUNJUNGAN NOT IN (2,3,4,5,11,12,13,14,15)
		 AND p.NORM=PNORM
		 ORDER BY k.MASUK DESC;
END//
DELIMITER ;

-- Dumping structure for procedure medicalrecord.getResumeTindakanMedis
DROP PROCEDURE IF EXISTS `getResumeTindakanMedis`;
DELIMITER //
CREATE PROCEDURE `getResumeTindakanMedis`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT tm.ID, t.NAMA, tm.RESUMEMEDIS
	 FROM pembayaran.rincian_tagihan rt
	  , pembayaran.tagihan_pendaftaran tp
	  , layanan.tindakan_medis tm
	  , master.tindakan t
	  , pendaftaran.kunjungan pk
	  , master.ruangan r
	 WHERE rt.JENIS=3 AND rt.`STATUS`!=0 AND rt.TAGIHAN=tp.TAGIHAN AND tp.UTAMA=1 AND tp.`STATUS`!=0
	  AND tp.PENDAFTARAN=PNOPEN
	  AND rt.REF_ID=tm.ID AND tm.`STATUS`!=0
	  AND tm.TINDAKAN=t.ID AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
	  AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN!=4
	GROUP BY t.ID
	ORDER BY t.NAMA;
END//
DELIMITER ;

-- Dumping structure for function medicalrecord.getHasilLaboratoriumResume
DROP FUNCTION IF EXISTS `getHasilLaboratoriumResume`;
DELIMITER //
CREATE FUNCTION `getHasilLaboratoriumResume`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TEXT;
   
	SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) INTO HASIL
	  FROM medicalrecord.`resume` r, 
	        JSON_TABLE(r.HASIL_LAB,
	         '$[*]' COLUMNS(
	                ID CHAR(12) PATH '$.ID'
	            )   
	       ) AS hl
	     , layanan.hasil_lab hlab
	       LEFT JOIN master.parameter_tindakan_lab ptl ON hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
			 LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
	WHERE r.NOPEN=PNOPEN AND hl.ID=hlab.ID AND hlab.`STATUS`!=0 ;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function medicalrecord.getHasilPenunjang
DROP FUNCTION IF EXISTS `getHasilPenunjang`;
DELIMITER //
CREATE FUNCTION `getHasilPenunjang`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE VHASIL TEXT;
   
   SELECT 
		  	CONCAT(
			  'Kesimpulan EEG : ',IFNULL((SELECT  
				eeg.KESIMPULAN
			FROM 
		  		medicalrecord.pemeriksaan_eeg eeg, 
		  		pendaftaran.kunjungan pk, 
		  		pendaftaran.pendaftaran pp
			WHERE 
		  		pp.NOMOR=PNOPEN AND 
		  		pk.NOPEN=pp.NOMOR AND 
		  		eeg.KUNJUNGAN=pk.NOMOR AND 
		  		eeg.STATUS !=0 
				ORDER BY eeg.TANGGAL_INPUT ASC LIMIT 1),''),'\r',
				'Impresion EMG : ',IFNULL((SELECT  
					emg.IMPRESSION 
				FROM 
			  		medicalrecord.pemeriksaan_emg emg, 
			  		pendaftaran.kunjungan pk, 
			  		pendaftaran.pendaftaran pp
				WHERE 
			  		pp.NOMOR=PNOPEN AND 
			  		pk.NOPEN=pp.NOMOR AND 
			  		emg.KUNJUNGAN=pk.NOMOR AND 
				  	emg.STATUS !=0 
					ORDER BY emg.DIBUAT_TANGGAL ASC LIMIT 1),''),'\r',
				'Interpretasi Raven Test : ',IFNULL((SELECT  
					rvn.INTERPRETASI 
				FROM 
			  		medicalrecord.pemeriksaan_raven_test rvn, 
			  		pendaftaran.kunjungan pk, 
			  		pendaftaran.pendaftaran pp
				WHERE 
			  		pp.NOMOR=PNOPEN AND 
			  		pk.NOPEN=pp.NOMOR AND 
			  		rvn.KUNJUNGAN=pk.NOMOR AND 
			  		rvn.STATUS !=0 
					ORDER BY rvn.DIBUAT_TANGGAL ASC LIMIT 1),'')) HASIL
   				INTO VHASIL
					;
  
	IF VHASIL IS NULL THEN
		RETURN '';
	ELSE
		RETURN VHASIL;
	END IF;
END//
DELIMITER ;

-- Dumping structure for function medicalrecord.getHasilRadiologiResume
DROP FUNCTION IF EXISTS `getHasilRadiologiResume`;
DELIMITER //
CREATE FUNCTION `getHasilRadiologiResume`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TEXT;
   
	SELECT GROUP_CONCAT(t.NAMA,' = ',hr.KESAN) INTO HASIL
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
		AND tm.TINDAKAN=t.ID;
 
  RETURN HASIL;
END//
DELIMITER ;
