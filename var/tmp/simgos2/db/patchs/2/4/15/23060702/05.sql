USE `bpjs`;

-- Dumping structure for procedure bpjs.CetakSEP
DROP PROCEDURE IF EXISTS `CetakSEP`;
DELIMITER //
CREATE PROCEDURE `CetakSEP`(
	IN `PSEP` VARCHAR(20)
)
BEGIN
	SELECT inst.NAMA NAMAINSTANSI,k.noSEP NOMORSEP, DATE_FORMAT(k.tglSEP,'%d-%m-%Y') TGLSEP, IF(k.klsRawatNaik=0,klsr.deskripsi,klsn.deskripsi) klsRawat
		  , CONCAT(p.noKartu, '  ( MR. ',p.norm,' )') NOMORKARTU, p.norm NORM, IF(k.poliTujuan IS NULL OR k.poliTujuan='',pls.nama,pl.nama) poliTujuan, mr.DESKRIPSI UNITPELAYANAN
		 , IF(k.jmlCetak > 0,CONCAT('*Cetakan Ke ',k.jmlCetak, ' ',DATE_FORMAT(k.tglSEP,'%d-%m-%Y %H:%i:%s')),'') CETAKAN , k.catatan CATATAN
		 , p.nmJenisPeserta PESERTA, p.nama NAMALENGKAP, CONCAT(DATE_FORMAT(p.tglLahir,'%d-%m-%Y'), '  Kelamin : ',IF(p.sex='L','Laki-laki','Perempuan')) TGL_LAHIR
		 , IF(k.jenisPelayanan=1,'Rawat Inap','Rawat Jalan') JENISRAWAT
		 , tjk.deskripsi TJKUNJ, proc.deskripsi PROC, kdp.deskripsi PENUNJANG, assp.deskripsi ASPEL
		 , IF(p.sex='L','Laki-laki','Perempuan') JENISKELAMIN, p.nmKelas KELAS
		 , CONCAT(r.CODE,' (',r.STR,')') DIAGNOSA, rp.NAMA RUJUKAN
		 , p.prolanisPRB PRB, penj.DESKRIPSI PENJAMIN
		 , IF(k.cob=0,'-','Ya') COB, k.noTelp NOTELP
		 , IF(k.katarak=1,'* PASIEN OPERASI KATARAK','') KATARAK
		 , dr.nama DOKTER
		 , (IF(k.klsRawatNaik='0',(SELECT ref.DESKRIPSI
				FROM pendaftaran.kunjungan kj1
					 LEFT JOIN master.ruang_kamar_tidur rkt ON kj1.RUANG_KAMAR_TIDUR=rkt.ID
					 LEFT JOIN master.ruang_kamar rk ON rk.ID=rkt.RUANG_KAMAR
				    LEFT JOIN master.referensi ref ON rk.KELAS=ref.ID AND ref.JENIS=19
			   WHERE kj1.NOPEN=tp.NOPEN AND kj1.RUANG_KAMAR_TIDUR!=0 
				AND kj1.`STATUS`!=0 ORDER BY kj1.MASUK DESC LIMIT 1),klsn.deskripsi)) KLSRAWAT
		 , '' POLIPERUJUK
	FROM bpjs.kunjungan k
		  LEFT JOIN bpjs.peserta p ON k.noKartu = p.noKartu
		  LEFT JOIN master.ppk rp ON k.ppkRujukan = rp.BPJS
		  LEFT JOIN master.mrconso r ON k.diagAwal = r.CODE AND r.SAB IN ('ICD10_2020','ICD10_1998') AND r.TTY !='HT' AND r.TTY !='PS'
		  LEFT JOIN pendaftaran.penjamin pp ON k.noSEP=pp.NOMOR
		  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON srp.NOMOR=pp.NOMOR
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOPEN=tp.NOPEN
		  LEFT JOIN master.ruangan mr ON tp.RUANGAN=mr.ID AND mr.JENIS=5
		  LEFT JOIN master.referensi penj ON k.penjamin=penj.ID AND penj.JENIS=80
		  LEFT JOIN bpjs.poli pl ON k.poliTujuan=pl.kode
		  LEFT JOIN bpjs.dpjp dr ON k.dpjpSKDP=dr.kode
		  LEFT JOIN bpjs.referensi tjk ON k.tujuanKunj=tjk.kode AND tjk.jenis_referensi_id=7
		  LEFT JOIN bpjs.referensi proc ON k.flagProcedure =proc.kode AND proc.jenis_referensi_id=8
		  LEFT JOIN bpjs.referensi kdp ON k.kdPenunjang=kdp.kode AND kdp.jenis_referensi_id=9
		  LEFT JOIN bpjs.referensi assp ON k.assesmentPel=assp.kode AND assp.jenis_referensi_id=10
		  LEFT JOIN bpjs.referensi klsr ON k.klsRawat=klsr.kode AND klsr.jenis_referensi_id=3
		  LEFT JOIN bpjs.referensi klsn ON k.klsRawatNaik=klsn.kode AND klsn.jenis_referensi_id=11
		  LEFT JOIN penjamin_rs.dpjp drs ON drs.DPJP_PENJAMIN=k.dpjpSKDP AND drs.PENJAMIN=2 AND drs.`STATUS`=1
		  LEFT JOIN master.dokter md ON drs.DPJP_RS=md.ID AND md.`STATUS`=1
		  LEFT JOIN master.dokter_smf mds ON md.ID=mds.DOKTER AND mds.`STATUS`=1		  
		  LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=mds.SMF AND pss.PENJAMIN=2
		  LEFT JOIN bpjs.poli pls ON pss.SUB_SPESIALIS_PENJAMIN=pls.kode
		, (SELECT mp.NAMA 
			FROM aplikasi.instansi ai
				, master.ppk mp
			WHERE ai.PPK=mp.ID) inst
	WHERE k.cetak= 0 AND k.noSEP=PSEP
	GROUP BY k.noSEP;
END//
DELIMITER ;

-- Dumping structure for procedure bpjs.executeTempatTidur
DROP PROCEDURE IF EXISTS `executeTempatTidur`;
DELIMITER //
CREATE PROCEDURE `executeTempatTidur`()
BEGIN
	DECLARE vkodekelas CHAR(3);
	DECLARE vkoderuang SMALLINT;
	DECLARE vnamaruang VARCHAR(100);
	DECLARE vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita SMALLINT;
	
	DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
	DECLARE CR_EXEC CURSOR FOR
		SELECT k.kelas kodekelas
			 , t.IDKAMAR koderuang
			 , CONCAT(t.SUBUNIT, ' - ', t.KAMAR) namaruang
			 , (t.TTLAKI + t.TTPEREMPUAN) kapasitas
			 , (t.TTLAKI + t.TTPEREMPUAN) - (t.JMLLAKI + t.JMLPEREMPUAN) tersedia
			 , IF(t.JMLLAKI > 0 AND t.JMLPEREMPUAN = 0, t.TTLAKI - t.JMLLAKI, 0) tersediapria
			 , IF(t.JMLPEREMPUAN > 0 AND t.JMLLAKI = 0, t.TTPEREMPUAN - t.JMLPEREMPUAN, 0) tersediawanita
			 , IF(t.JMLLAKI > 0 AND t.JMLPEREMPUAN > 0,  (t.TTLAKI + t.TTPEREMPUAN) - (t.JMLLAKI + t.JMLPEREMPUAN), 0) tersediapriawanita
	  FROM informasi.tempat_tidur_kemkes t,
	  		 bpjs.map_kelas k
	 WHERE k.kelas_rs = t.IDKELAS AND DATE(t.LASTUPDATED)=DATE(SYSDATE())
	   AND NOT t.INSTALASI IS NULL;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
	OPEN CR_EXEC;
					
	EXIT_EXEC: LOOP
		FETCH CR_EXEC INTO vkodekelas, vkoderuang, vnamaruang, vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita;
						
		IF EXEC_NOT_FOUND THEN
			LEAVE EXIT_EXEC;
		END IF;

		SET Vtersedia = IF(vtersedia < 0, 0, vtersedia);
		SET vtersediapriawanita = IF(vtersediapriawanita < 0, 0, vtersediapriawanita);
		SET vtersediapria = IF(vtersediapria < 0, 0, vtersediapria);
		SET vtersediawanita = IF(vtersediawanita < 0, 0, vtersediawanita);
		
		IF EXISTS(SELECT 1 
				FROM bpjs.tempat_tidur tt
			  WHERE tt.kodekelas = vkodekelas
			    AND tt.koderuang = vkoderuang) THEN
			UPDATE bpjs.tempat_tidur
			   SET namaruang = vnamaruang
			   	 , kapasitas = vkapasitas
					 , tersedia = vtersedia
					 , tersediapria = vtersediapria
					 , tersediawanita = vtersediawanita
					 , tersediapriawanita = vtersediapriawanita
					 , kirim = 1
			  WHERE kodekelas = vkodekelas
			    AND koderuang = vkoderuang;
		ELSE
			INSERT INTO bpjs.tempat_tidur(kodekelas, koderuang, namaruang, kapasitas, tersedia, tersediapria, tersediawanita, tersediapriawanita)
				  VALUES (vkodekelas, vkoderuang, vnamaruang, vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita);
		END IF;
	END LOOP;
	
	CLOSE CR_EXEC;
END//
DELIMITER ;

-- Dumping structure for procedure bpjs.RencanaKontrol
DROP PROCEDURE IF EXISTS `RencanaKontrol`;
DELIMITER //
CREATE PROCEDURE `RencanaKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT, inst.BPJS KODEBPJS
		 , jk.NOMOR , pj.JENIS IDPENJAMIN
		 , CONCAT(pst.noKartu, '  ( MR. ',p.NORM,' )') NOMORKARTU, pst.norm NORMBPJS, pst.noKartu NOBPJS
		 , pst.nmJenisPeserta PESERTA, CONCAT(pst.nama,'  (',IF(pst.sex='L','Laki-laki','Perempuan'),')') NAMALENGKAP1
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE_FORMAT(jk.DIBUAT_TANGGAL,'%d %M %Y'),DATE_FORMAT(pri.DIBUAT_TANGGAL,'%d %M %Y')) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drk.NIP),master.getNamaLengkapPegawai(drso.NIP)) DOKTER
	    , IFNULL(drk.NIP,drso.NIP) NIP
	    , bpjs.getDPJP(drpj.DPJP_PENJAMIN) DRSEP
	    , bpjs.getDPJP(drtj.DPJP_PENJAMIN) DRKONTROL
	    , pbpjs.nama SPESIALISTIK
	    , IFNULL(smf.DESKRIPSI,smfso.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING
	   # , IF(master.getDiagnosa(p.NOMOR, 1) IS NULL,CONCAT(dms.CODE,' (',dms.STR,')'),CONCAT(master.getKodeDiagnosa(p.NOMOR,1),master.getDiagnosa(p.NOMOR, 1))) DIAGMASUK
	   , IF(dg.ID IS NULL, CONCAT(dms.CODE,'- ',dms.STR), `master`.getICD10(dg.KODE)) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, pri.DESKRIPSI KETSO, jk.DESKRIPSI KET
	    , IF(rkbpjs.noSurat IS NULL, DATE_FORMAT(rkbpjs1.tglRencanaKontrol, '%d %M %Y'), DATE_FORMAT(rkbpjs.tglRencanaKontrol, '%d %M %Y')) JADWALBPJS
	    , DATE_FORMAT(jk.DIBUAT_TANGGAL, '%m') BLN, DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y') THN
	    , rt.DESKRIPSI RENCANA_TERAPI, rk.JENIS_KUNJUNGAN
	    , IF(jk.RUANGAN IS NULL, IFNULL(pri.NOMOR_REFERENSI,'Nomor Surat BPJS Wajib diterbitkan'),
		 		IF(IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat) IS NULL,
				  IF(rk.JENIS_KUNJUNGAN=3,'Pasca Ranap wajib terbit nomor surat kontrol BPJS',
					 IF(bpn.kode=pss.SUB_SPESIALIS_PENJAMIN,'Nomor Surat BPJS Wajib diterbitkan',CONCAT('K',inst.BPJS,DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR))), 
						IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat))) NOSBPJS	 
	    , IF(jk.RUANGAN IS NULL, CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR), CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)) NOSURAT
	    , IF(jk.RUANGAN IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(jk.RUANGAN IS NULL, 1 , 2) JENISKONTROL
	    , IF(rk.JENIS_KUNJUNGAN=3,pj.NOMOR,IFNULL(bk.noRujukan,'')) NORJK
		 , IF(rk.JENIS_KUNJUNGAN=3,DATE_FORMAT(p.TANGGAL,'%d-%m-%Y'),IFNULL(DATE_FORMAT(bk.tglRujukan, '%d-%m-%Y'),'')) TGLRJK
		 , IF(rk.JENIS_KUNJUNGAN!=3,DATE_FORMAT(DATE_ADD(IFNULL(bk.tglRujukan,srp.TANGGAL), INTERVAL 90 DAY), '%d-%m-%Y'),'1 Kali pada kunjungan pertama Setelah Rawat Inap') MASABERLAKU
		 , IF(rk.JENIS_KUNJUNGAN!=3,srp.BAGIAN_DOKTER,smf.DESKRIPSI) TUJUANRUJUK, bpn.nama, bpn.kode
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
       LEFT JOIN bpjs.poli pbpjs ON pss.SUB_SPESIALIS_PENJAMIN=pbpjs.kode
      # LEFT JOIN bpjs.dpjp drtjn ON drtj.DPJP_PENJAMIN=drtjn.kode
  		 LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0
  		 LEFT JOIN master.referensi jrp ON pri.JENIS_RUANG_PERAWATAN=jrp.ID AND jrp.JENIS=242
  		 LEFT JOIN master.referensi jp ON pri.JENIS_PERAWATAN=jp.ID AND jp.JENIS=243  		 
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs ON jk.NOMOR_REFERENSI=rkbpjs.noSurat AND rkbpjs.`status` !=0
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs1 ON pri.NOMOR_REFERENSI=rkbpjs1.noSurat AND rkbpjs1.`status` !=0
  		 LEFT JOIN `master`.ruangan rk ON k.RUANGAN = rk.ID
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON bk.noRujukan=srp.NOMOR AND srp.NORM=p.NORM
       LEFT JOIN bpjs.poli bpn ON srp.BAGIAN_DOKTER=bpn.nama
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_2020','ICD10_1998') AND dms.TTY !='HT' AND dms.TTY !='PS'
       LEFT JOIN medicalrecord.diagnosa dg ON p.NOMOR=dg.NOPEN AND dg.UTAMA=1 AND dg.INA_GROUPER=0 AND dg.`STATUS`!=0
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER
       LEFT JOIN penjamin_rs.dpjp drpj ON dr.ID=drpj.DPJP_RS AND drpj.PENJAMIN=2
    #   LEFT JOIN bpjs.dpjp drskdp ON drpj.DPJP_PENJAMIN=drskdp.kode
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT, mp.BPJS
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
		, DATE_FORMAT(ruj.tglRencanaKunjungan,'%d-%m-%Y') tglRencanaKunjungan, DATE_FORMAT(ruj.tglBerlakuKunjungan,'%d-%m-%Y') tglBerlakuKunjungan
	FROM pendaftaran.rujukan_keluar rj
		  LEFT JOIN master.referensi ref ON ref.ID = rj.JENIS AND ref.JENIS = 86
		  LEFT JOIN master.ppk ppk ON rj.TUJUAN = ppk.ID
		  LEFT JOIN master.referensi rrj ON rrj.JENIS = 70 AND rrj.ID = rj.TUJUAN_RUANGAN
		  LEFT JOIN master.dokter dok ON rj.DOKTER = dok.ID
		  LEFT JOIN master.mrconso mr ON rj.DIAGNOSA = mr.CODE AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT')
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

-- Dumping structure for function bpjs.getDPJP
DROP FUNCTION IF EXISTS `getDPJP`;
DELIMITER //
CREATE FUNCTION `getDPJP`(
	`PKODE` CHAR(15)
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT dp.nama INTO HASIL FROM bpjs.dpjp dp WHERE dp.kode= PKODE LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;