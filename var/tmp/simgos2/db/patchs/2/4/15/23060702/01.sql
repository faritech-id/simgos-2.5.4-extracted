USE `master`;

-- Dumping structure for function master.getAlamatPasien
DROP FUNCTION IF EXISTS `getAlamatPasien`;
DELIMITER //
CREATE FUNCTION `getAlamatPasien`(
	`PNORM` VARCHAR(8)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT CONCAT(IF(p.ALAMAT='' OR p.ALAMAT IS NULL,''
		, CONCAT(p.ALAMAT,' ')),IF(p.RT='' OR p.RT IS NULL,''
		, CONCAT('RT. ',p.RT,' ')),IF(p.RW='' OR p.RW IS NULL,''
		, CONCAT('RW. ',p.RW,' '))
		, IF(p.WILAYAH='' OR p.WILAYAH IS NULL,''
		, CONCAT('Kel/Desa .',kel.DESKRIPSI,' '
		, 'Kec. ',kec.DESKRIPSI,' '
		, 'Kab/Kota. ',kab.DESKRIPSI,' '
		, 'prov. ',prov.DESKRIPSI)))
		 INTO HASIL
	  FROM master.pasien p
	  LEFT JOIN master.wilayah kel ON kel.ID=p.WILAYAH
	  LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
	  LEFT JOIN master.wilayah kab ON kab.ID = LEFT(p.WILAYAH, 4)
	  LEFT JOIN master.wilayah prov ON prov.ID = LEFT(p.WILAYAH, 2)
	 WHERE p.NORM = PNORM;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getAturanPakai
DROP FUNCTION IF EXISTS `getAturanPakai`;
DELIMITER //
CREATE FUNCTION `getAturanPakai`(
	`PKODE` VARCHAR(250)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VATURAN_PAKAI VARCHAR(250);
	
	SELECT DESKRIPSI INTO VATURAN_PAKAI
	  FROM referensi ref 
	WHERE ref.JENIS = 41 
	  AND CONCAT('',ref.ID,'') = PKODE;
	 
	IF VATURAN_PAKAI IS NULL THEN
		SET VATURAN_PAKAI = PKODE;
	END IF;

	RETURN VATURAN_PAKAI;
END//
DELIMITER ;

-- Dumping structure for function master.getAturanPakai2
DROP FUNCTION IF EXISTS `getAturanPakai2`;
DELIMITER //
CREATE FUNCTION `getAturanPakai2`(`PFREKUENSI` INT, `DOSIS` CHAR(50), `PRUTE` INT) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VATURAN_PAKAI VARCHAR(250);
	DECLARE VFREKUENSI,VRUTE VARCHAR(100);
	
	SELECT f.FREKUENSI INTO VFREKUENSI FROM master.frekuensi_aturan_resep f WHERE f.ID = PFREKUENSI;
	IF VFREKUENSI IS NULL THEN
		SET VFREKUENSI = '';
	END IF;
	
	SELECT r.DESKRIPSI INTO VRUTE FROM master.referensi r WHERE r.JENIS = 217 AND r.ID = PRUTE;
	IF VRUTE IS NULL THEN
		SET VRUTE = '';
	END IF;
	
	RETURN CONCAT(VFREKUENSI,'  ',DOSIS,'  ',VRUTE);
END//
DELIMITER ;

-- Dumping structure for function master.getBulanIndo
DROP FUNCTION IF EXISTS `getBulanIndo`;
DELIMITER //
CREATE FUNCTION `getBulanIndo`(`TANGGAL` DATETIME) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN

	DECLARE varhasil VARCHAR(50);
	
	SELECT 
		    CASE MONTH(TANGGAL) 
		      WHEN 1 THEN 'Januari' 
		      WHEN 2 THEN 'Februari' 
		      WHEN 3 THEN 'Maret' 
		      WHEN 4 THEN 'April' 
		      WHEN 5 THEN 'Mei' 
		      WHEN 6 THEN 'Juni' 
		      WHEN 7 THEN 'Juli' 
		      WHEN 8 THEN 'Agustus' 
		      WHEN 9 THEN 'September'
		      WHEN 10 THEN 'Oktober' 
		      WHEN 11 THEN 'November' 
		      WHEN 12 THEN 'Desember' 
		    END INTO varhasil;
	
	RETURN varhasil;
	
END//
DELIMITER ;

-- Dumping structure for function master.getCariUmur
DROP FUNCTION IF EXISTS `getCariUmur`;
DELIMITER //
CREATE FUNCTION `getCariUmur`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE desk VARCHAR(50);
	DECLARE thn,bln,hari INTEGER;	
	
	SET thn = YEAR(PTGLREG) - YEAR(PTGLLAHIR);
	IF DATE_ADD(PTGLLAHIR, INTERVAL thn YEAR) > PTGLREG THEN
		SET thn = thn - 1;
	END IF;
	
	SET bln = (YEAR(PTGLREG) * 12 + MONTH(PTGLREG)) - (YEAR(PTGLLAHIR) * 12 + MONTH(PTGLLAHIR));
	IF DATE_ADD(PTGLLAHIR, INTERVAL bln MONTH) > PTGLREG THEN
		SET bln = bln - 1;
	END IF;	
	SET bln = bln - (thn * 12);
	IF MONTH(PTGLREG) = 2 AND DAY(PTGLREG) >= 28 AND DAY(PTGLLAHIR) > 28 THEN
		SET bln = bln - 1;
	END IF;
	
	SET hari = DAY(LAST_DAY(PTGLLAHIR)) - DAY(PTGLLAHIR);
	IF DAY(PTGLREG) >= DAY(PTGLLAHIR) THEN
		SET hari = DAY(PTGLREG) - DAY(PTGLLAHIR);
	ELSE
		SET hari = hari + DAY(PTGLREG);
	END IF;
	
	RETURN CONCAT(thn, ' Th/ ', bln, ' bl/ ', hari, ' hr');
END//
DELIMITER ;

-- Dumping structure for function master.getDeskripsiICD
DROP FUNCTION IF EXISTS `getDeskripsiICD`;
DELIMITER //
CREATE FUNCTION `getDeskripsiICD`(
	`PCODE` CHAR(6)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT mr.STR INTO HASIL
		FROM master.mrconso mr
		WHERE mr.SAB IN ('ICD10_1998','ICD10_2020','ICD9CM_2005','ICD9CM_2020') AND TTY IN ('PX', 'PT') AND mr.CODE=PCODE
	GROUP BY mr.CODE
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosa
DROP FUNCTION IF EXISTS `getDiagnosa`;
DELIMITER //
CREATE FUNCTION `getDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, md.ID
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND mr.TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY md.ID
	) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa_meninggal md 
		WHERE mr.CODE=md.KODE AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT')
	GROUP BY md.ID) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaMR1
DROP FUNCTION IF EXISTS `getDiagnosaMR1`;
DELIMITER //
CREATE FUNCTION `getDiagnosaMR1`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR, ' (', mr.CODE,')') mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaPasien
DROP FUNCTION IF EXISTS `getDiagnosaPasien`;
DELIMITER //
CREATE FUNCTION `getDiagnosaPasien`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  GROUP_CONCAT(mrcode) INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'-[',mr.STR,'(',md.DIAGNOSA,')]') mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE  AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE
	ORDER BY  md.ID) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDokterTindakan
DROP FUNCTION IF EXISTS `getDokterTindakan`;
DELIMITER //
CREATE FUNCTION `getDokterTindakan`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(DOKTER SEPARATOR ';'),';',' ; ')  
	  INTO HASIL
	  FROM (
		SELECT DISTINCT(CONCAT('- ',master.getNamaLengkapPegawai(md.NIP))) DOKTER, md.ID
		  FROM master.dokter md,
			    layanan.petugas_tindakan_medis ptm,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k,
			    master.ruangan r 
		 WHERE md.ID = ptm.MEDIS 
		   AND ptm.JENIS IN (1,2) 
			AND ptm.`STATUS` = 1 
			AND ptm.TINDAKAN_MEDIS = tm.ID 
			AND tm.`STATUS` = 1
		   AND tm.KUNJUNGAN = k.NOMOR 
			AND k.`STATUS` != 0 
			AND k.RUANGAN = r.ID 
			AND r.JENIS = 5 
			AND r.JENIS_KUNJUNGAN NOT IN (0,4,5,11,13,14)
		   AND NOT EXISTS (SELECT 1 FROM layanan.pasien_pulang pp WHERE pp.NOPEN = k.NOPEN AND pp.DOKTER = ptm.MEDIS AND pp.`STATUS` != 0 LIMIT 1)
		   AND k.NOPEN = PNOPEN
     ) a
   ORDER BY DOKTER;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDPJP
DROP FUNCTION IF EXISTS `getDPJP`;
DELIMITER //
CREATE FUNCTION `getDPJP`(
	`PNOPEN` CHAR(10),
	`PJENIS` TINYINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT IF(PJENIS=1, d.NIP, `master`.getNamaLengkapPegawai(d.NIP)) INTO HASIL 
		FROM pendaftaran.kunjungan k 
			, master.dokter d 
			, `master`.ruangan r
		WHERE k.NOPEN=PNOPEN AND k.DPJP!=0 AND k.DPJP=d.ID AND k.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN =3
		AND d.`STATUS`!=0 
		ORDER BY k.MASUK  DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getFormatNorm
DROP FUNCTION IF EXISTS `getFormatNorm`;
DELIMITER //
CREATE FUNCTION `getFormatNorm`(
	`PNORM` INT,
	`PDELIMITER` CHAR(1)
) RETURNS char(11) CHARSET latin1
    DETERMINISTIC
BEGIN
	RETURN INSERT(INSERT(INSERT(LPAD(PNORM,8,'0'),3,0,PDELIMITER),6,0,PDELIMITER),9,0,PDELIMITER);
END//
DELIMITER ;

-- Dumping structure for function master.getHeaderKategoriBarang
DROP FUNCTION IF EXISTS `getHeaderKategoriBarang`;
DELIMITER //
CREATE FUNCTION `getHeaderKategoriBarang`(`PKATEGORI` CHAR(10)) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE KATEGORI CHAR(10);
	DECLARE HASIL VARCHAR(250);
   
   SET KATEGORI = CONCAT(PKATEGORI,'%');
   
	SELECT CONCAT(IF(LENGTH(KATEGORI) < 1,'Semua', i.NAMA),' - ',
			IF(LENGTH(KATEGORI) < 3,'Semua', u.NAMA),' - ',
			IF(LENGTH(KATEGORI) < 5,'Semua', k.NAMA)) INTO HASIL
	FROM inventory.kategori k
		  LEFT JOIN inventory.kategori u ON k.ID LIKE CONCAT(u.ID,'%') AND u.JENIS=2
		  LEFT JOIN inventory.kategori i ON k.ID LIKE CONCAT(i.ID,'%') AND i.JENIS=1
	WHERE k.ID LIKE KATEGORI AND k.JENIS=3
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getHeaderLaporan
DROP FUNCTION IF EXISTS `getHeaderLaporan`;
DELIMITER //
CREATE FUNCTION `getHeaderLaporan`(
	`PRUANG` CHAR(10)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE RUANG CHAR(10);
	DECLARE HASIL VARCHAR(250);
   
   SET RUANG = CONCAT(PRUANG,'%');
   
	SELECT CONCAT(
	      'INSTALASI : ',IF(LENGTH(RUANG) < 5,'Semua', i.DESKRIPSI),'\r',
			'UNIT : ',IF(LENGTH(RUANG) < 7,'Semua', u.DESKRIPSI),'\r',
			'SUB UNIT : ',IF(LENGTH(RUANG) < 9,'Semua', r.DESKRIPSI)) INTO HASIL
	FROM master.ruangan r
		  LEFT JOIN master.ruangan u ON r.ID LIKE CONCAT(u.ID,'%') AND u.JENIS=4
		  LEFT JOIN master.ruangan i ON r.ID LIKE CONCAT(i.ID,'%') AND i.JENIS=3
	WHERE r.ID LIKE RUANG AND r.JENIS=5
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getICD10
DROP FUNCTION IF EXISTS `getICD10`;
DELIMITER //
CREATE FUNCTION `getICD10`(
	`PCODE` CHAR(6)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT CONCAT(mr.CODE,'- ',mr.STR) mrcode INTO HASIL
		FROM master.mrconso mr
		WHERE mr.SAB IN ('ICD10_2020','ICD10_1998') AND TTY IN ('PX', 'PT') AND mr.CODE=PCODE
	GROUP BY mr.CODE
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getICD9CM
DROP FUNCTION IF EXISTS `getICD9CM`;
DELIMITER //
CREATE FUNCTION `getICD9CM`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r')  INTO HASIL
	FROM (SELECT CONCAT('- (',mr.CODE,') ', mr.STR) mrcode, pr.ID 
			FROM master.mrconso mr,
								medicalrecord.prosedur pr 
					WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=PNOPEN
					  AND mr.SAB ='ICD9CM_2005' AND TTY IN ('PX', 'PT') AND pr.INA_GROUPER=0
					GROUP BY pr.KODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getJawabanKonsul
DROP FUNCTION IF EXISTS `getJawabanKonsul`;
DELIMITER //
CREATE FUNCTION `getJawabanKonsul`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN

	
	
	DECLARE HASIL TEXT;
	
	SET SESSION group_concat_max_len = 1000000;
	
	SELECT (GROUP_CONCAT(KONSUL SEPARATOR ' \r'))
	  INTO HASIL
	  FROM (
		SELECT CONCAT('- Nomor Konsul : ',jk.KONSUL_NOMOR,' \r','- KSM/Bagian : ',smf.DESKRIPSI,' \r', '- Jawaban : ', jk.JAWABAN,' \r','- Anjuran : ', jk.ANJURAN,'; ',' \r') KONSUL
		  FROM pendaftaran.jawaban_konsul jk
				 LEFT JOIN master.dokter_smf mds ON jk.DOKTER = mds.DOKTER
				 LEFT JOIN master.referensi smf ON mds.SMF = smf.ID AND smf.JENIS = 26,
				 pendaftaran.kunjungan k
		 WHERE jk.KONSUL_NOMOR = k.REF
			AND k.`STATUS` != 0 AND jk.`STATUS`!=0
			AND k.NOPEN = PNOPEN
			GROUP BY jk.NOMOR
	  ) a;
	  
	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKelompokUmur
DROP FUNCTION IF EXISTS `getKelompokUmur`;
DELIMITER //
CREATE FUNCTION `getKelompokUmur`(`PTGLREG` DATETIME, `PTGLLAHIR` DATETIME) RETURNS int(11)
    DETERMINISTIC
BEGIN

	
	
	DECLARE idklp, umur, tahun INTEGER;
	
	SET umur= DATEDIFF(PTGLREG,PTGLLAHIR);
	
	SET tahun = umur DIV 365;
	
	SET idklp = IF(umur <=6,1
					, IF(umur >6 AND umur <=28,2
					, IF(umur >28 AND tahun <=1,3
					, IF(tahun >1 AND tahun <=4,4
					, IF(tahun >4 AND tahun <=14,5
					, IF(tahun >14 AND tahun <=24,6
					, IF(tahun >24 AND tahun <=44,7
					, IF(tahun >44 AND tahun <=64,8
					, 9))))))));
	
	RETURN idklp;
END//
DELIMITER ;

-- Dumping structure for function master.getKelompokUmurICDTerbanyak
DROP FUNCTION IF EXISTS `getKelompokUmurICDTerbanyak`;
DELIMITER //
CREATE FUNCTION `getKelompokUmurICDTerbanyak`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS int(11)
    DETERMINISTIC
BEGIN

	
	
	DECLARE idklp, umur, tahun INTEGER;
	
	SET umur= DATEDIFF(PTGLREG,PTGLLAHIR);
	
	SET tahun = umur DIV 365;
	
	SET idklp = IF(tahun <2,1
					, IF(tahun >=2 AND tahun <=17,2
					, IF(tahun >17 AND tahun <=50,3
					, 4)));
	
	RETURN idklp;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeDiagnosa
DROP FUNCTION IF EXISTS `getKodeDiagnosa`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT mr.CODE mrcode, md.ID
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND mr.TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY md.ID
	) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getKodeDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') 
	  INTO HASIL
	  FROM (
	   SELECT mr.CODE mrcode, md.ID 
		  FROM master.mrconso mr,
			    medicalrecord.diagnosa_meninggal md 
		 WHERE mr.CODE = md.KODE 
		   AND md.`STATUS` = 1 
			AND md.NOPEN = PNOPEN
		   AND mr.SAB IN ('ICD10_2020','ICD10_1998')
			AND TTY IN ('PX', 'PT')
	    GROUP BY mr.CODE
	  ) a
	 ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD
DROP FUNCTION IF EXISTS `getKodeICD`;
DELIMITER //
CREATE FUNCTION `getKodeICD`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',',';') INTO HASIL
	FROM (SELECT mr.CODE mrcode, md.ID
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB IN ('ICD10_2020','ICD10_1998') AND mr.TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY md.ID
	) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD10
DROP FUNCTION IF EXISTS `getKodeICD10`;
DELIMITER //
CREATE FUNCTION `getKodeICD10`(
	`PNOPEN` CHAR(10),
	`PBARIS` INT,
	`PUTAMA` TINYINT
) RETURNS char(5) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL CHAR(5);
	
	SET @row=0;
		SELECT KODE INTO HASIL
		FROM(
		SELECT KODE , @row:=@row+1 r
		FROM medicalrecord.diagnosa 
			 WHERE NOPEN = PNOPEN AND UTAMA=PUTAMA AND STATUS!=0 AND INA_GROUPER=0
			 ORDER BY UTAMA, ID) a
		WHERE r=PBARIS;
			  
	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD9
DROP FUNCTION IF EXISTS `getKodeICD9`;
DELIMITER //
CREATE FUNCTION `getKodeICD9`(
	`PNOPEN` CHAR(10),
	`PBARIS` TINYINT
) RETURNS char(5) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL CHAR(5);
	
	SET @row=0;
	SELECT KODE INTO HASIL
		FROM(
			SELECT KODE, @row:=@row+1 r 
			FROM medicalrecord.prosedur  
		   WHERE NOPEN = PNOPEN AND STATUS!=0 AND INA_GROUPER=0
		  ORDER BY ID) a
		WHERE r=PBARIS;
			  
	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD9CM
DROP FUNCTION IF EXISTS `getKodeICD9CM`;
DELIMITER //
CREATE FUNCTION `getKodeICD9CM`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT mr.CODE mrcode, pr.ID 
		FROM master.mrconso mr,
			  	medicalrecord.prosedur pr 
		WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=PNOPEN
		  AND mr.SAB='ICD9CM_2005' AND TTY IN ('PX', 'PT') AND pr.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICDCM
DROP FUNCTION IF EXISTS `getKodeICDCM`;
DELIMITER //
CREATE FUNCTION `getKodeICDCM`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',',';') INTO HASIL
	FROM (SELECT mr.CODE mrcode, pr.ID 
		FROM master.mrconso mr,
			  	medicalrecord.prosedur pr 
		WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=PNOPEN
		  AND mr.SAB='ICD9CM_2005' AND TTY IN ('PX', 'PT') AND pr.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKsmSubspesialis
DROP FUNCTION IF EXISTS `getKsmSubspesialis`;
DELIMITER //
CREATE FUNCTION `getKsmSubspesialis`(
	`PNIP` VARCHAR(30)
) RETURNS varchar(150) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(150);
  
   SELECT CONCAT(UPPER(bp.NMPOLI),' ; ',UPPER(smf.DESKRIPSI)) INTO HASIL
		FROM 
		  master.dokter_smf mds
			LEFT JOIN master.dokter md ON mds.DOKTER=md.ID
			LEFT JOIN master.referensi smf ON mds.SMF=smf.ID AND smf.JENIS=26
		, master.penjamin_sub_spesialistik psb
		, regonline.poli_bpjs  bp						
			WHERE psb.SUB_SPESIALIS_PENJAMIN= bp.KDSUBSPESIALIS
			AND psb.SUB_SPESIALIS_RS=mds.SMF
			AND mds.`STATUS`=1 AND md.`STATUS`=1
			AND psb.`STATUS`=1
			AND md.NIP = PNIP
			LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getNamaDanGelar
DROP FUNCTION IF EXISTS `getNamaDanGelar`;
DELIMITER //
CREATE FUNCTION `getNamaDanGelar`(
	`PGELAR_DEPAN` VARCHAR(25),
	`PNAMA` VARCHAR(75),
	`PGELAR_BELAKANG` VARCHAR(35)
) RETURNS varchar(135) CHARSET latin1
    DETERMINISTIC
BEGIN
	RETURN CONCAT(
		IF(PGELAR_DEPAN = '' OR PGELAR_DEPAN IS NULL, '', CONCAT(TRIM(PGELAR_DEPAN), '. '))
		, TRIM(UPPER(PNAMA))
		, IF(PGELAR_BELAKANG = '' OR PGELAR_BELAKANG IS NULL, '', CONCAT(', ', TRIM(PGELAR_BELAKANG)))
	);
END//
DELIMITER ;

-- Dumping structure for function master.getNamaLengkap
DROP FUNCTION IF EXISTS `getNamaLengkap`;
DELIMITER //
CREATE FUNCTION `getNamaLengkap`(`PNORM` VARCHAR(8)) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT CONCAT(IF(GELAR_DEPAN='' OR GELAR_DEPAN IS NULL,'',CONCAT(GELAR_DEPAN,'. ')),UPPER(NAMA),IF(GELAR_BELAKANG='' OR GELAR_BELAKANG IS NULL,'',CONCAT(', ',GELAR_BELAKANG))) INTO HASIL
	  FROM master.pasien
	 WHERE NORM = PNORM;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getNamaLengkapPegawai
DROP FUNCTION IF EXISTS `getNamaLengkapPegawai`;
DELIMITER //
CREATE FUNCTION `getNamaLengkapPegawai`(`PNIP` VARCHAR(30)) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT CONCAT(IF(GELAR_DEPAN='' OR GELAR_DEPAN IS NULL,'',CONCAT(GELAR_DEPAN,'. ')),UPPER(NAMA),IF(GELAR_BELAKANG='' OR GELAR_BELAKANG IS NULL,'',CONCAT(', ',GELAR_BELAKANG))) INTO HASIL
	  FROM master.pegawai
	 WHERE NIP = PNIP;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getNopenIRD
DROP FUNCTION IF EXISTS `getNopenIRD`;
DELIMITER //
CREATE FUNCTION `getNopenIRD`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(10);
   
	SELECT pr.NOMOR INTO HASIL	
		FROM pendaftaran.pendaftaran pr
			, pendaftaran.tujuan_pasien tpr
			, master.ruangan rpr
			, pendaftaran.kunjungan kpr
			  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
		  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		WHERE pr.NORM=PNORM AND pr.TANGGAL < PTANGGAL AND HOUR(TIMEDIFF(PTANGGAL, pr.TANGGAL)) <= 24 AND pr.`STATUS`!=0 AND pr.NOMOR=tpr.NOPEN
		  AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=2		  
		  AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.`STATUS`!=0
		ORDER BY pr.TANGGAL DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getNopenIRNA
DROP FUNCTION IF EXISTS `getNopenIRNA`;
DELIMITER //
CREATE FUNCTION `getNopenIRNA`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(10);
   
  SELECT pr.NOMOR INTO HASIL  
    FROM pendaftaran.pendaftaran pr
      , pendaftaran.tujuan_pasien tpr
      , master.ruangan rpr
      , pendaftaran.kunjungan kpr
      
    WHERE pr.NORM=PNORM AND pr.TANGGAL > PTANGGAL AND HOUR(TIMEDIFF(pr.TANGGAL,PTANGGAL)) <= 24 AND pr.STATUS!=0 AND pr.NOMOR=tpr.NOPEN
      AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=3
      AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.STATUS!=0
    LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getPelaksanaOperasi
DROP FUNCTION IF EXISTS `getPelaksanaOperasi`;
DELIMITER //
CREATE FUNCTION `getPelaksanaOperasi`(
	`PIDOPERASI` INT,
	`PJENIS` TINYINT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	  SELECT REPLACE(GROUP_CONCAT(IFNULL(master.getNamaLengkapPegawai(pg.NIP),po.PELAKSANA) SEPARATOR ';'),';',' ; ')  
	  INTO HASIL
	  FROM medicalrecord.pelaksana_operasi po
		  LEFT JOIN master.pegawai pg ON po.PELAKSANA=pg.ID
	WHERE po.OPERASI_ID=PIDOPERASI AND po.JENIS=PJENIS AND po.`STATUS`!=0;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getPelaksanaOperasi2
DROP FUNCTION IF EXISTS `getPelaksanaOperasi2`;
DELIMITER //
CREATE FUNCTION `getPelaksanaOperasi2`(
	`PIDOPERASI` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	  SELECT REPLACE(GROUP_CONCAT(IFNULL(master.getNamaLengkapPegawai(pg.NIP),po.PELAKSANA) SEPARATOR ' \r'),' \r',' \r')  
	  INTO HASIL
	  FROM medicalrecord.pelaksana_operasi po
		  LEFT JOIN master.pegawai pg ON po.PELAKSANA=pg.ID
	WHERE po.OPERASI_ID=PIDOPERASI AND po.`STATUS`!=0 AND po.JENIS NOT IN (1,4);

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getPetugasMedis
DROP FUNCTION IF EXISTS `getPetugasMedis`;
DELIMITER //
CREATE FUNCTION `getPetugasMedis`(
	`PTINDAKAN_MEDIS` CHAR(11),
	`PJENIS` TINYINT,
	`P_KE` TINYINT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT IF(ptm.JENIS IN (1,2), master.getNamaLengkapPegawai(dok.NIP), IF(ptm.JENIS IN (3,5,8), master.getNamaLengkapPegawai(pr.NIP) ,  master.getNamaLengkapPegawai(pg.NIP))) INTO HASIL
		FROM layanan.petugas_tindakan_medis ptm 
		     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID AND ptm.JENIS IN (1,2)
			  LEFT JOIN master.perawat pr ON ptm.MEDIS=pr.ID AND ptm.JENIS IN (3,5,8)
			  LEFT JOIN master.pegawai pg ON ptm.MEDIS=pg.ID AND ptm.JENIS NOT IN (3,5,8)
		WHERE ptm.TINDAKAN_MEDIS=PTINDAKAN_MEDIS AND ptm.JENIS=PJENIS AND ptm.KE=P_KE AND ptm.`STATUS`!=0;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getPetugasMedisTindakan
DROP FUNCTION IF EXISTS `getPetugasMedisTindakan`;
DELIMITER //
CREATE FUNCTION `getPetugasMedisTindakan`(
	`PTINDAKAN_MEDIS` CHAR(11)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(IF(ptm.JENIS IN (1,2), master.getNamaLengkapPegawai(dok.NIP), IF(ptm.JENIS IN (3,5,8), master.getNamaLengkapPegawai(pr.NIP) ,  master.getNamaLengkapPegawai(pg.NIP))) SEPARATOR ';'),';',' ; ')  INTO HASIL
		FROM layanan.petugas_tindakan_medis ptm 
		     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID AND ptm.JENIS IN (1,2)
			  LEFT JOIN master.perawat pr ON ptm.MEDIS=pr.ID AND ptm.JENIS IN (3,5,8)
			  LEFT JOIN master.pegawai pg ON ptm.MEDIS=pg.ID AND ptm.JENIS NOT IN (3,5,8)
		WHERE ptm.TINDAKAN_MEDIS=PTINDAKAN_MEDIS AND ptm.`STATUS`!=0;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getProsedurePasien
DROP FUNCTION IF EXISTS `getProsedurePasien`;
DELIMITER //
CREATE FUNCTION `getProsedurePasien`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  GROUP_CONCAT(mrcode) INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'-[',mr.STR,']') mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.prosedur md 
		WHERE mr.CODE=md.KODE AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		 -- AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE
	ORDER BY  md.ID) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getRuangKonsul
DROP FUNCTION IF EXISTS `getRuangKonsul`;
DELIMITER //
CREATE FUNCTION `getRuangKonsul`(
	`PNORM` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(RUANGAN SEPARATOR ';'))  INTO HASIL
	FROM (SELECT CONCAT('- ',mr.DESKRIPSI) RUANGAN
			FROM master.ruangan mr,
				  pendaftaran.kunjungan k
				  LEFT JOIN pendaftaran.pendaftaran p ON k.NOPEN=p.NOMOR
			WHERE mr.ID=k.RUANGAN AND k.`STATUS`!=0 AND k.REF IS NOT NULL
			AND mr.JENIS_KUNJUNGAN NOT IN (4,5,11) AND p.NORM=PNORM
			GROUP BY mr.ID) a
	ORDER BY RUANGAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getRuangPenunjang
DROP FUNCTION IF EXISTS `getRuangPenunjang`;
DELIMITER //
CREATE FUNCTION `getRuangPenunjang`(
	`PNORM` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(RUANGAN SEPARATOR ';'))  INTO HASIL
	FROM (SELECT CONCAT('- ',mr.DESKRIPSI) RUANGAN
			FROM master.ruangan mr,
				  pendaftaran.kunjungan k
				  LEFT JOIN pendaftaran.pendaftaran p ON k.NOPEN=p.NOMOR
			WHERE mr.ID=k.RUANGAN AND k.`STATUS`!=0 AND k.REF IS NOT NULL
			AND mr.JENIS_KUNJUNGAN IN (1,4,5,6,7,8,9,10) AND p.NORM=PNORM
			GROUP BY mr.ID) a
	ORDER BY RUANGAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getSepIRD
DROP FUNCTION IF EXISTS `getSepIRD`;
DELIMITER //
CREATE FUNCTION `getSepIRD`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(19) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(19);
   
	SELECT pj.NOMOR INTO HASIL	
		FROM pendaftaran.pendaftaran pr
			  LEFT JOIN pendaftaran.penjamin pj ON pr.NOMOR=pj.NOPEN
			, pendaftaran.tujuan_pasien tpr
			, master.ruangan rpr
			, pendaftaran.kunjungan kpr
			  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
		  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		WHERE pr.NORM=PNORM AND pr.TANGGAL < PTANGGAL AND HOUR(TIMEDIFF(PTANGGAL, pr.TANGGAL)) <= 24 AND pr.`STATUS`!=0 AND pr.NOMOR=tpr.NOPEN
		  AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=2		  
		  AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.`STATUS`!=0
		ORDER BY pr.TANGGAL DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getSepIRNA
DROP FUNCTION IF EXISTS `getSepIRNA`;
DELIMITER //
CREATE FUNCTION `getSepIRNA`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(19) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(19);
   
  SELECT pj.NOMOR INTO HASIL  
    FROM pendaftaran.pendaftaran pr
    		LEFT JOIN pendaftaran.penjamin pj ON pr.NOMOR=pj.NOPEN
      , pendaftaran.tujuan_pasien tpr
      , master.ruangan rpr
      , pendaftaran.kunjungan kpr
        LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
          LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
          LEFT JOIN master.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
    WHERE pr.NORM=PNORM AND pr.TANGGAL > PTANGGAL AND HOUR(TIMEDIFF(pr.TANGGAL,PTANGGAL)) <= 24 AND pr.STATUS!=0 AND pr.NOMOR=tpr.NOPEN
      AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=3
      AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.STATUS!=0
    LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getSMFDokter
DROP FUNCTION IF EXISTS `getSMFDokter`;
DELIMITER //
CREATE FUNCTION `getSMFDokter`(
	`PID` SMALLINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT s.DESKRIPSI INTO HASIL FROM master.dokter_smf ds
	, master.referensi s 
	WHERE ds.DOKTER=PID AND ds.SMF=s.ID AND s.JENIS=26 AND ds.`STATUS`=1 AND s.`STATUS`=1 
	ORDER BY ds.TANGGAL DESC
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTarifFarmasiPerKelas
DROP FUNCTION IF EXISTS `getTarifFarmasiPerKelas`;
DELIMITER //
CREATE FUNCTION `getTarifFarmasiPerKelas`(`PKELAS` TINYINT, `PTARIF` DECIMAL(60,2)) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VPERSEN DECIMAL(10,2);
	
	SELECT FARMASI INTO VPERSEN
	  FROM `master`.tarif_farmasi_per_kelas
	 WHERE STATUS = 1
	   AND KELAS = PKELAS
	 LIMIT 1;
	 
	IF FOUND_ROWS() > 0 THEN
		RETURN PTARIF + (PTARIF * (VPERSEN/100));
	END IF;
	
	RETURN PTARIF;
END//
DELIMITER ;

-- Dumping structure for function master.getTarifMarginPenjaminFarmasi
DROP FUNCTION IF EXISTS `getTarifMarginPenjaminFarmasi`;
DELIMITER //
CREATE FUNCTION `getTarifMarginPenjaminFarmasi`(
	`PPENJAMIN` SMALLINT,
	`PJENIS` TINYINT,
	`PTARIF` DECIMAL(60,2),
	`PTANGGAL` DATETIME
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VMARGIN DECIMAL(10,2);
	
	SELECT MARGIN INTO VMARGIN
	  FROM `master`.margin_penjamin_farmasi
	 WHERE PENJAMIN = PPENJAMIN
	   AND JENIS = PJENIS 
	   AND TANGGAL_SK <= PTANGGAL
    ORDER BY TANGGAL DESC LIMIT 1;
	 
	IF FOUND_ROWS() = 0 THEN
		SELECT MARGIN INTO VMARGIN
		  FROM `master`.margin_penjamin_farmasi
		 WHERE STATUS = 1
		   AND PENJAMIN = PPENJAMIN
		   AND JENIS = PJENIS 
	    ORDER BY TANGGAL DESC LIMIT 1;
	    
	   IF FOUND_ROWS() = 0 THEN
			SET VMARGIN = 0;
		END IF;
	END IF;
	
	RETURN PTARIF + (PTARIF * (VMARGIN/100));
END//
DELIMITER ;

-- Dumping structure for function master.getTarifRuangRawat
DROP FUNCTION IF EXISTS `getTarifRuangRawat`;
DELIMITER //
CREATE FUNCTION `getTarifRuangRawat`(
	`PKELAS` TINYINT,
	`PTANGGAL` DATETIME

) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE VTARIF INT;
	SELECT trr.TARIF INTO VTARIF
	  FROM `master`.tarif_ruang_rawat trr
	 WHERE trr.KELAS = PKELAS
	   AND trr.TANGGAL_SK <= PTANGGAL
	ORDER BY trr.TANGGAL DESC LIMIT 1;	 
	
	IF FOUND_ROWS() = 0 THEN 
		SELECT trr.TARIF INTO VTARIF
		  FROM `master`.tarif_ruang_rawat trr
		 WHERE trr.KELAS = PKELAS
		   AND trr.`STATUS` = 1
		ORDER BY trr.TANGGAL DESC LIMIT 1;
		
		IF FOUND_ROWS() = 0 THEN
			SET VTARIF = 0;
		END IF;
	END IF;
	 
	RETURN VTARIF;
END//
DELIMITER ;

-- Dumping structure for function master.getTblDiagnosa
DROP FUNCTION IF EXISTS `getTblDiagnosa`;
DELIMITER //
CREATE FUNCTION `getTblDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'- ',mr.STR) mrcode, md.ID
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1
		  AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTempatLahir
DROP FUNCTION IF EXISTS `getTempatLahir`;
DELIMITER //
CREATE FUNCTION `getTempatLahir`(`PKODE` CHAR(10)) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTEMPAT_LAHIR VARCHAR(50);
	DECLARE VKODE INT;
	
	SET VKODE = CAST(PKODE AS UNSIGNED);
	
	IF VKODE = 0 THEN
		RETURN '';
	END IF;
	
	SELECT DESKRIPSI INTO VTEMPAT_LAHIR
	  FROM `master`.wilayah
	 WHERE ID = PKODE;
	 
  	IF FOUND_ROWS() = 0 THEN
  		SELECT DESKRIPSI INTO VTEMPAT_LAHIR
		  FROM `master`.negara n
		 WHERE ID = PKODE;
		 
		IF FOUND_ROWS() = 0 THEN
			SET VTEMPAT_LAHIR = '';
		END IF;
	END IF;

	RETURN VTEMPAT_LAHIR;
END//
DELIMITER ;

-- Dumping structure for function master.getTglAsesmenAwal
DROP FUNCTION IF EXISTS `getTglAsesmenAwal`;
DELIMITER //
CREATE FUNCTION `getTglAsesmenAwal`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	   SELECT IF(an.TANGGAL > ku.TANGGAL, ku.TANGGAL, an.TANGGAL) tanggal INTO VTANGGAL
			FROM pendaftaran.kunjungan pk
			     LEFT JOIN medicalrecord.anamnesis an ON pk.NOMOR=an.KUNJUNGAN AND an.`STATUS`!=0
			     LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
			WHERE pk.NOMOR=PKUNJUNGAN AND pk.`STATUS`!=0 
			LIMIT 1;

	RETURN VTANGGAL;
END//
DELIMITER ;

-- Dumping structure for function master.getTglHasilLab
DROP FUNCTION IF EXISTS `getTglHasilLab`;
DELIMITER //
CREATE FUNCTION `getTglHasilLab`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	   SELECT a.TANGGAL INTO VTANGGAL
				FROM layanan.hasil_lab a 
				LEFT JOIN layanan.order_detil_lab odl ON a.TINDAKAN_MEDIS=odl.REF 
				LEFT JOIN layanan.order_lab od ON odl.ORDER_ID=od.NOMOR AND od.`STATUS` !=0
				LEFT JOIN pendaftaran.kunjungan k ON k.REF=od.NOMOR
		WHERE k.NOMOR=PKUNJUNGAN AND a.`STATUS` !=0
		ORDER BY a.TANGGAL ASC LIMIT 1;

	RETURN VTANGGAL;
END//
DELIMITER ;

-- Dumping structure for function master.getTglTindakanAwal
DROP FUNCTION IF EXISTS `getTglTindakanAwal`;
DELIMITER //
CREATE FUNCTION `getTglTindakanAwal`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	   SELECT tm.TANGGAL INTO VTANGGAL
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOMOR = PKUNJUNGAN
		GROUP BY mt.ID		
		ORDER BY tm.TANGGAL ASC
		LIMIT 1;

	RETURN VTANGGAL;
END//
DELIMITER ;

-- Dumping structure for function master.getTindakan
DROP FUNCTION IF EXISTS `getTindakan`;
DELIMITER //
CREATE FUNCTION `getTindakan`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR ';'))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOPEN = PNOPEN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTindakanKonsul
DROP FUNCTION IF EXISTS `getTindakanKonsul`;
DELIMITER //
CREATE FUNCTION `getTindakanKonsul`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR ';'))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND k.REF IS NOT NULL
		    AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOPEN = PNOPEN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTindakanKunjungan
DROP FUNCTION IF EXISTS `getTindakanKunjungan`;
DELIMITER //
CREATE FUNCTION `getTindakanKunjungan`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR '; '))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOMOR = PKUNJUNGAN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTindakanTanpaKonsultasi
DROP FUNCTION IF EXISTS `getTindakanTanpaKonsultasi`;
DELIMITER //
CREATE FUNCTION `getTindakanTanpaKonsultasi`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR '; '))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (3,7,8,9) 
			 AND k.NOMOR = PKUNJUNGAN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getUmurTahun
DROP FUNCTION IF EXISTS `getUmurTahun`;
DELIMITER //
CREATE FUNCTION `getUmurTahun`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	DECLARE thn INTEGER;	
	
	SET thn = YEAR(PTGLREG) - YEAR(PTGLLAHIR);
	IF DATE_ADD(PTGLLAHIR, INTERVAL thn YEAR) > PTGLREG THEN
		SET thn = thn - 1;
	END IF;
	
	RETURN thn;
END//
DELIMITER ;

-- Dumping structure for function master.getWilayah
DROP FUNCTION IF EXISTS `getWilayah`;
DELIMITER //
CREATE FUNCTION `getWilayah`(
	`PWILAYAH` CHAR(10),
	`PJENISWILAYAH` TINYINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   DECLARE VWILAYAH CHAR(10);

   SET VWILAYAH = LEFT(PWILAYAH, IF(PJENISWILAYAH = 1, 2, IF(PJENISWILAYAH = 2, 4, IF(PJENISWILAYAH = 3, 6, IF(PJENISWILAYAH = 4, 10, 0)))));

   
   SELECT IF(PJENISWILAYAH=1,CONCAT('Prop. ',w.DESKRIPSI)
			, IF(PJENISWILAYAH=2,CONCAT('Kab/Kota. ',w.DESKRIPSI)
			 , IF(PJENISWILAYAH=3,CONCAT('Kec. ',w.DESKRIPSI)
			  , IF(PJENISWILAYAH=4,CONCAT('Kel. ',w.DESKRIPSI)
			   , w.DESKRIPSI)))) INTO HASIL 
	 FROM `master`.wilayah w 
 	 WHERE w.JENIS = PJENISWILAYAH 
       AND w.ID = VWILAYAH;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.isRawatInap
DROP FUNCTION IF EXISTS `isRawatInap`;
DELIMITER //
CREATE FUNCTION `isRawatInap`(`PRUANGAN` CHAR(10)) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	RETURN EXISTS(SELECT 1 FROM `master`.ruangan WHERE ID = PRUANGAN AND JENIS_KUNJUNGAN = 3);
END//
DELIMITER ;
