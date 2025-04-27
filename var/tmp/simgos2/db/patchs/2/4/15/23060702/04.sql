USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilLab
DROP PROCEDURE IF EXISTS `CetakHasilLab`;
DELIMITER //
CREATE PROCEDURE `CetakHasilLab`(
	IN `PNOMOR` CHAR(21),
	IN `PTINDAKAN` VARCHAR(1000)
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT  COUNT(*) INTO @ROWS 
		FROM layanan.hasil_lab hlab,
			  layanan.tindakan_medis tm
			  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
			  LEFT JOIN master.dokter dok ON chl.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP,
			  master.parameter_tindakan_lab ptl,
			  master.tindakan mt
			  LEFT JOIN master.mapping_group_pemeriksaan mgp ON mt.ID=mgp.PEMERIKSAAN AND mgp.STATUS = 1
			  LEFT JOIN master.group_pemeriksaan kgl ON mgp.GROUP_PEMERIKSAAN_ID=kgl.ID AND kgl.JENIS=8 AND kgl.STATUS=1
			  LEFT JOIN master.group_pemeriksaan ggl ON ggl.KODE=LEFT(kgl.KODE,2) AND ggl.JENIS=8 AND ggl.STATUS=1,
			  pendaftaran.pendaftaran pp
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10,
			  pendaftaran.kunjungan pk 
			  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.dokter dokasal ON ks.DOKTER_ASAL=dokasal.ID
			  LEFT JOIN master.pegawai mpasal ON dokasal.NIP=mpasal.NIP,
			  master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
				AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
				AND pk.NOMOR=''',PNOMOR,'''  AND hlab.TINDAKAN_MEDIS IN (',PTINDAKAN,')
				AND (hlab.HASIL!='''' AND hlab.HASIL IS NOT NULL)
		ORDER BY ggl.ID,kgl.ID,mt.ID,ptl.INDEKS');
	
		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
		SELECT mp.NAMA NAMAINST, mp.ALAMAT ALAMATINST, ai.PPK, w.DESKRIPSI KOTA, mp.TELEPON, mp.FAX, ai.EMAIL
		   INTO @NAMAINST, @ALAMATINST, @PPK, @KOTA, @TELEPON, @FAX, @EMAIL
			FROM aplikasi.instansi ai
				, master.ppk mp
				, master.wilayah w
			WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID;
		
	SET @sqlText = CONCAT('
				SELECT @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, @PPK PPK, @KOTA KOTA, @TELEPON TELEPON, @FAX FAX, @EMAIL EMAIL, 
						 DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s'') TGLSKRG, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP,
						 CONCAT(rjk.DESKRIPSI,'' / '',DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'')) JKTGLALHIR,
						 master.getNamaLengkapPegawai(mp.NIP) DOKTER, mp.NIP NIPDPJP, master.getNamaLengkapPegawai(mpasal.NIP) DOKTERASAL,
						 master.getNamaLengkapPegawai(mpper.NIP) ANALIS,
						 pk.NOPEN, pk.MASUK TGLREG, hlab.TANGGAL TANGGALHASIL, chl.CATATAN,
						 r.DESKRIPSI UNITPENGANTAR, ks.ALASAN DIAGNOSA, tm.KUNJUNGAN,
						 kgl.DESKRIPSI KLPLAB, ggl.DESKRIPSI GROUPLAB,
						 mt.NAMA NAMATINDAKAN, ptl.PARAMETER, IFNULL(hlab.NILAI_NORMAL, ptl.NILAI_RUJUKAN) NILAI_RUJUKAN, hlab.HASIL, 
						 IFNULL(hlab.SATUAN, sl.DESKRIPSI) SATUAN, hlab.KETERANGAN,
						 ggl.ID, ptl.INDEKS, @ROWS `ROWS`
				FROM layanan.hasil_lab hlab,
					  layanan.tindakan_medis tm
					  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
					  LEFT JOIN master.dokter dok ON chl.DOKTER=dok.ID
					  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					  LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS=tm.ID AND ptm.JENIS=6 AND ptm.KE=1 AND ptm.STATUS!=0
					  #LEFT JOIN master.perawat per ON ptm.MEDIS=per.ID
					  LEFT JOIN master.pegawai mpper ON ptm.MEDIS=mpper.ID,
					  master.parameter_tindakan_lab ptl
					  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
					  master.tindakan mt
					  LEFT JOIN master.mapping_group_pemeriksaan mgp ON mt.ID=mgp.PEMERIKSAAN AND mgp.STATUS = 1
					  LEFT JOIN master.group_pemeriksaan kgl ON mgp.GROUP_PEMERIKSAAN_ID=kgl.ID AND kgl.JENIS=8 AND kgl.STATUS=1
					  LEFT JOIN master.group_pemeriksaan ggl ON ggl.KODE=LEFT(kgl.KODE,2) AND ggl.JENIS=8 AND ggl.STATUS=1,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10,
					  pendaftaran.kunjungan pk 
					  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
					  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
					  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
					  LEFT JOIN master.dokter dokasal ON ks.DOKTER_ASAL=dokasal.ID
					  LEFT JOIN master.pegawai mpasal ON dokasal.NIP=mpasal.NIP,
					  master.pasien p
					  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
					WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
						AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
						AND pk.NOMOR=''',PNOMOR,''' AND hlab.TINDAKAN_MEDIS IN (',PTINDAKAN,')
						AND (hlab.HASIL!='''' AND hlab.HASIL IS NOT NULL)
				ORDER BY ggl.ID,kgl.ID,mt.ID,ptl.INDEKS');

		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure layanan.CetakOrderDetilResep
DROP PROCEDURE IF EXISTS `CetakOrderDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderDetilResep`(
	IN `PNOMOR` CHAR(21)
)
BEGIN
	
	SET @gp=0;
	SET @r='';
	SELECT *
			, IF(@r!=RACIKAN,'R/','') R
			 , @r:=RACIKAN R2
		FROM (
				SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU
						 , mp.NIP, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER
						 , o.BERAT_BADAN, o.TINGGI_BADAN
						 , o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
						 , IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
						 , r.DESKRIPSI ASALPENGIRIM, ib.NAMA NAMAOBAT, od.JUMLAH
					 	 , IF(lf.ID IS NULL
						  		,master.getAturanPakai2(od.FREKUENSI, od.DOSIS, od.RUTE_PEMBERIAN)
						  			,master.getAturanPakai2(lf.FREKUENSI, lf.DOSIS, lf.RUTE_PEMBERIAN)
								) ATURANPAKAI
						 , master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
						 , ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
						 , CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP, od.KETERANGAN, CONCAT(od.RACIKAN,IF(od.RACIKAN=0,@gp:=@gp+1,od.GROUP_RACIKAN)) RACIKAN
						 , IFNULL(f.DESKRIPSI,'') PETUNJUK_RACIKAN
						 , lf.`STATUS` STATUSLAYANAN
				  FROM layanan.order_resep o
						 LEFT JOIN master.dokter md ON o.DOKTER_DPJP = md.ID
						 LEFT JOIN master.pegawai mp ON md.NIP = mp.NIP
						 , pendaftaran.kunjungan pk
					    LEFT JOIN master.ruangan r ON pk.RUANGAN = r.ID AND r.JENIS = 5
					    LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
						 , layanan.order_detil_resep od
						 LEFT JOIN master.referensi ref ON ref.ID = od.ATURAN_PAKAI AND ref.JENIS = 41
					    LEFT JOIN layanan.farmasi lf ON od.REF = lf.ID
					    LEFT JOIN `master`.referensi f ON od.PETUNJUK_RACIKAN=f.ID AND f.JENIS=84
						 , inventory.barang ib
						 , pendaftaran.pendaftaran pp
						 LEFT JOIN master.pasien ps ON pp.NORM = ps.NORM
						 , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
							   FROM aplikasi.instansi ai
								     , master.ppk mp
							  WHERE ai.PPK = mp.ID) inst
				 WHERE o.NOMOR=od.ORDER_ID AND o.`STATUS` IN (1,2)
					AND od.FARMASI = ib.ID AND o.KUNJUNGAN = pk.NOMOR AND pk.`STATUS` IN (1,2)
					AND pk.NOPEN = pp.NOMOR
					AND o.NOMOR = PNOMOR
				 ORDER BY od.RACIKAN DESC, od.GROUP_RACIKAN
	 ) ab;
END//
DELIMITER ;

-- Dumping structure for procedure layanan.CetakOrderResep
DROP PROCEDURE IF EXISTS `CetakOrderResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderResep`(IN `PNOMOR` CHAR(21))
BEGIN
	
	SELECT inst.PPK, inst.NAMA INSTASI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
		, o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
		, IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
		, r.DESKRIPSI ASALPENGIRIM, master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
		, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
		, CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP
		FROM layanan.order_resep o
			  LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
			  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			, pendaftaran.kunjungan pk
		     LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
			, pendaftaran.pendaftaran pp
			  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
			, (SELECT mp.NAMA, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
		WHERE  o.`STATUS`IN (1,2) AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR
			AND o.NOMOR=PNOMOR
	;
END//
DELIMITER ;

-- Dumping structure for function layanan.getJumlahTindakan
DROP FUNCTION IF EXISTS `getJumlahTindakan`;
DELIMITER //
CREATE FUNCTION `getJumlahTindakan`(
	`PNOMOR` VARCHAR(19),
	`PTINDAKAN` SMALLINT,
	`PTIPE` ENUM('PENDAFTARAN','KUNJUNGAN')) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VJML SMALLINT DEFAULT 0;
	
	IF PTIPE = 'PENDAFTARAN' THEN
		SELECT COUNT(tm.ID) INTO VJML
		  FROM pendaftaran.pendaftaran p
		  		 , pendaftaran.kunjungan k
		  		 , layanan.tindakan_medis tm
		 WHERE p.NOMOR = PNOMOR
		   AND k.NOPEN = p.NOMOR
		   AND k.`STATUS` IN (1,2)
		   AND tm.KUNJUNGAN = k.NOMOR
		   AND tm.TINDAKAN = PTINDAKAN
		   AND tm.`STATUS` = 1;
	ELSEIF PTIPE = 'KUNJUNGAN' THEN
		SELECT COUNT(tm.ID) INTO VJML
		  FROM pendaftaran.kunjungan k
		  		 , layanan.tindakan_medis tm
		 WHERE k.NOMOR = PNOMOR
		 	AND k.`STATUS` IN (1,2)
		   AND tm.KUNJUNGAN = k.NOMOR
		   AND tm.TINDAKAN = PTINDAKAN
		   AND tm.`STATUS` = 1;		
	END IF;
	
	IF FOUND_ROWS() = 0 THEN
		SET VJML = 0;
	END IF;
	
	RETURN VJML;
END//
DELIMITER ;

-- Dumping structure for function layanan.getResepPulang
DROP FUNCTION IF EXISTS `getResepPulang`;
DELIMITER //
CREATE FUNCTION `getResepPulang`(
	`PNOPEN` CHAR(10)
) RETURNS tinyint(4)
    DETERMINISTIC
BEGIN
	RETURN EXISTS(
		SELECT  1
		  FROM layanan.farmasi lf
			    LEFT JOIN master.referensi ref ON ref.ID = lf.ATURAN_PAKAI AND ref.JENIS = 41
			    , pendaftaran.kunjungan pk
		       LEFT JOIN layanan.order_resep o ON o.NOMOR = pk.REF
		     	 LEFT JOIN master.dokter md ON o.DOKTER_DPJP = md.ID
			  	 LEFT JOIN master.pegawai mp ON md.NIP = mp.NIP
			  	 LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN = asal.NOMOR
			  	 LEFT JOIN master.ruangan r ON asal.RUANGAN = r.ID AND r.JENIS = 5
		     	 LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN = jenisk.ID AND jenisk.JENIS = 15
		   	 , pendaftaran.pendaftaran pp
			    LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				 , inventory.barang ib
				 , pembayaran.rincian_tagihan rt
		 WHERE  lf.`STATUS` != 0 
		   AND lf.KUNJUNGAN = pk.NOMOR 
			AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN = pp.NOMOR 
			AND lf.FARMASI = ib.ID
			AND pk.NOPEN = PNOPEN 
			AND o.RESEP_PASIEN_PULANG = 1
			AND lf.ID = rt.REF_ID
			AND rt.JENIS = 4
			AND LEFT(ib.KATEGORI,3) = '101'
	    LIMIT 1
	);
END//
DELIMITER ;