USE `laporan`;

-- Dumping structure for procedure laporan.LaporanBarangMasukKeluarRuangan
DROP PROCEDURE IF EXISTS `LaporanBarangMasukKeluarRuangan`;
DELIMITER //
CREATE PROCEDURE `LaporanBarangMasukKeluarRuangan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT

)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
	SET @sqlText = CONCAT('
				SELECT PPK, NAMAINST, ALAMATINST, NAMAOBAT, SUM(MASUK) BARANG_MASUK, SUM(KELUAR) BARANG_KELUAR, IF(HARGABELI IS NULL,0,HARGABELI) HARGABELI
				      , IF(HARGA_JUAL IS NULL,0,HARGA_JUAL) HARGA_JUAL, JENISLAPORAN, INSTALASI, KATEGORI
						, CARABAYARHEADER, BARANGHEADER, JNSKATEGORI, SATUAN
						FROM (
						SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, ib.ID IDOBAT, ib.NAMA NAMAOBAT, jts.DESKRIPSI, DATE_FORMAT(tsr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLPELAYANAN
												, IF(jts.TAMBAH_ATAU_KURANG=''+'',tsr.JUMLAH,0) MASUK
												, IF(jts.TAMBAH_ATAU_KURANG=''-'',tsr.JUMLAH,0) KELUAR
												, tsr.STOK
												, IF(inventory.getHargaPenerimaanTerakhir(ib.ID)=0,ib.HARGA_BELI,inventory.getHargaPenerimaanTerakhir(ib.ID)) HARGABELI
												, (SELECT HARGA_JUAL FROM  inventory.harga_barang hb  WHERE hb.BARANG=ib.ID AND hb.`STATUS`=1 AND HARGA_JUAL!=0 ORDER BY hb.TANGGAL DESC LIMIT 1) HARGA_JUAL
												, CONCAT(''LAPORAN REKAP MUTASI BARANG '',UPPER(jk.DESKRIPSI)) JENISLAPORAN
												, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
												, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
												, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
												, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER, ik.NAMA JNSKATEGORI, stn.DESKRIPSI SATUAN
												, LPAD(ps.NORM,8,''0'') NORM, pk.NOPEN, master.getNamaLengkap(ps.NORM) NAMAPASIEN
												, IF(jts.ID=20,rga.DESKRIPSI,IF(jts.ID=23,rgt.DESKRIPSI,ra.DESKRIPSI)) RUANGASAL
											FROM inventory.transaksi_stok_ruangan tsr
											     LEFT JOIN inventory.jenis_transaksi_stok jts ON tsr.JENIS=jts.ID
											     LEFT JOIN layanan.farmasi lf ON tsr.REF=lf.ID
											     LEFT JOIN pendaftaran.kunjungan pk ON lf.KUNJUNGAN=pk.NOMOR
											     LEFT JOIN layanan.order_resep o ON pk.REF=o.NOMOR
											     LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
											     LEFT JOIN master.ruangan ra ON asal.RUANGAN=ra.ID
											     LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR
											     LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
											     LEFT JOIN inventory.pengiriman_detil ipd ON tsr.REF=ipd.ID AND ipd.`STATUS`!=0
											     LEFT JOIN inventory.pengiriman ipg ON ipd.PENGIRIMAN=ipg.NOMOR
											     LEFT JOIN master.ruangan rgt ON ipg.TUJUAN=rgt.ID
											     LEFT JOIN master.ruangan rga ON ipg.ASAL=rga.ID
												, inventory.barang_ruangan br
												, master.ruangan r
												  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
												, inventory.barang ib
												  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
												  LEFT JOIN inventory.satuan stn ON ib.SATUAN=stn.ID
												, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
																	FROM aplikasi.instansi ai
																		, master.ppk mp
																	WHERE ai.PPK=mp.ID) inst
											WHERE tsr.BARANG_RUANGAN=br.ID AND br.RUANGAN=r.ID AND r.JENIS=5 AND br.BARANG=ib.ID  AND ik.ID NOT LIKE ''107%''
												 AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND tsr.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
												 AND br.RUANGAN LIKE ''',vRUANGAN,''' 
												 ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
												  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
						) ab		
					GROUP BY IDOBAT				  
					ORDER BY JNSKATEGORI, NAMAOBAT	');
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanBelumKlikBayar
DROP PROCEDURE IF EXISTS `LaporanBelumKlikBayar`;
DELIMITER //
CREATE PROCEDURE `LaporanBelumKlikBayar`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT inst.PPK, inst.NAMAINST NAMAINST, inst.ALAMATINST ALAMATINST, tp.TAGIHAN, IF(pt.`STATUS` IS NULL,0,pt.`STATUS`) STATUS, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
				, pp.NOMOR, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(pp.NORM) NAMAPASIEN, p.ALAMAT ALAMATPASIEN
			   , (SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM) NOHP, cb.DESKRIPSI CARABAYAR
				, pj.NAMA PENANGGUNGJAWAB, pj.ALAMAT ALAMATPENANGGUNGJAWAB, kpj.NOMOR HPPENANGGUNGJAWAB
			   , kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , UPPER(jnslyn.DESKRIPSI) JENISLAYANAN, jnslyn.ID IDJENISLAYANAN
			   , r.DESKRIPSI RUANGANAWAL
				, IF(jnslyn.ID=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pp.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jnslyn.ID=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pp.TANGGAL)) LOS
				, IF(jnslyn.ID=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pp.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM pendaftaran.pendaftaran pp 
				  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN pendaftaran.penanggung_jawab_pasien pj ON pp.NOMOR=pj.NOPEN 
			     LEFT JOIN pendaftaran.kontak_penanggung_jawab kpj ON pj.ID=kpj.ID  AND kpj.JENIS=3
			     LEFT JOIN pendaftaran.penjamin pjm ON pp.NOMOR=pjm.NOPEN 
			     LEFT JOIN master.referensi cb ON pjm.JENIS=cb.ID AND cb.JENIS=10
			     LEFT JOIN `master`.kartu_asuransi_pasien kap ON p.NORM = kap.NORM AND kap.JENIS=pjm.JENIS
			     LEFT JOIN inacbg.hasil_grouping cbg ON pp.NOMOR=cbg.NOPEN
		  		  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
		  		  LEFT JOIN layanan.pasien_pulang lpp ON pp.NOMOR=lpp.NOPEN AND lpp.STATUS=1
		  		  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			   , pembayaran.tagihan_pendaftaran tp 
			     LEFT JOIN pendaftaran.tujuan_pasien tps ON tp.PENDAFTARAN=tps.NOPEN AND tps.`STATUS`!=0
			     LEFT JOIN master.ruangan r ON tps.RUANGAN=r.ID
			     LEFT JOIN master.referensi jnslyn ON r.JENIS_KUNJUNGAN=jnslyn.ID AND jnslyn.JENIS=15
			     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN=tp.TAGIHAN AND pt.`STATUS`!=0
			     LEFT JOIN pembayaran.tagihan t on tp.TAGIHAN=t.ID
			     LEFT JOIN master.dokter dok ON tps.DOKTER=dok.ID
			   , (SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) inst
			WHERE pp.`STATUS`!=0 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND tps.RUANGAN LIKE ''',vRUANGAN,''' 
			  ',IF(CARABAYAR=0,'',CONCAT(' AND pjm.JENIS=',CARABAYAR)),'
			  AND pp.NOMOR =tp.PENDAFTARAN AND tp.`STATUS`!=0 AND tp.UTAMA=1 AND pt.TAGIHAN IS NULL
			GROUP BY tp.TAGIHAN
			ORDER BY TGLDAFTAR, JENISLAYANAN, RUANGANAWAL, DPJP
		');
	

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanBelumKlikBayarIKS
DROP PROCEDURE IF EXISTS `LaporanBelumKlikBayarIKS`;
DELIMITER //
CREATE PROCEDURE `LaporanBelumKlikBayarIKS`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT inst.PPK, inst.NAMAINST NAMAINST, inst.ALAMATINST ALAMATINST, tp.TAGIHAN, IF(pt.`STATUS` IS NULL,0,pt.`STATUS`) STATUS, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
				, pp.NOMOR, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(pp.NORM) NAMAPASIEN, p.ALAMAT ALAMATPASIEN
			   , (SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM) NOHP, cb.DESKRIPSI CARABAYAR
				, pj.NAMA PENANGGUNGJAWAB, pj.ALAMAT ALAMATPENANGGUNGJAWAB, kpj.NOMOR HPPENANGGUNGJAWAB
			   , kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , UPPER(jnslyn.DESKRIPSI) JENISLAYANAN, jnslyn.ID IDJENISLAYANAN
			   , r.DESKRIPSI RUANGANAWAL
				, IF(jnslyn.ID=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pp.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jnslyn.ID=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pp.TANGGAL)) LOS
				, IF(jnslyn.ID=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pp.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM pendaftaran.pendaftaran pp 
				  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN pendaftaran.penanggung_jawab_pasien pj ON pp.NOMOR=pj.NOPEN 
			     LEFT JOIN pendaftaran.kontak_penanggung_jawab kpj ON pj.ID=kpj.ID  AND kpj.JENIS=3
			     LEFT JOIN pendaftaran.penjamin pjm ON pp.NOMOR=pjm.NOPEN 
			     LEFT JOIN master.referensi cb ON pjm.JENIS=cb.ID AND cb.JENIS=10
			     LEFT JOIN `master`.kartu_asuransi_pasien kap ON p.NORM = kap.NORM AND kap.JENIS=pjm.JENIS
			     LEFT JOIN inacbg.hasil_grouping cbg ON pp.NOMOR=cbg.NOPEN
		  		  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
		  		  LEFT JOIN layanan.pasien_pulang lpp ON pp.NOMOR=lpp.NOPEN AND lpp.STATUS=1
		  		  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			   , pembayaran.tagihan_pendaftaran tp 
			     LEFT JOIN pendaftaran.tujuan_pasien tps ON tp.PENDAFTARAN=tps.NOPEN AND tps.`STATUS`!=0
			     LEFT JOIN master.ruangan r ON tps.RUANGAN=r.ID
			     LEFT JOIN master.referensi jnslyn ON r.JENIS_KUNJUNGAN=jnslyn.ID AND jnslyn.JENIS=15
			     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN=tp.TAGIHAN AND pt.`STATUS`!=0
			     LEFT JOIN pembayaran.tagihan t on tp.TAGIHAN=t.ID
			     LEFT JOIN master.dokter dok ON tps.DOKTER=dok.ID
			   , (SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) inst
			WHERE pp.`STATUS`!=0 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND tps.RUANGAN LIKE ''',vRUANGAN,''' 
			  AND pjm.JENIS NOT IN (1,2)
			  AND pp.NOMOR =tp.PENDAFTARAN AND tp.`STATUS`!=0 AND tp.UTAMA=1 AND pt.TAGIHAN IS NULL
			GROUP BY tp.TAGIHAN
			ORDER BY CARABAYAR, TGLDAFTAR, JENISLAYANAN, RUANGANAWAL, DPJP
		');
	

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanDistribusiPendapatanPerPasien
DROP PROCEDURE IF EXISTS `LaporanDistribusiPendapatanPerPasien`;
DELIMITER //
CREATE PROCEDURE `LaporanDistribusiPendapatanPerPasien`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT)
BEGIN
	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT INST.NAMAINST, INST.ALAMATINST,INSTALASI, ab.TAGIHAN, ab.REF, ab.JENIS, SUM(ADMINISTRASI) ADMINISTRASI, SUM(SARANA) SARANA, SUM(BHP) BHP
		, SUM(DOKTER_OPERATOR) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
		, SUM(PENATA_ANASTESI) PENATA_ANASTESI, SUM(PARAMEDIS ) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
		, TOTALTAGIHAN
		, (pembayaran.getTotalDiskon(ab.TAGIHAN)+ pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) TOTALDISKON
		, NORM, NAMAPASIEN, NOPEN,  TGLBAYAR
		, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
		, RUANGAN, CARABAYAR, TGLREG
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
	FROM (
	/*Tindakan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
				, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		   LEFT JOIN `master`.tindakan mt ON mt.ID = tm.TINDAKAN
	  		   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , master.tarif_tindakan tt 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tt.ID AND rt.JENIS=3
		GROUP BY t.TAGIHAN
		UNION
/*Administrasi Non Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt 
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID NOT IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Administrasi Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			  LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
	  		  LEFT JOIN `master`.ruangan r ON r.ID = kj.RUANGAN
	  		  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kj.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Akomodasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 ,  master.tarif_ruang_rawat trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=2
		GROUP BY t.TAGIHAN
		UNION
		
		/*Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(tf.HARGA_JUAL * rt.JUMLAH) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(tf.HARGA_JUAL * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
			   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , inventory.harga_barang tf
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=tf.ID AND rt.JENIS=4
		GROUP BY t.TAGIHAN
		UNION
		/*Paket*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tp.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tp.SARANA * rt.JUMLAH) SARANA, SUM(tp.BHP * rt.JUMLAH) BHP
				, SUM(tp.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tp.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tp.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tp.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tp.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tp.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tp.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt  
			 , master.distribusi_tarif_paket tp
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
		GROUP BY t.TAGIHAN
		UNION
		/*Penjualan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
				, '''' NORM, ppj.PENGUNJUNG NAMAPASIEN, '''' NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
				, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			FROM pembayaran.pembayaran_tagihan t
				  LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
			     LEFT JOIN penjualan.penjualan ppj ON t.TAGIHAN=ppj.NOMOR
			     LEFT JOIN master.ruangan ru ON ppj.RUANGAN=ru.ID AND ru.JENIS=5
			     LEFT JOIN master.referensi rfu ON ru.JENIS_KUNJUNGAN=rfu.ID AND rfu.JENIS=15
			     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
			WHERE t.`STATUS` !=0 AND t.JENIS=8 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND ppj.RUANGAN LIKE ''',vRUANGAN,'''  AND ru.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
			GROUP BY t.TAGIHAN
			UNION
			/*O2*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 ,  master.tarif_ruang_rawat trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=6
		GROUP BY t.TAGIHAN
	) ab
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
		FROM aplikasi.instansi ai
			, master.ppk p
		WHERE ai.PPK=p.ID) INST
	GROUP BY ab.TAGIHAN
			
	');
	

  PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanDokterPerpasienTglTindakan
DROP PROCEDURE IF EXISTS `LaporanDokterPerpasienTglTindakan`;
DELIMITER //
CREATE PROCEDURE `LaporanDokterPerpasienTglTindakan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10)
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	(SELECT p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN, IFNULL(kls.DESKRIPSI,''Non Kelas'') KELAS
		, jka.DESKRIPSI JENISKUNJUNGAN
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN
		, rt.TARIF
		, IF(ptm.JENIS=1 AND ptm.KE=1,tt.DOKTER_OPERATOR
			, IF(ptm.JENIS=1 AND ptm.KE=2,tt.DOKTER_LAINNYA
			  , IF(ptm.JENIS=2 ,tt.DOKTER_ANASTESI
			    , IF(ptm.JENIS=3 ,tt.PARAMEDIS
			      , IF(ptm.JENIS=5 ,tt.PARAMEDIS
			        , IF(ptm.JENIS=6 ,tt.PARAMEDIS
			          , IF(ptm.JENIS=7 ,tt.PENATA_ANASTESI
			            , IF(ptm.JENIS=8 ,0
			              , IF(ptm.JENIS=9 ,0
			                , IF(ptm.JENIS=10 ,0,0)))))))))) TARIF_JASA
		, master.getNamaLengkapPegawai(mp.NIP) PEGAWAI
	/*	, (SELECT REPLACE(GROUP_CONCAT(IF(ptg.JENIS IN (1,2),CONCAT(''- '',master.getNamaLengkapPegawai(mp.NIP)),CONCAT(''- '',master.getNamaLengkapPegawai(mpp.NIP)))),'',-'',''\r-'') 
				FROM layanan.petugas_tindakan_medis ptg
					  LEFT JOIN master.dokter dok ON ptg.MEDIS=dok.ID AND ptg.JENIS IN (1,2)
					  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					  LEFT JOIN master.pegawai mpp ON mpp.ID=ptg.MEDIS AND ptg.JENIS NOT IN (1,2)
				WHERE ptg.TINDAKAN_MEDIS=tm.ID
				GROUP BY ptg.TINDAKAN_MEDIS
				LIMIT 1) PEGAWAI */
		, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLMASUK 
		, DATE_FORMAT(pp.TANGGAL,''%H:%i:%s'') WAKTUMASUK
		, DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y'') TGLKELUAR
		, DATE_FORMAT(pl.TANGGAL,''%H:%i:%s'') WAKTUKELUAR   
		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
	FROM  pembayaran.rincian_tagihan rt
	     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
		  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.STATUS!=0 AND ptm.JENIS=1
		  LEFT JOIN master.dokter dok1 ON ptm.MEDIS=dok1.ID AND ptm.JENIS IN (1,2)
		  LEFT JOIN master.pegawai mp ON dok1.NIP=mp.NIP
		  LEFT JOIN medicalrecord.operasi_di_tindakan mot ON tm.ID=mot.TINDAKAN_MEDIS AND mot.`STATUS`!=0
		  LEFT JOIN medicalrecord.operasi op ON mot.ID=op.ID AND op.`STATUS`!=0
		  LEFT JOIN master.tarif_tindakan tt ON rt.TARIF_ID=tt.ID
		  LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR = tm.KUNJUNGAN
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.STATUS=1
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.ruangan ra ON tp.RUANGAN=ra.ID AND ra.JENIS=5
		  LEFT JOIN master.referensi jka ON ra.JENIS_KUNJUNGAN=jka.ID AND jka.JENIS=15
		  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
		  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pp.STATUS!=0
	  AND rt.JENIS = 3 AND rt.`STATUS` NOT IN (0)
	  ',IF(RUANGAN=0,'',CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''')),' 	  
	ORDER BY pp.TANGGAL, tm.TANGGAL, ptm.JENIS, ptm.MEDIS)
	UNION ALL
	(SELECT p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN, IFNULL(kls.DESKRIPSI,''Non Kelas'') KELAS
		, jk.DESKRIPSI JENISKUNJUNGAN
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN
		, tt.TARIF
		, IF(ptm.JENIS=1 AND ptm.KE=1,tt.DOKTER_OPERATOR
			, IF(ptm.JENIS=1 AND ptm.KE=2,tt.DOKTER_LAINNYA
			  , IF(ptm.JENIS=2 ,tt.DOKTER_ANASTESI
			    , IF(ptm.JENIS=3 ,tt.PARAMEDIS
			      , IF(ptm.JENIS=5 ,tt.PARAMEDIS
			        , IF(ptm.JENIS=6 ,tt.PARAMEDIS
			          , IF(ptm.JENIS=7 ,tt.PENATA_ANASTESI
			            , IF(ptm.JENIS=8 ,0
			              , IF(ptm.JENIS=9 ,0
			                , IF(ptm.JENIS=10 ,0,0)))))))))) TARIF_JASA
		, master.getNamaLengkapPegawai(mp.NIP) PEGAWAI
	/*	, (SELECT REPLACE(GROUP_CONCAT(IF(ptg.JENIS IN (1,2),CONCAT(''- '',master.getNamaLengkapPegawai(mp.NIP)),CONCAT(''- '',master.getNamaLengkapPegawai(mpp.NIP)))),'',-'',''\r-'') 
				FROM layanan.petugas_tindakan_medis ptg
					  LEFT JOIN master.dokter dok ON ptg.MEDIS=dok.ID AND ptg.JENIS IN (1,2)
					  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					  LEFT JOIN master.pegawai mpp ON mpp.ID=ptg.MEDIS AND ptg.JENIS NOT IN (1,2)
				WHERE ptg.TINDAKAN_MEDIS=tm.ID
				GROUP BY ptg.TINDAKAN_MEDIS
				LIMIT 1) PEGAWAI */
		, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLMASUK 
		, DATE_FORMAT(pp.TANGGAL,''%H:%i:%s'') WAKTUMASUK
		, DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y'') TGLKELUAR
		, DATE_FORMAT(pl.TANGGAL,''%H:%i:%s'') WAKTUKELUAR   
		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
	FROM  pembayaran.rincian_tagihan_paket rt
	     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID 
		  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.STATUS!=0 AND ptm.JENIS=1
		  LEFT JOIN master.dokter dok1 ON ptm.MEDIS=dok1.ID AND ptm.JENIS IN (1,2)
		  LEFT JOIN master.pegawai mp ON dok1.NIP=mp.NIP
		  LEFT JOIN medicalrecord.operasi_di_tindakan mot ON tm.ID=mot.TINDAKAN_MEDIS AND mot.`STATUS`!=0
		  LEFT JOIN medicalrecord.operasi op ON mot.ID=op.ID AND op.`STATUS`!=0
		  LEFT JOIN master.tarif_tindakan tt ON rt.TARIF_ID=tt.ID
		  LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR = tm.KUNJUNGAN
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.STATUS=1
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.ruangan ra ON tp.RUANGAN=ra.ID AND ra.JENIS=5
		  LEFT JOIN master.referensi jka ON ra.JENIS_KUNJUNGAN=jka.ID AND jka.JENIS=15
		  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
		  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pp.STATUS!=0
	  AND rt.`STATUS` NOT IN (0)
	  ',IF(RUANGAN=0,'',CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''')),' 
	  	ORDER BY pp.TANGGAL, tm.TANGGAL, ptm.JENIS, ptm.MEDIS)');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanFarmasiPerobat
DROP PROCEDURE IF EXISTS `LaporanFarmasiPerobat`;
DELIMITER //
CREATE PROCEDURE `LaporanFarmasiPerobat`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT,
	IN `JENISINVENTORY` INT,
	IN `JENISKATEGORI` INT,
	IN `KATEGORIBARANG` INT,
	IN `JENISGENERIK` TINYINT,
	IN `JENISFORMULARIUM` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
	DECLARE vJENISINVENTORY VARCHAR(11);
	DECLARE vKATEGORIBARANG VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vJENISINVENTORY = CONCAT(JENISINVENTORY,'%');
   SET vKATEGORIBARANG = CONCAT(KATEGORIBARANG,'%');
   
	SET @sqlText = CONCAT('
		SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST,lf.ID NOMOR, lf.KUNJUNGAN, lf.TANGGAL, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER
		   , CONCAT(''LAPORAN PELAYANAN '',UPPER(jk.DESKRIPSI),'' PER OBAT'') JENISLAPORAN
			, rg.DESKRIPSI RUANG, r.DESKRIPSI ASALPENGIRIM, master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y'') TGLLAHIR
			, ps.ALAMAT,LPAD(ps.NORM,8,''0'') NORM
			, CONCAT(''RESEP '',UPPER(jenisk.DESKRIPSI)) JENISRESEP, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
			, ib.NAMA NAMAOBAT, lf.JUMLAH, SUM(rt.JUMLAH) JMLOBAT, rt.TARIF, SUM(rt.JUMLAH * rt.TARIF) TOTAL, COUNT(lf.KUNJUNGAN) JMLR
			, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.`STATUS` STATUSLAYANAN
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
			, if(ib.JENIS_GENERIK=1,''GENERIK'',''NON GENERIK'') GENERIK
			, mr.DESKRIPSI MERK, fr.DESKRIPSI FORMULARIUM, inventory.getGolonganPerBarang(ib.ID) GOLONGAN
			, master.getHeaderKategoriBarang(ik.ID) KATEGORIBARANG
		   /*, (SELECT SUM(JUMLAH) 
					  FROM inventory.transaksi_stok_ruangan tsr
					     , inventory.barang_ruangan br
					 WHERE tsr.JENIS IN (20, 21, 31, 32, 34)
					   AND tsr.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					   AND tsr.BARANG_RUANGAN=br.ID AND br.RUANGAN=pk.RUANGAN
					   AND br.BARANG=ib.ID) MASUK*/
			FROM layanan.farmasi lf
				  LEFT JOIN master.referensi ref ON lf.ATURAN_PAKAI=ref.ID AND ref.JENIS=41
				  LEFT JOIN pembayaran.rincian_tagihan rt ON lf.ID=rt.REF_ID AND rt.JENIS=4
				, pendaftaran.kunjungan pk
			     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
			     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
				  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
				  LEFT JOIN master.ruangan rg ON pk.RUANGAN=rg.ID AND rg.JENIS=5
				  LEFT JOIN master.referensi jk ON rg.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
				  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
				  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
			     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
			   , pendaftaran.pendaftaran pp
				  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
				  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				, inventory.barang ib
				  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
				  LEFT JOIN master.referensi mr ON ib.MERK=mr.ID AND mr.JENIS=39
				  LEFT JOIN master.referensi fr ON ib.FORMULARIUM=fr.ID AND fr.JENIS=176
				#  LEFT JOIN inventory.penggolongan_barang gb ON ib.ID = gb.BARANG AND gb.CHECKED = 1
				, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
			WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
				AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID AND rg.JENIS_KUNJUNGAN=',LAPORAN,'
				AND lf.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND pk.RUANGAN LIKE ''',vRUANGAN,'''
				',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
			GROUP BY ib.ID	
			ORDER BY KATEGORIBARANG, NAMAOBAT
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanJadwalOperasi
DROP PROCEDURE IF EXISTS `LaporanJadwalOperasi`;
DELIMITER //
CREATE PROCEDURE `LaporanJadwalOperasi`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10)
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);      
   SET vRUANGAN = CONCAT(RUANGAN,'%');	
	SET @sqlText = CONCAT('
	
	SELECT INST.*, rjo.KODE, DATE_FORMAT(rjo.TANGGAL,''%d-%m-%Y'') TANGGAL_JADWAL, DATE_FORMAT(rjo.JAM,''%H:%i:%s'') JAM_JADWAL, rjo.RUANGAN, DATE_FORMAT(rjo.TIMESTAMP,''%d-%m-%Y %H:%i:%s'') INPUTJADWAL
	, rok.DESKRIPSI RUANG_MENJADWAL, pp.NORM
			, ro.DESKRIPSI RUANGOK, master.getNamaLengkap(pp.NORM) NAMAPS, master.getNamaLengkapPegawai(md.NIP) DOKTER, rjo.TINDAKAN, rjo.DIAGNOSA
				FROM jadwal_operasi.request_jadwal_operasi rjo
				      LEFT JOIN jadwal_operasi.jadwal_operasi jo ON rjo.KODE=jo.KODE AND jo.`STATUS`!=0
				      LEFT JOIN master.ruangan ro ON rjo.RUANGAN=ro.ID
				      LEFT JOIN pendaftaran.kunjungan pk ON rjo.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
				      LEFT JOIN master.ruangan rok ON pk.RUANGAN=rok.ID
				      LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
				      LEFT JOIN master.dokter md ON rjo.DOKTER=md.ID
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
				WHERE rjo.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''AND rjo.STATUS!=0 
			AND ro.ID LIKE ''',vRUANGAN,'''
	 ORDER BY ro.ID, rok.ID, rjo.TANGGAL ASC, rjo.JAM ASC
	');	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanKlaimBPJS
DROP PROCEDURE IF EXISTS `LaporanKlaimBPJS`;
DELIMITER //
CREATE PROCEDURE `LaporanKlaimBPJS`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `LAPORAN` TINYINT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT,
	IN `RUANGAN` INT,
	IN `STATUS` INT
)
BEGIN	
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	
	SELECT r.JENIS_KUNJUNGAN INTO VJENIS_KUNJUNGAN
	  FROM `master`.ruangan r 
	 WHERE r.ID = RUANGAN;
	 
	IF FOUND_ROWS() = 0 THEN
		SET VJENIS_KUNJUNGAN = 0;
	ELSE
		SET VJENIS_KUNJUNGAN = IF(VJENIS_KUNJUNGAN = 3, 1, 2);
	END IF;
	SET LAPORAN = VJENIS_KUNJUNGAN;
	
	SET @sqlText = CONCAT(
	  'SELECT INST.NAMAINST, INST.ALAMATINST, NOPEN, NORM, NAMAPASIEN, NOKARTU, NOSEP, NOFPK
	        , TGLSEP, TGLPULANG, KELAS, JENISPELAYANAN, KODEJENISPELAYANAN, KODEINACBG, INACBG
	        , PENGAJUAN, DISETUJUI
	        , IF(',LAPORAN,'=0,''SEMUA'',IF(',LAPORAN,'=1,''RAWAT INAP'',IF(',LAPORAN,'=2,''RAWAT JALAN'',''''))) JENISP
			 FROM (
                SELECT pj.NOPEN, LPAD(k.peserta_noMR,8,''0'') NORM, k.peserta_nama NAMAPASIEN, k.peserta_noKartu NOKARTU, k.noSEP NOSEP, k.noFPK NOFPK
                , k.tglSep TGLSEP, k.tglPulang TGLPULANG
                , k.kelasRawat KELAS
                , IF(k.jenisPelayanan=1,''Rawat Inap'',''Rawat Jalan'') JENISPELAYANAN
                , k.jenisPelayanan KODEJENISPELAYANAN
                , k.inacbg_kode KODEINACBG, k.inacbg_nama INACBG
                , k.biaya_byPengajuan PENGAJUAN, k.biaya_bySetujui DISETUJUI
            FROM bpjs.klaim k
                 LEFT JOIN pendaftaran.penjamin pj ON k.noSEP=pj.NOMOR AND pj.JENIS=2
            WHERE ',
				IF(STATUS = 3, CONCAT('CONCAT(STR_TO_DATE(SUBSTRING(k.noFPK, 3, 6), ''%d%m%y''), '' 00:00:00'') BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''), CONCAT('CONCAT(k.tglPulang, '' 00:00:00'') BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')), '
              AND k.`status_id`= ', STATUS, 
              IF(VJENIS_KUNJUNGAN = 0, '', CONCAT(' AND k.jenisPelayanan = ', VJENIS_KUNJUNGAN)),
					 '
            GROUP BY k.noSEP
        ) ab
        , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
                    FROM aplikasi.instansi ai
                        , master.ppk p
                    WHERE ai.PPK=p.ID) INST
        ');
	

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanKlikBayarKasirPerPasien
DROP PROCEDURE IF EXISTS `LaporanKlikBayarKasirPerPasien`;
DELIMITER //
CREATE PROCEDURE `LaporanKlikBayarKasirPerPasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @brs=0;
	SET @ksr=NULL;
	SET @kj=0;
	
	SET @sqlText = CONCAT(
		'SELECT a.*, IF((@ksr IS NULL OR @ksr!=KASIR) OR (@ksr=KASIR AND @kj!=IDJENISKUNJUNGAN),@brs:=1, @brs:=@brs+1) brs, @ksr:=KASIR, @kj:=IDJENISKUNJUNGAN 
			FROM (
			SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 (SELECT SUM(TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=2 AND g.STATUS!=0) EDC,
			 (SELECT SUM(TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=3 AND g.STATUS!=0) TRANSFER,
			 (SELECT SUM(TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=4 AND g.STATUS!=0) SETOR_BANK,
			 (SELECT SUM(TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=5 AND g.STATUS!=0) VA,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 
	   AND pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''  AND tg.JENIS = 1
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
	UNION
	SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 (SELECT SUM(g.TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=2 AND g.STATUS!=0) EDC,
			 (SELECT SUM(g.TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=3 AND g.STATUS!=0) TRANSFER,
			 (SELECT SUM(g.TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=4 AND g.STATUS!=0) SETOR_BANK,
			 (SELECT SUM(g.TOTAL) FROM pembayaran.pembayaran_tagihan g WHERE g.TAGIHAN = pt.TAGIHAN AND g.JENIS_LAYANAN_ID=5 AND g.STATUS!=0) VA,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	      LEFT JOIN pembayaran.pelunasan_piutang_pasien p3 ON p3.ID = tg.REF
	     LEFT JOIN pembayaran.tagihan tg2 ON tg2.ID = p3.TAGIHAN_PIUTANG
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON ptp.TAGIHAN = tg2.ID AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	    LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 
	   AND pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''  AND tg.JENIS = 2
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		
		) a
   ORDER BY a.KASIR, JENISKUNJUNGAN, DATE(a.TANGGAL),a.CARABAYAR
			
	');

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanKlikBayarPerKasir
DROP PROCEDURE IF EXISTS `LaporanKlikBayarPerKasir`;
DELIMITER //
CREATE PROCEDURE `LaporanKlikBayarPerKasir`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT  NAMAINST, ALAMATINST, KASIR,  BUKA, TUTUP, JENISKUNJUNGAN, CARABAYAR
				, SUM(TOTALTAGIHAN) TOTALTAGIHAN, SUM(PEMBULATAN), SUM(TOTALDISKON) TOTALDISKON
				, SUM(TOTALEDC) TOTALEDC, SUM(TOTALPENJAMINTAGIHAN) TOTALPENJAMINTAGIHAN
				, SUM(TOTALPIUTANG) TOTALPIUTANG, SUM(TOTALDEPOSIT) TOTALDEPOSIT, SUM(PENERIMAAN) PENERIMAAN
			FROM (
			SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, pt.TRANSAKSI_KASIR_NOMOR,tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 IF(crbyr.ID IN (1,2),crbyr.DESKRIPSI,''IKS'') CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 
	   AND pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''  AND tg.JENIS = 1
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
	UNION
	SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, pt.TRANSAKSI_KASIR_NOMOR,tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 IF(crbyr.ID IN (1,2),crbyr.DESKRIPSI,''IKS'') CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	      LEFT JOIN pembayaran.pelunasan_piutang_pasien p3 ON p3.ID = tg.REF
	     LEFT JOIN pembayaran.tagihan tg2 ON tg2.ID = p3.TAGIHAN_PIUTANG
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON ptp.TAGIHAN = tg2.ID AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	    LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 
	   AND pt.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''  AND tg.JENIS = 2
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		
		) a
    GROUP BY a.KASIR, TRANSAKSI_KASIR_NOMOR, JENISKUNJUNGAN, IF(a.CARABAYAR NOT IN (1,2),3,a.CARABAYAR)
    ORDER BY a.KASIR, TRANSAKSI_KASIR_NOMOR, JENISKUNJUNGAN, IF(a.CARABAYAR NOT IN (1,2),3,a.CARABAYAR)
			
	');

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanMonitoringPengunjung
DROP PROCEDURE IF EXISTS `LaporanMonitoringPengunjung`;
DELIMITER //
CREATE PROCEDURE `LaporanMonitoringPengunjung`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

  
  DECLARE vRUANGAN VARCHAR(11);
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  SET @sqlText = CONCAT('
    SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
        , p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
        , CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
        , IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
        , IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
        , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT((SELECT tk.MASUK
    FROM pendaftaran.kunjungan tk
    WHERE tk.NOPEN=pd.NOMOR AND tk.REF IS NULL LIMIT 1),''%d-%m-%Y %H:%i:%s'') TGLTERIMA
        , DATE_FORMAT(TIMEDIFF((SELECT tk.MASUK
    FROM pendaftaran.kunjungan tk
    WHERE tk.NOPEN=pd.NOMOR AND tk.REF IS NULL LIMIT 1),pd.TANGGAL),''%H:%i:%s'') SELISIH
        , ref.DESKRIPSI CARABAYAR, stt.DESKRIPSI KET
        , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
         , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
        , pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
        , INST.NAMAINST, INST.ALAMATINST
        , master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
        , master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
        , kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , IF(jkr.ID=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pd.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jkr.ID=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LOS
				, IF(jkr.ID=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pd.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
      FROM master.pasien p
          LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
        , pendaftaran.pendaftaran pd
          LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
          LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
          LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
          LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.STATUS!=0
          LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
          LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.STATUS!=0
          LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.STATUS!=0
          LEFT JOIN inacbg.hasil_grouping cbg ON pd.NOMOR=cbg.NOPEN
		  	 LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
		  	 LEFT JOIN layanan.pasien_pulang lpp ON pd.NOMOR=lpp.NOPEN AND lpp.STATUS=1
		  	 LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
		  	 LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pd.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
		  	 LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID
        , pendaftaran.tujuan_pasien tp
          LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
          LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
          LEFT JOIN master.referensi stt ON tp.STATUS=stt.ID AND stt.JENIS=24
        , master.ruangan jkr  
          LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
        , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
          FROM aplikasi.instansi ai
            , master.ppk p
          WHERE ai.PPK=p.ID) INST
        , (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
      WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.STATUS IN (1,2)
          AND tp.RUANGAN=jkr.ID AND jkr.JENIS=5 AND pd.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pd.STATUS IN (1,2)
          AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
          ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
          ORDER BY tp.RUANGAN
          ');
  PREPARE stmt FROM @sqlText;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienGrouping
DROP PROCEDURE IF EXISTS `LaporanPasienGrouping`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienGrouping`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `PSTATUS_GROUPING` TINYINT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, pp.TANGGAL TGLMASUK, IF(r.JENIS_KUNJUNGAN=3,lpp.TANGGAL,pp.TANGGAL) TGLKELUAR, pp.NOMOR, LPAD(pp.NORM,8,''0'') NORM, kap.NOMOR NOMORKARTU, pj.NOMOR NOSEP
	  , master.getNamaLengkap(pp.NORM) NAMAPASIEN, hl.CODECBG,  hl.TOTALTARIF TARIFCBG
	  , IFNULL(hl.TARIFRS,ROUND(pembayaran.getTotalTagihan(tpd.TAGIHAN))) TARIFRS, (hl.TOTALTARIF - IFNULL(hl.TARIFRS,ROUND(pembayaran.getTotalTagihan(tpd.TAGIHAN)))) SELISIH
	  , (SELECT ''Lanjut Rawat Inap''
				FROM pendaftaran.pendaftaran pd
					, pendaftaran.tujuan_pasien tpp
					, master.ruangan rg
				WHERE pd.NORM=pp.NORM AND pd.TANGGAL > pp.TANGGAL
				AND HOUR(TIMEDIFF(pd.TANGGAL, pp.TANGGAL)) <= 24 
				AND pd.NOMOR=tpp.NOPEN AND pd.`STATUS`!=0 AND tpp.`STATUS`!=0
				AND tpp.RUANGAN=rg.ID AND rg.JENIS_KUNJUNGAN=3
				ORDER BY pd.tanggal DESC
				LIMIT 1) KETERANGAN
		, IF(hl.`STATUS`=1,''Final'',''Belum'') STATUSGROUPING
		, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pp.TANGGAL)) LOS
		, master.getNamaLengkapPegawai(dok.NIP) DPJP
		, CONCAT(''BRIDGING PASIEN '',IF(r.JENIS_KUNJUNGAN=3,''RAWAT INAP '',''RAWAT JALAN ''),IF(hl.`STATUS`=1,''FINAL'',''BELUM FINAL'')) JENISLAPORAN
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER	
		, IF(r.JENIS_KUNJUNGAN=3, rg.DESKRIPSI, r.DESKRIPSI) UNITPELAYANAN
	FROM pendaftaran.pendaftaran pp
	     LEFT JOIN (SELECT * FROM layanan.pasien_pulang GROUP BY NOPEN) lpp ON lpp.NOPEN=pp.NOMOR AND lpp.`STATUS`=1
	     LEFT JOIN pendaftaran.kunjungan k ON lpp.kunjungan=k.NOMOR AND k.`STATUS`!=0
	     LEFT JOIN `master`.ruangan rg ON k.RUANGAN=rg.ID 
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0
	     LEFT JOIN master.ruangan r ON r.ID=tp.RUANGAN AND r.JENIS=5
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN AND pj.JENIS=2
	     LEFT JOIN master.kartu_asuransi_pasien kap ON pp.NORM=kap.NORM AND kap.JENIS=2
	     LEFT JOIN inacbg.hasil_grouping hl ON pp.NOMOR=hl.NOPEN
	     LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON tpd.PENDAFTARAN=pp.NOMOR AND tpd.`STATUS`!=0 AND tpd.UTAMA=1
	     LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE pp.`STATUS`!=0 
		',IF(LAPORAN=3,' AND r.JENIS_KUNJUNGAN=3',' AND r.JENIS_KUNJUNGAN IN (1,2)'),'
	  AND IF(r.JENIS_KUNJUNGAN=3,lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''',pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''')
	  	',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(PSTATUS_GROUPING=1,'AND hl.`STATUS`=1',' AND (hl.`STATUS`!=1 OR hl.`STATUS` IS NULL)'),'
		',IF(LAPORAN=3,CONCAT(' AND rg.ID LIKE ''',vRUANGAN,''''),CONCAT(' AND r.ID LIKE ''',vRUANGAN,'''')),'
		
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienKeluar
DROP PROCEDURE IF EXISTS `LaporanPasienKeluar`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienKeluar`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN PASIEN KELUAR '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 LPAD(ps.NORM,8,''0'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, 
			 CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR, 
			 crbyr.DESKRIPSI CARABAYAR, master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, 
			 IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN, pp.TANGGAL TGLMASUK, lpp.TANGGAL TGLKELUAR, 
			 cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR, r.DESKRIPSI UNIT1, r.ID IDRUANGAN,
			 master.getNamaLengkapPegawai(md.NIP) DPJP, lpp.DIAGNOSA, master.getTindakan(lpp.NOPEN) TINDAKAN,
			 master.getDiagnosaPasien(lpp.NOPEN) ICD10, master.getProsedurePasien(lpp.NOPEN) ICD9, smf.DESKRIPSI SMF,
			 master.getDokterTindakan(pp.NOMOR) DPJP2,
			IF(n.IKUT_IBU=1,CONCAT(''Rawat Gabung Ibu - '',r.DESKRIPSI,
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT(''  ('', rk1.KAMAR, ''/'', rkt1.TEMPAT_TIDUR, ''/'', kls11.DESKRIPSI, '')''
						 , IF(ki.TITIPAN = 1, CONCAT('' Pasien Titipan '', kls12.DESKRIPSI), '''')), ''''))
					 , CONCAT(r.DESKRIPSI,
						 	IF(r.JENIS_KUNJUNGAN = 3,
						 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''
								 , IF(pk.TITIPAN = 1, CONCAT('' Pasien Titipan '', kls1.DESKRIPSI), '''')), ''''))) UNIT, pp.BERAT_BAYI, pp.PANJANG_BAYI,
			IF(pt.NOMOR IS NULL, ''Belum Klik Bayar'',''Sudah Klik Bayar'') STATUS_BAYAR,
			IF(hg.NOPEN IS NULL, ''Belum Grouping'',IF(hg.`STATUS`=1,''Sudah Final'',''Belum Final'')) STATUS_GROUPING,
			hg.CODECBG, hg.TARIFCBG, cbg.DESKRIPSI DESKRIPSICBG, tn.TOTAL TARIFRS
	FROM layanan.pasien_pulang lpp
		  LEFT JOIN master.dokter md ON lpp.DOKTER=md.ID
		  LEFT JOIN master.dokter_smf mds ON md.ID=mds.DOKTER
		  LEFT JOIN master.referensi smf ON mds.SMF=smf.ID AND smf.JENIS=26
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
  		  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
  		  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
  		  LEFT JOIN `master`.referensi kls1 ON kls1.JENIS = 19 AND kls1.ID = pk.TITIPAN_KELAS,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN master.referensi rjk ON ps.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		  LEFT JOIN pembayaran.tagihan_pendaftaran tg ON pp.NOMOR=tg.PENDAFTARAN AND tg.UTAMA=1 AND tg.`STATUS`=1
		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON tg.TAGIHAN=pt.TAGIHAN AND pt.JENIS=1 AND pt.`STATUS`=2
		  LEFT JOIN inacbg.hasil_grouping hg ON pp.NOMOR=hg.NOPEN
		  LEFT JOIN inacbg.inacbg cbg ON hg.CODECBG=cbg.KODE AND cbg.VERSION=''5'' AND cbg.JENIS=1
		  LEFT JOIN pembayaran.tagihan tn ON tg.TAGIHAN=tn.ID AND tn.`STATUS`!=0
		  LEFT JOIN pendaftaran.tujuan_pasien n ON pp.NOMOR=n.NOPEN
		  LEFT JOIN pendaftaran.kunjungan ki ON n.KUNJUNGAN_IBU=ki.NOMOR AND ki.`STATUS`!=0
		  LEFT JOIN `master`.ruang_kamar_tidur rkt1 ON rkt1.ID = ki.RUANG_KAMAR_TIDUR
  		  LEFT JOIN `master`.ruang_kamar rk1 ON rk1.ID = rkt1.RUANG_KAMAR
  		  LEFT JOIN `master`.referensi kls11 ON kls11.JENIS = 19 AND kls11.ID = rk1.KELAS
  		  LEFT JOIN `master`.referensi kls12 ON kls12.JENIS = 19 AND kls12.ID = ki.TITIPAN_KELAS,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE lpp.KUNJUNGAN=pk.NOMOR AND lpp.`STATUS`=1 ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		GROUP BY lpp.NOPEN
		ORDER BY IDRUANGAN, lpp.TANGGAL
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienMasuk
DROP PROCEDURE IF EXISTS `LaporanPasienMasuk`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienMasuk`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
				, LPAD(p.NORM,8,''0'') NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(pk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pp.NOMOR NOPEN, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
				, DATE_FORMAT(pk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLMASUK
				, TIMEDIFF(pk.MASUK,pp.TANGGAL) SELISIH
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, r.DESKRIPSI UNITPELAYANAN
				, IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(rk.KAMAR, '' - '', kls.DESKRIPSI), '''') KAMAR
				, INST.NAMAINST, INST.ALAMATINST
				, (SELECT CONCAT(jkj.DESKRIPSI,''\r'',''('',DATE_FORMAT(pr.TANGGAL,''%d-%m-%Y %H:%i:%s''),'')'')
						FROM pendaftaran.pendaftaran pr
							, pendaftaran.tujuan_pasien tpr
							, master.ruangan rpr
							  LEFT JOIN `master`.referensi jkj ON rpr.JENIS_KUNJUNGAN=jkj.ID AND jkj.JENIS=15
							, pendaftaran.kunjungan kpr
							  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
						  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
						  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
						WHERE pr.NORM=pp.NORM 
						  AND pr.TANGGAL < pp.TANGGAL
						  AND pr.`STATUS`!=0 AND pr.NOMOR=tpr.NOPEN
						  AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN IN (1,2)
						  AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.`STATUS`!=0
						ORDER BY pr.TANGGAL DESC
						LIMIT 1) REG_ASAL
			FROM pendaftaran.pendaftaran pp
			     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			     LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN layanan.pasien_pulang lpp ON pp.NOMOR=lpp.NOPEN AND lpp.`STATUS`!=0
				, pendaftaran.tujuan_pasien tp
				, master.ruangan r
				, pendaftaran.kunjungan pk
				  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  		     LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		     LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			
			WHERE p.NORM=pp.NORM AND pp.NOMOR=tp.NOPEN  AND pp.NOMOR=pk.NOPEN AND tp.RUANGAN=pk.RUANGAN AND pp.STATUS IN (1,2) AND pk.REF IS NULL
					',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
					AND pk.RUANGAN=r.ID AND r.JENIS=5 AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pk.STATUS IN (1,2)
					AND r.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					');
					

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienODC
DROP PROCEDURE IF EXISTS `LaporanPasienODC`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienODC`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	   ( SELECT INST.NAMAINST, INST.ALAMATINST
		, p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(pt.TANGGAL) TGLBAYAR
		, r.DESKRIPSI RUANGAN, pp.TANGGAL TGLREG, 0 TOTALTAGIHAN
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN, IFNULL(kls.DESKRIPSI,''Non Kelas'') KELAS
		, jk.DESKRIPSI JENISKUNJUNGAN, pk.RUANGAN
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN, op.JENIS_OPERASI
		, tt.*, smf.DESKRIPSI SMF
		, IFNULL(master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP)) OPERATOR
		, IFNULL(master.getNamaLengkapPegawai(dok2.NIP),IFNULL(master.getNamaLengkapPegawai(dok1.NIP),master.getNamaLengkapPegawai(dok.NIP))) ANASTESI
		, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLMASUK 
		, DATE_FORMAT(pp.TANGGAL,''%H:%i:%s'') WAKTUMASUK
		, DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y'') TGLKELUAR
		, DATE_FORMAT(pl.TANGGAL,''%H:%i:%s'') WAKTUKELUAR   
		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
	FROM layanan.tindakan_medis tm
		  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		  LEFT JOIN master.tarif_tindakan tt ON tt.TINDAKAN=t.ID
		  LEFT JOIN layanan.petugas_tindakan_medis dtm ON tm.ID=dtm.TINDAKAN_MEDIS AND dtm.STATUS!=0 AND dtm.JENIS=1 AND dtm.KE=1
		  LEFT JOIN master.dokter dok1 ON dtm.MEDIS=dok1.ID
		  LEFT JOIN layanan.petugas_tindakan_medis atm ON tm.ID=atm.TINDAKAN_MEDIS AND atm.STATUS!=0 AND atm.JENIS=2 AND atm.KE=2
		  LEFT JOIN master.dokter dok2 ON atm.MEDIS=dok2.ID
		  LEFT JOIN master.pegawai mp ON dok1.NIP=mp.NIP  		  
		  LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR = tm.KUNJUNGAN
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.STATUS=1
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.ruangan ra ON tp.RUANGAN=ra.ID AND ra.JENIS=5
		  LEFT JOIN master.referensi jka ON ra.JENIS_KUNJUNGAN=jka.ID AND jka.JENIS=15
		  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
		  LEFT JOIN master.dokter_smf dsm ON dok.ID=dsm.DOKTER
		  LEFT JOIN `master`.referensi smf ON dsm.SMF=smf.ID AND smf.JENIS=26
		  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
		, medicalrecord.operasi op	
		, pembayaran.rincian_tagihan rt    
		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON rt.TAGIHAN=pt.TAGIHAN AND pt.STATUS !=0
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
		FROM aplikasi.instansi ai
			, master.ppk p
		WHERE ai.PPK=p.ID) INST
	WHERE tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pp.STATUS!=0 AND tm.ID = rt.REF_ID AND rt.JENIS = 3
	  AND tm.KUNJUNGAN=op.KUNJUNGAN AND op.`STATUS`!=0 AND op.JENIS_OPERASI=3	  
	  ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
	  ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' 
	  	GROUP BY rt.TAGIHAN
		ORDER BY tm.TANGGAL)');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienOperasi
DROP PROCEDURE IF EXISTS `LaporanPasienOperasi`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienOperasi`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `CARABAYAR` INT
)
BEGIN
	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT ''LAPORAN PASIEN OPERASI'' JENISLAPORAN
			, inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT ALAMATINST, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, ref.DESKRIPSI CARABAYAR
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER 
			, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
			, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
			, IFNULL(pg.NIP,mpdok.NIP) NIP
			, IFNULL(smf1.DESKRIPSI,smf.DESKRIPSI) SMF
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, ''1''),master.getNamaLengkapPegawai(mpdok.NIP)) DOKTEROPERATOR
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, ''2''),op.ASISTEN_DOKTER) ASISTEN_DOKTER
			, master.`getPelaksanaOperasi`(op.ID, ''3'') DRPERFUSI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, ''4''),master.getNamaLengkapPegawai(mpanas.NIP)) DOKTERANASTESI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, ''5''),op.ASISTEN_ANASTESI) ASISTEN_ANASTESI
			, master.`getPelaksanaOperasi`(op.ID, ''6'') PENATA
			, master.`getPelaksanaOperasi`(op.ID, ''7'') SCRUB
			, master.`getPelaksanaOperasi`(op.ID, ''8'') SIRKULER
			, master.`getPelaksanaOperasi`(op.ID, ''9'') PERFUSI
			, master.`getPelaksanaOperasi`(op.ID, ''10'') DRTAMU
			, master.`getPelaksanaOperasi2`(po.OPERASI_ID) LAINNYA
			, ja.DESKRIPSI JENISANASTESI, gol.DESKRIPSI GOLONGANOPERASI, jop.DESKRIPSI JENISOPERASI
			, IF(op.PA=1,''Ya'',''Tidak'') PEMERIKSAANPA
			, DATE_FORMAT(op.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLOPERASI
			, DATE_FORMAT(op.DIBUAT_TANGGAL,''%d-%m-%Y %H:%i:%s'') DBUATTANGGAL
			, pk.NOPEN
			, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
			, DATE_FORMAT(pk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLOP
			, TIMEDIFF(pk.MASUK,pp.TANGGAL) WAKTU_TUNGGU
			, TIME_TO_SEC(TIMEDIFF(pk.MASUK,pp.TANGGAL))/60 WAKTU_TUNGGU_MENIT
			, r.DESKRIPSI KAMAROPERASI
			, rasal.DESKRIPSI UNITPENGANTAR
			, rt.DESKRIPSI JNSTRANSFUSI
			, op.ID
			, op.INDIKASI
			, op.NAMA_OPERASI
			, op.JARINGAN_DIEKSISI
			, DATE_FORMAT(CONCAT(op.TANGGAL,'' '',op.WAKTU_MULAI),''%d-%m-%Y %H:%i:%s'') WAKTU_MULAI
			, DATE_FORMAT(CONCAT(op.TANGGAL,'' '',op.WAKTU_SELESAI),''%d-%m-%Y %H:%i:%s'') WAKTU_SELESAI
			, DATE_FORMAT(op.DURASI,''%H:%i:%s'') DURASI
			, op.KOMPLIKASI
			, op.PERDARAHAN
			, op.RUANGAN_PASCA_OPERASI
			, op.GUNAKAN_IMPLAN
			, op.JENIS_IMPLAN
			, op.NAMA_IMPLAN
			, op.NO_SERI_IMPLAN
			, op.JUMLAH_TRANSFUSI
			, op.PRA_BEDAH
			, op.PASCA_BEDAH
		
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
			, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT  
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND op.KUNJUNGAN=pk.NOMOR AND op.`STATUS` IN (1, 2)
	AND op.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
	AND r.ID LIKE ''',vRUANGAN,'''
	',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		GROUP BY op.ID
		ORDER BY pk.MASUK, KAMAROPERASI, SMF, DOKTEROPERATOR, UNITPENGANTAR
		');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPasienPerICD10
DROP PROCEDURE IF EXISTS `LaporanPasienPerICD10`;
DELIMITER //
CREATE PROCEDURE `LaporanPasienPerICD10`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KODEICD` CHAR(6),
	IN `UTAMA` CHAR(50),
	IN `LMT` SMALLINT
)
BEGIN
  DECLARE vRUANGAN VARCHAR(11);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');
  
 SET @sqlText = CONCAT('
	SELECT INST.NAMAINST, INST.ALAMATINST, CONCAT(''LAPORAN ICD 10 '',UPPER(jk.DESKRIPSI)) JENISLAPORAN,
			 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
			 IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			 LPAD(ps.NORM,8,''0'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP,
			 CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR, crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN,
		    pp.TANGGAL TGLMASUK, lpp.TANGGAL TGLKELUAR, cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR,
		    r.DESKRIPSI UNIT, md.KODE KODEICD10, kode.kode KODECBG, kode.DESKRIPSI NAMACBG, REVERSE(LEFT(REVERSE(kode.kode), INSTR(REVERSE(kode.kode),''-'')-1)) SL,
		    cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS,
			 GROUP_CONCAT((SELECT CONCAT(ms.CODE,''['',ms.STR,'']'') FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1)) DIAGNOSA,
			 IF(''',KODEICD,'''='''' OR ''',KODEICD,'''=''0'' ,''Semua'',(SELECT CONCAT(ms.CODE,''-'',ms.STR) FROM master.mrconso ms WHERE ms.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND ms.CODE=md.KODE LIMIT 1)) DIAGNOSAHEADER
	FROM pendaftaran.kunjungan pk
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN pendaftaran.kunjungan pk2 ON pk.NOPEN=pk2.NOPEN AND pk2.`STATUS` IN (1,2)
		  LEFT JOIN layanan.pasien_pulang lpp ON lpp.KUNJUNGAN=pk2.NOMOR AND lpp.`STATUS`=1
		  LEFT JOIN master.referensi cr ON lpp.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON lpp.KEADAAN=kd.ID AND kd.JENIS=46,
		  pendaftaran.pendaftaran pp
		  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		  LEFT JOIN inacbg.hasil_grouping cbg ON pp.NOMOR=cbg.NOPEN
		  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
		  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pp.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
		  LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID,
		  (SELECT DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk,
		  medicalrecord.diagnosa md,
		  pendaftaran.tujuan_pasien tp,
		  (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE  pk.NOPEN=md.NOPEN AND md.STATUS=1 AND md.INA_GROUPER=0 AND pp.NOMOR=tp.NOPEN AND pk.RUANGAN=tp.RUANGAN
	   AND IF(r.JENIS_KUNJUNGAN=3,NOT lpp.KUNJUNGAN IS NULL, TRUE)
		',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
		AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		AND pk.NOPEN=pp.NOMOR ',IF(KODEICD='''' OR KODEICD='0','',CONCAT(' AND md.KODE=''',KODEICD,'''')),'
		',IF(UTAMA=0,'',CONCAT(' AND md.UTAMA=1')),'
		',IF(LAPORAN=3,CONCAT(' AND lpp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''),CONCAT(' AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')),'  
	GROUP BY md.NOPEN
	',IF(LMT=0,'',CONCAT(' LIMIT ',LMT)),'
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPendapatanPerPasien
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerPasien`;
DELIMITER //
CREATE PROCEDURE `LaporanPendapatanPerPasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT INST.NAMAINST, INST.ALAMATINST,INSTALASI, ab.TAGIHAN, ab.REF, ab.JENIS, (SUM(ADMINISTRASI) - pembayaran.getTotalDiskonAdministrasi(ab.TAGIHAN)) ADMINISTRASI
		, (SUM(SARANA) - pembayaran.getTotalDiskonSarana(ab.TAGIHAN)) SARANA, SUM(BHP) BHP
		, (SUM(DOKTER_OPERATOR) - pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
		, SUM(PENATA_ANASTESI) PENATA_ANASTESI
		, (SUM(PARAMEDIS) - pembayaran.getTotalDiskonParamedis(ab.TAGIHAN)) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
		, TOTALTAGIHAN
		, (pembayaran.getTotalDiskon(ab.TAGIHAN)+ pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) TOTALDISKON
		, NORM, NAMAPASIEN, NOPEN,  TGLBAYAR
		, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
		, RUANGAN, CARABAYAR, TGLREG
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, (SELECT pl.TANGGAL FROM layanan.pasien_pulang pl WHERE pl.NOPEN=ab.NOPEN AND pl.`STATUS`!=0 LIMIT 1) TGLKELUAR
	FROM (
	/*Tindakan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
				, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		   LEFT JOIN `master`.tindakan mt ON mt.ID = tm.TINDAKAN
	  		   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			   
			 , master.tarif_tindakan tt 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tt.ID AND rt.JENIS=3
		GROUP BY t.TAGIHAN
		UNION
/*Administrasi Non Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt 
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID NOT IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Administrasi Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			  LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
	  		  LEFT JOIN `master`.ruangan r ON r.ID = kj.RUANGAN
	  		  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	  		  LEFT JOIN pendaftaran.konsul ks ON kj.REF=ks.NOMOR AND ks.`STATUS`!=0
			  LEFT JOIN pendaftaran.kunjungan asal ON ks.KUNJUNGAN=asal.NOMOR AND asal.`STATUS`!=0
			  LEFT JOIN `master`.ruangan rasal ON rasal.ID = asal.RUANGAN
			  LEFT JOIN master.referensi rf1 ON rasal.JENIS_KUNJUNGAN=rf1.ID AND rf1.JENIS=15
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kj.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Akomodasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 ,  master.tarif_ruang_rawat trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=2
		GROUP BY t.TAGIHAN
		UNION
		
		/*Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(rt.TARIF * rt.JUMLAH) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(rt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
			   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 , inventory.harga_barang tf
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=tf.ID AND rt.JENIS=4
		GROUP BY t.TAGIHAN
		UNION
		/*Paket*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tp.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tp.SARANA * rt.JUMLAH) SARANA, SUM(tp.BHP * rt.JUMLAH) BHP
				, SUM(tp.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tp.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tp.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tp.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tp.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tp.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tp.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt  
			 , master.distribusi_tarif_paket tp
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
		GROUP BY t.TAGIHAN
		UNION
		/*Penjualan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
				, '''' NORM, ppj.PENGUNJUNG NAMAPASIEN, '''' NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
				, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
			FROM pembayaran.pembayaran_tagihan t
				  LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
			     LEFT JOIN penjualan.penjualan ppj ON t.TAGIHAN=ppj.NOMOR
			     LEFT JOIN master.ruangan ru ON ppj.RUANGAN=ru.ID AND ru.JENIS=5
			     LEFT JOIN master.referensi rfu ON ru.JENIS_KUNJUNGAN=rfu.ID AND rfu.JENIS=15
			     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
			WHERE t.`STATUS` !=0 AND t.JENIS=8 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND ppj.RUANGAN LIKE ''',vRUANGAN,'''  AND ru.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
			GROUP BY t.TAGIHAN
			UNION
			/*O2*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 ,  master.tarif_o2 trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=6
		GROUP BY t.TAGIHAN
	) ab
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
		FROM aplikasi.instansi ai
			, master.ppk p
		WHERE ai.PPK=p.ID) INST
	GROUP BY ab.TAGIHAN
			
	');

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPendapatanPerPasienIKS
DROP PROCEDURE IF EXISTS `LaporanPendapatanPerPasienIKS`;
DELIMITER //
CREATE PROCEDURE `LaporanPendapatanPerPasienIKS`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT INST.NAMAINST, INST.ALAMATINST,INSTALASI, ab.TAGIHAN, ab.REF, ab.JENIS, (SUM(ADMINISTRASI) - pembayaran.getTotalDiskonAdministrasi(ab.TAGIHAN)) ADMINISTRASI
		, (SUM(SARANA) - pembayaran.getTotalDiskonSarana(ab.TAGIHAN)) SARANA, SUM(BHP) BHP
		, (SUM(DOKTER_OPERATOR) - pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) DOKTER_OPERATOR, SUM(DOKTER_ANASTESI) DOKTER_ANASTESI, SUM(DOKTER_LAINNYA) DOKTER_LAINNYA
		, SUM(PENATA_ANASTESI) PENATA_ANASTESI
		, (SUM(PARAMEDIS) - pembayaran.getTotalDiskonParamedis(ab.TAGIHAN)) PARAMEDIS, SUM(NON_MEDIS) NON_MEDIS, SUM(TARIF) TARIF
		, TOTALTAGIHAN
		, (pembayaran.getTotalDiskon(ab.TAGIHAN)+ pembayaran.getTotalDiskonDokter(ab.TAGIHAN)) TOTALDISKON
		, NORM, NAMAPASIEN, NOPEN,  TGLBAYAR
		, JENISBAYAR, IDJENISKUNJUNGAN, JENISKUNJUNGAN
		, RUANGAN, CARABAYAR, TGLREG
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, (SELECT pl.TANGGAL FROM layanan.pasien_pulang pl WHERE pl.NOPEN=ab.NOPEN AND pl.`STATUS`!=0 LIMIT 1) TGLKELUAR
	FROM (
	/*Tindakan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tt.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tt.SARANA * rt.JUMLAH) SARANA, SUM(tt.BHP * rt.JUMLAH) BHP
				, SUM(tt.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tt.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tt.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tt.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tt.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tt.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		   LEFT JOIN `master`.tindakan mt ON mt.ID = tm.TINDAKAN
	  		   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			   LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			   
			 , master.tarif_tindakan tt 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				    ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tt.ID AND rt.JENIS=3
		GROUP BY t.TAGIHAN
		UNION
/*Administrasi Non Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt 
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID NOT IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Administrasi Pelayanan Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(ta.TARIF * rt.JUMLAH) ADMINISTRASI, 0 SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(ta.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			 , pembayaran.rincian_tagihan rt 
			  LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
	  		  LEFT JOIN `master`.ruangan r ON r.ID = kj.RUANGAN
	  		  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	  		  LEFT JOIN pendaftaran.konsul ks ON kj.REF=ks.NOMOR AND ks.`STATUS`!=0
			  LEFT JOIN pendaftaran.kunjungan asal ON ks.KUNJUNGAN=asal.NOMOR AND asal.`STATUS`!=0
			  LEFT JOIN `master`.ruangan rasal ON rasal.ID = asal.RUANGAN
			  LEFT JOIN master.referensi rf1 ON rasal.JENIS_KUNJUNGAN=rf1.ID AND rf1.JENIS=15
			 ,  master.tarif_administrasi ta 
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kj.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=ta.ID AND rt.JENIS=1 AND rt.TARIF_ID IN (3,4)
		GROUP BY t.TAGIHAN
		UNION
		/*Akomodasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 ,  master.tarif_ruang_rawat trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=2
		GROUP BY t.TAGIHAN
		UNION
		
		/*Farmasi*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(rt.TARIF * rt.JUMLAH) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(rt.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
			   LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 , inventory.harga_barang tf
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=tf.ID AND rt.JENIS=4
		GROUP BY t.TAGIHAN
		UNION
		/*Paket*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, SUM(tp.ADMINISTRASI * rt.JUMLAH) ADMINISTRASI, SUM(tp.SARANA * rt.JUMLAH) SARANA, SUM(tp.BHP * rt.JUMLAH) BHP
				, SUM(tp.DOKTER_OPERATOR * rt.JUMLAH) DOKTER_OPERATOR, SUM(tp.DOKTER_ANASTESI * rt.JUMLAH) DOKTER_ANASTESI, SUM(tp.DOKTER_LAINNYA * rt.JUMLAH) DOKTER_LAINNYA
				, SUM(tp.PENATA_ANASTESI * rt.JUMLAH) PENATA_ANASTESI, SUM(tp.PARAMEDIS * rt.JUMLAH) PARAMEDIS, SUM(tp.NON_MEDIS * rt.JUMLAH) NON_MEDIS, SUM(tp.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
				
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
			 , pembayaran.rincian_tagihan rt  
			 , master.distribusi_tarif_paket tp
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tp.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),' AND t.TAGIHAN=rt.TAGIHAN  AND rt.TARIF_ID=tp.ID AND rt.JENIS=5
		GROUP BY t.TAGIHAN
		UNION
		/*Penjualan*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, 0 SARANA, SUM(t.TOTAL) BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(t.TOTAL) TARIF
				, '''' NORM, ppj.PENGUNJUNG NAMAPASIEN, '''' NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rfu.ID IDJENISKUNJUNGAN, rfu.DESKRIPSI JENISKUNJUNGAN
				, ru.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, ppj.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
			FROM pembayaran.pembayaran_tagihan t
				  LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
			     LEFT JOIN penjualan.penjualan ppj ON t.TAGIHAN=ppj.NOMOR
			     LEFT JOIN master.ruangan ru ON ppj.RUANGAN=ru.ID AND ru.JENIS=5
			     LEFT JOIN master.referensi rfu ON ru.JENIS_KUNJUNGAN=rfu.ID AND rfu.JENIS=15
			     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
			WHERE t.`STATUS` !=0 AND t.JENIS=8 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND ppj.RUANGAN LIKE ''',vRUANGAN,'''  AND ru.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
					',IF(CARABAYAR=0,CONCAT(' AND  crbyr.ID NOT IN (1,2)'),CONCAT(' AND  crbyr.ID=',CARABAYAR)),'
				   
			GROUP BY t.TAGIHAN
			UNION
			/*O2*/
		SELECT RAND() QID, t.TAGIHAN, t.REF, t.JENIS, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI, 0 ADMINISTRASI, SUM(trr.TARIF * rt.JUMLAH) SARANA, 0 BHP
				, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA, 0 PENATA_ANASTESI 
				, 0 PARAMEDIS, 0 NON_MEDIS, SUM(trr.TARIF * rt.JUMLAH) TARIF
				, p.NORM NORM
				, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN,  DATE(t.TANGGAL) TGLBAYAR
				, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN
				, r.DESKRIPSI RUANGAN, crbyr.DESKRIPSI CARABAYAR, pp.TANGGAL TGLREG, t.TOTAL TOTALTAGIHAN
			
		FROM pembayaran.pembayaran_tagihan t
		     LEFT JOIN master.referensi jb ON t.JENIS=jb.ID AND jb.JENIS=50
			  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON t.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
			  LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR AND pp.`STATUS` IN (1,2)
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
			  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			  , pembayaran.rincian_tagihan rt 
			   LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
		  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
		  		 LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
		  		
			 ,  master.tarif_o2 trr
		WHERE t.`STATUS` !=0 AND t.JENIS=1 AND rt.STATUS!=0 AND t.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
				     ',IF(CARABAYAR=0,CONCAT(' AND pj.JENIS NOT IN (1,2)'),CONCAT(' AND pj.JENIS=',CARABAYAR)),'  AND t.TAGIHAN=rt.TAGIHAN AND rt.TARIF_ID=trr.ID AND rt.JENIS=6
		GROUP BY t.TAGIHAN
	) ab
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
		FROM aplikasi.instansi ai
			, master.ppk p
		WHERE ai.PPK=p.ID) INST
	GROUP BY ab.TAGIHAN
			
	');

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPenggunaanO2
DROP PROCEDURE IF EXISTS `LaporanPenggunaanO2`;
DELIMITER //
CREATE PROCEDURE `LaporanPenggunaanO2`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
  
  SET @sqlText = CONCAT('
      SELECT inst.PPK, inst.NAMAINST NAMAINST, inst.ALAMATINST ALAMATINST,master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLDAFTAR,pp.NOMOR NOPEN, pp.NORM, master.getNamaLengkap(pp.NORM) NAMAPASIEN
		, IF(mr.JENIS_KUNJUNGAN=3,CONCAT(mr.DESKRIPSI,''-'',rk.KAMAR,''-'',kls.DESKRIPSI,''-'',rkt.TEMPAT_TIDUR),mr.DESKRIPSI) LAYANAN, rkt.TEMPAT_TIDUR, rk.KAMAR, kls.DESKRIPSI KELAS
		, ox.FLOW, DATE_FORMAT(ox.PASANG,''%d-%m-%Y %H:%i:%s'') PASANG, IF(ox.LEPAS IS NULL,DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s''), DATE_FORMAT(ox.LEPAS,''%d-%m-%Y %H:%i:%s'')) LEPAS
		, IF(ox.PEMAKAIAN IS NULL,TIME_TO_SEC(TIMEDIFF(SYSDATE(),ox.PASANG))/60,ox.PEMAKAIAN) PEMAKAIAN, IF(jns.DESKRIPSI IS NULL,''Jenis Belum ditentukan'',jns.DESKRIPSI) JENIS
		, IF(ox.PEMAKAIAN IS NULL,(TIME_TO_SEC(TIMEDIFF(SYSDATE(),ox.PASANG))/60) * 
		  IF(rt.TARIF IS NULL,(SELECT master.tarif_o2.TARIF FROM master.tarif_o2 WHERE master.tarif_o2.STATUS=1 ORDER BY master.tarif_o2.TANGGAL DESC LIMIT 1), rt.TARIF),ox.PEMAKAIAN * 
		  IF(rt.TARIF IS NULL,(SELECT master.tarif_o2.TARIF FROM master.tarif_o2 WHERE master.tarif_o2.STATUS=1 ORDER BY master.tarif_o2.TANGGAL DESC LIMIT 1), rt.TARIF)) TAGIHANO2
		, ox.TANGGAL, tp.RUANGAN, ox.STATUS, IF(ox.LEPAS IS NULL, ''Tanggal Lepas belum ada, menampilkan waktu saat ini'',''Tanggal Lepas sudah ada'') KETERANGAN
		, IF(rt.TARIF IS NULL,(SELECT master.tarif_o2.TARIF FROM master.tarif_o2 WHERE master.tarif_o2.STATUS=1 ORDER BY master.tarif_o2.TANGGAL DESC LIMIT 1), rt.TARIF) TARIF
      FROM
	      layanan.o2 ox
	      INNER JOIN pendaftaran.kunjungan pk ON ox.KUNJUNGAN = pk.NOMOR
	      INNER JOIN master.ruangan mr ON pk.RUANGAN = mr.ID
	      LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR = rkt.ID
	      LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
	      LEFT JOIN master.referensi kls ON rk.KELAS=kls.ID AND kls.JENIS=19
	      INNER JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
	      LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR = tp.NOPEN
	      LEFT JOIN pendaftaran.penjamin pjm ON pp.NOMOR=pjm.NOPEN
	      LEFT JOIN pembayaran.rincian_tagihan rt ON rt.REF_ID=ox.KUNJUNGAN AND rt.JENIS=6
	      LEFT JOIN master.referensi jns ON ox.JENIS=jns.ID AND jns.JENIS=220
		,  (SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
                  FROM aplikasi.instansi ai
                    , master.ppk p
                  WHERE ai.PPK=p.ID) inst
      WHERE ox.STATUS !=0 AND pk.`STATUS` !=0
		AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
 #     ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''  AND mr.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
      ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''')),'
      ',IF(CARABAYAR=0,'',CONCAT(' AND pjm.JENIS=',CARABAYAR)),'
      ORDER BY pp.TANGGAL, pk.RUANGAN, pp.NORM, ox.PASANG
      ');
      
PREPARE stmt FROM @sqlText;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPengunjungBelumCoding
DROP PROCEDURE IF EXISTS `LaporanPengunjungBelumCoding`;
DELIMITER //
CREATE PROCEDURE `LaporanPengunjungBelumCoding`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT ''LAPORAN PASIEN BELUM GROUPING'' JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, DATE_FORMAT(TIMEDIFF(tk.MASUK,pd.TANGGAL),''%H:%i:%s'') SELISIH
				, DATE_FORMAT(TIMEDIFF(tk.KELUAR,tk.MASUK),''%H:%i:%s'') WKTPELAYANAN
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLORDER
				, DATE_FORMAT(TIMEDIFF(kf.MASUK,orr.TANGGAL),''%H:%i:%s'') TERIMARESEP
				, DATE_FORMAT(TIMEDIFF(kf.KELUAR,kf.MASUK),''%H:%i:%s'') OBATSIAP
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
				, INST.NAMAINST, INST.ALAMATINST
				, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getNopenIRD(pd.NORM, pd.NOMOR), master.getNopenIRNA(pd.NORM, pd.NOMOR)) NOPENRDRI
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getSepIRD(pd.NORM, pd.NOMOR), master.getSepIRNA(pd.NORM, pd.NOMOR)) SEPRDRI
				, jkr.JENIS_KUNJUNGAN JNSK
				, kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , IF(jkr.JENIS_KUNJUNGAN=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pd.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jkr.JENIS_KUNJUNGAN=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LOS
				, IF(jkr.JENIS_KUNJUNGAN=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pd.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
				  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		        LEFT JOIN inacbg.hasil_grouping cbg ON pd.NOMOR=cbg.NOPEN
			  	  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
			  	  LEFT JOIN layanan.pasien_pulang lpp ON pd.NOMOR=lpp.NOPEN AND lpp.STATUS=1
			  	  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			  	  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pd.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
			  	  LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk			
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND cbg.`STATUS` IS NULL AND (lpp.STATUS=1 OR tk.STATUS IN (1,2))
					AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					ORDER BY UNITPELAYANAN, pd.TANGGAL					
					');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPengunjungBelumGrouping
DROP PROCEDURE IF EXISTS `LaporanPengunjungBelumGrouping`;
DELIMITER //
CREATE PROCEDURE `LaporanPengunjungBelumGrouping`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT ''LAPORAN PASIEN BELUM GROUPING'' JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, DATE_FORMAT(TIMEDIFF(tk.MASUK,pd.TANGGAL),''%H:%i:%s'') SELISIH
				, DATE_FORMAT(TIMEDIFF(tk.KELUAR,tk.MASUK),''%H:%i:%s'') WKTPELAYANAN
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLORDER
				, DATE_FORMAT(TIMEDIFF(kf.MASUK,orr.TANGGAL),''%H:%i:%s'') TERIMARESEP
				, DATE_FORMAT(TIMEDIFF(kf.KELUAR,kf.MASUK),''%H:%i:%s'') OBATSIAP
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
				, INST.NAMAINST, INST.ALAMATINST
				, master.getNamaLengkapPegawai(mp.NIP) PENGGUNA
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getNopenIRD(pd.NORM, pd.NOMOR), master.getNopenIRNA(pd.NORM, pd.NOMOR)) NOPENRDRI
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getSepIRD(pd.NORM, pd.NOMOR), master.getSepIRNA(pd.NORM, pd.NOMOR)) SEPRDRI
				, jkr.JENIS_KUNJUNGAN JNSK
				, kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , IF(jkr.JENIS_KUNJUNGAN=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pd.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jkr.JENIS_KUNJUNGAN=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LOS
				, IF(jkr.JENIS_KUNJUNGAN=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pd.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
				  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		        LEFT JOIN inacbg.hasil_grouping cbg ON pd.NOMOR=cbg.NOPEN
			  	  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
			  	  LEFT JOIN layanan.pasien_pulang lpp ON pd.NOMOR=lpp.NOPEN AND lpp.STATUS=1
			  	  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			  	  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pd.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
			  	  LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk			
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND cbg.`STATUS` IS NULL AND (lpp.STATUS=1 OR tk.STATUS IN (1,2))
					AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					ORDER BY UNITPELAYANAN, pd.TANGGAL					
					');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPengunjungPerpasien
DROP PROCEDURE IF EXISTS `LaporanPengunjungPerpasien`;
DELIMITER //
CREATE PROCEDURE `LaporanPengunjungPerpasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT CONCAT(IF(jk.ID=1,''Laporan Pengunjung '', IF(jk.ID=2,''Laporan Kunjungan '',IF(jk.ID=3,''Laporan Pasien Masuk '',''''))), CONCAT(jk.DESKRIPSI,'' Per Pasien'')) JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, TIMEDIFF(tk.MASUK,pd.TANGGAL) SELISIH
				, TIMEDIFF(tk.KELUAR,tk.MASUK) WKTPELAYANAN
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLORDER
				, TIMEDIFF(kf.MASUK,orr.TANGGAL) TERIMARESEP
				, TIMEDIFF(kf.KELUAR,kf.MASUK) OBATSIAP
				, ref.DESKRIPSI CARABAYAR
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU, ppk.NAMA RUJUKAN, r.DESKRIPSI UNITPELAYANAN, srp.DOKTER
				, INST.NAMAINST, INST.ALAMATINST
				, IF(mp.NIP IS NULL, ''ANJUNGAN PENDAFTARAN MANDIRI'', master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getNopenIRD(pd.NORM, pd.NOMOR), master.getNopenIRNA(pd.NORM, pd.NOMOR)) NOPENRDRI
				, IF(jkr.JENIS_KUNJUNGAN=3,master.getSepIRD(pd.NORM, pd.NOMOR), master.getSepIRNA(pd.NORM, pd.NOMOR)) SEPRDRI
				, jkr.JENIS_KUNJUNGAN JNSK
				, kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG, IF(master.getDiagnosaPasien(pd.NOMOR) IS NULL,''Belum Koding'',master.getDiagnosaPasien(pd.NOMOR)) ICD10, master.getProsedurePasien(pd.NOMOR) ICD9
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , IF(jkr.JENIS_KUNJUNGAN=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pd.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jkr.JENIS_KUNJUNGAN=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pd.TANGGAL)) LOS
				, IF(jkr.JENIS_KUNJUNGAN=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pd.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON pd.RUJUKAN=srp.ID AND srp.`STATUS`!=0
				  LEFT JOIN master.ppk ppk ON srp.PPK=ppk.ID
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		        LEFT JOIN inacbg.hasil_grouping cbg ON pd.NOMOR=cbg.NOPEN
			  	  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
			  	  LEFT JOIN layanan.pasien_pulang lpp ON pd.NOMOR=lpp.NOPEN AND lpp.STATUS=1
			  	  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			  	  LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pd.NOMOR=ptp.PENDAFTARAN AND ptp.UTAMA=1 AND ptp.STATUS=1
			  	  LEFT JOIN pembayaran.tagihan t on ptp.TAGIHAN=t.ID
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND jkr.JENIS_KUNJUNGAN=',LAPORAN,' AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					ORDER BY UNITPELAYANAN, pd.TANGGAL					
					');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanPenjadwalanOperasi
DROP PROCEDURE IF EXISTS `LaporanPenjadwalanOperasi`;
DELIMITER //
CREATE PROCEDURE `LaporanPenjadwalanOperasi`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);      
   SET vRUANGAN = CONCAT(RUANGAN,'%');	
	SET @sqlText = CONCAT('
	
	SELECT INST.*, ab.NORM, pdf.NOMOR NOPEN, master.getNamaLengkap(ab.NORM) NAMAPASIEN, ref.DESKRIPSI CARABAYAR, ab.RUANG_MENJADWAL, ab.TANGGAL_JADWAL, ab.JAM_JADWAL, ab.INPUTJADWAL
		, ab.JADWAL_RUANG_OPERASI
      , mr.DESKRIPSI RUANG_OPERASI
		, pkk.NOMOR KUNJUNGAN
		, pkk.MASUK TANGGAL_KUNJUNGAN, t.NAMA NAMA_TINDAKAN
		, op.TANGGAL TANGGAL_OPERASI, op.WAKTU_MULAI, op.WAKTU_SELESAI
		, TIMEDIFF(CONCAT(op.TANGGAL,'' '',op.WAKTU_MULAI),CONCAT(ab.TANGGAL_JADWAL,'' '',ab.JAM_JADWAL)) WAKTU_TUNGGU
		, TIMEDIFF(pkk.MASUK,ab.JADWAL_RUANG_OPERASI) PENUNDAAN_OPERASI
		, TIME_TO_SEC(TIMEDIFF(CONCAT(op.TANGGAL,'' '',op.WAKTU_MULAI),CONCAT(ab.TANGGAL_JADWAL,'' '',ab.JAM_JADWAL)))/60 WAKTU_TUNGGU_MENIT
		, IF(ab.KEGIATAN IS NULL,''BELUM DILAKUKAN'',IF(ab.KEGIATAN=1,''SIGN IN'',IF(ab.KEGIATAN=2,''SIGN OUT'',''TIME OUT''))) KEGIATAN
		, ab.JAMKEGIATAN, ab.KAMAR
	FROM (
			SELECT rjo.KODE, rjo.TANGGAL TANGGAL_JADWAL, rjo.JAM JAM_JADWAL, rjo.RUANGAN, rjo.TIMESTAMP INPUTJADWAL,CONCAT(jo.TANGGAL,'' '',jo.MULAI) JADWAL_RUANG_OPERASI, rok.DESKRIPSI RUANG_MENJADWAL, pp.NORM
			, jod.KEGIATAN, jod.JAM JAMKEGIATAN, kok.KAMAR 
					, @jdwl:=(SELECT rjo2.TANGGAL
						FROM pendaftaran.kunjungan pk2
							, jadwal_operasi.request_jadwal_operasi rjo2
							, pendaftaran.pendaftaran pp2
						WHERE pk2.NOMOR=rjo2.KUNJUNGAN AND pk2.NOPEN=pp2.NOMOR AND pp2.NORM=pp.NORM AND rjo2.TANGGAL > rjo.TANGGAL ORDER BY rjo2.TANGGAL ASC LIMIT 1) JADWAL_SETELAHNYA
					, (SELECT pk1.NOMOR
							FROM pendaftaran.pendaftaran pp1
								, pendaftaran.kunjungan pk1
								, master.ruangan rg1
							WHERE pp1.NOMOR=pk1.NOPEN AND pp1.NORM=pp.NORM AND pk1.RUANGAN=rg1.ID AND rg1.JENIS_KUNJUNGAN=6 AND pk1.MASUK >= rjo.TANGGAL 
									AND (@jdwl IS NOT NULL AND pk1.MASUK > @jdwl IS FALSE OR @jdwl IS NULL)
							ORDER BY pk1.MASUK ASC LIMIT 1) NOMOR_KUNJUNGAN					
				FROM jadwal_operasi.request_jadwal_operasi rjo
				      LEFT JOIN jadwal_operasi.jadwal_operasi jo ON rjo.KODE=jo.KODE AND jo.`STATUS`!=0
				      LEFT JOIN master.ruang_kamar kok ON kok.ID=jo.KAMAR
				      LEFT JOIN jadwal_operasi.jadwal_operasi_detail jod ON jo.ID=jod.JADWAL AND jod.`STATUS`!=0
				      LEFT JOIN master.ruangan ro ON rjo.RUANGAN=ro.ID
				      LEFT JOIN pendaftaran.kunjungan pk ON rjo.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
				      LEFT JOIN master.ruangan rok ON pk.RUANGAN=rok.ID
				      LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
				WHERE rjo.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''AND rjo.STATUS!=0 
			) ab
			LEFT JOIN pendaftaran.kunjungan pkk ON ab.NOMOR_KUNJUNGAN=pkk.NOMOR AND pkk.`STATUS`!=0
			LEFT JOIN layanan.tindakan_medis tm ON ab.NOMOR_KUNJUNGAN=tm.KUNJUNGAN AND tm.`STATUS`!=0
			LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			LEFT JOIN medicalrecord.operasi op ON tm.KUNJUNGAN=op.KUNJUNGAN AND op.`STATUS`!=0
			LEFT JOIN pendaftaran.pendaftaran pdf ON pkk.NOPEN=pdf.NOMOR AND pdf.`STATUS`!=0
			LEFT JOIN master.ruangan mr ON pkk.RUANGAN=mr.ID
			LEFT JOIN pendaftaran.penjamin pj ON pdf.NOMOR=pj.NOPEN
			LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pkk.NOPEN=pdf.NOMOR AND tm.KUNJUNGAN=pkk.NOMOR
		AND pkk.RUANGAN LIKE ''',vRUANGAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
		',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
	ORDER BY tm.TINDAKAN');	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRekapRegistrasiPerUser
DROP PROCEDURE IF EXISTS `LaporanRekapRegistrasiPerUser`;
DELIMITER //
CREATE PROCEDURE `LaporanRekapRegistrasiPerUser`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT OLEH, PENGGUNA, SUM(RJ) RJ, SUM(RD) RD, SUM(RI) RI, SUM(KRM) KRM
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		, INST.NAMAINST, INST.ALAMATINST
	FROM (
			SELECT RAND() IDX, pd.NOMOR, pd.NORM, pd.TANGGAL, r.DESKRIPSI, pd.OLEH,  IFNULL(master.getNamaLengkapPegawai(mp.NIP), us.LOGIN) PENGGUNA
						, IF(r.JENIS_KUNJUNGAN=1,1,0) RJ
						, IF(r.JENIS_KUNJUNGAN=2,1,0) RD
						, IF(r.JENIS_KUNJUNGAN=3,1,0) RI
						, 0 KRM
					FROM master.pasien p
						  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
						, pendaftaran.pendaftaran pd
						  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID 
				  		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
					   , pendaftaran.tujuan_pasien tp
						, pendaftaran.kunjungan tk
						, master.ruangan r  
						
					WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
							AND tk.RUANGAN=r.ID AND r.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					 		AND tp.RUANGAN LIKE ''',vRUANGAN,'''
						  ',IF(LAPORAN=0,CONCAT(' AND r.JENIS_KUNJUNGAN IN (1,2,3)'),CONCAT(' AND r.JENIS_KUNJUNGAN=',LAPORAN)),'
							',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					UNION ALL
					SELECT RAND() IDX,  pd.NOMOR, pd.NORM, pd.TANGGAL, r.DESKRIPSI, pd.OLEH,  IFNULL(master.getNamaLengkapPegawai(mp.NIP), us.LOGIN) PENGGUNA
						, 0 RJ
						, 0 RD
						, 0 RI
						, IF(r.JENIS_KUNJUNGAN IN (1,2,3),1,0) KRM
					FROM master.pasien p
						  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
						, pendaftaran.pendaftaran pd
						, pendaftaran.tujuan_pasien tp
						, pendaftaran.kunjungan tk
						, master.ruangan r  
						, berkas_rekammedis.berkas_keluar bk
						  LEFT JOIN aplikasi.pengguna us ON bk.KIRIM_OLEH=us.ID 
				  		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
					WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN AND pd.STATUS IN (1,2) AND tk.REF IS NULL
							AND tk.RUANGAN=r.ID AND r.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					 		AND tp.RUANGAN LIKE ''',vRUANGAN,'''
						  ',IF(LAPORAN=0,CONCAT(' AND r.JENIS_KUNJUNGAN IN (1,2,3)'),CONCAT(' AND r.JENIS_KUNJUNGAN=',LAPORAN)),'
							',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
							AND pd.NOMOR=bk.NOPEN AND bk.`STATUS`!=0
					GROUP BY pd.NOMOR
				) ab
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
						   , master.ppk p
						WHERE ai.PPK=p.ID) INST
	GROUP BY OLEH
	ORDER BY PENGGUNA');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanResponTime
DROP PROCEDURE IF EXISTS `LaporanResponTime`;
DELIMITER //
CREATE PROCEDURE `LaporanResponTime`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN


	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
					SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, ra.DESKRIPSI RUANGAN_AWAL
						, IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, hl.TANGGAL) TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, hl.TANGGAL),k.MASUK) SELISIH2
						, TIMEDIFF(IF(r.DESKRIPSI LIKE ''%Anatomi%'', pa.TANGGAL, hl.TANGGAL),olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
						, IF(olb.CITO=1,''Ya'',''Tidak'') CITO
					FROM pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_lab hl ON tm.ID=hl.TINDAKAN_MEDIS
						  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
						  LEFT JOIN master.dokter drh ON chl.DOKTER=drh.ID
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						  LEFT JOIN layanan.hasil_pa pa ON k.NOMOR=pa.KUNJUNGAN AND pa.`STATUS`!=0
						  LEFT JOIN layanan.order_lab olb ON olb.NOMOR=k.REF AND olb.`STATUS`!=0
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE k.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND k.RUANGAN=r.ID AND k.`STATUS`!=0 
					 
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				GROUP BY olb.NOMOR
				UNION
				SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA
						, ra.DESKRIPSI RUANGAN_AWAL, hl.TANGGAL TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(hl.TANGGAL,k.MASUK) SELISIH2
						, TIMEDIFF(hl.TANGGAL,olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
						, IF(olb.CITO=1,''Ya'',''Tidak'') CITO
					FROM pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN layanan.hasil_rad hl ON tm.ID=hl.TINDAKAN_MEDIS AND hl.`STATUS`=2
						  LEFT JOIN master.dokter drh ON hl.DOKTER=drh.ID
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM  
						  LEFT JOIN layanan.order_rad olb ON olb.NOMOR=k.REF AND olb.`STATUS`!=0
					     LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE k.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND k.RUANGAN=r.ID AND k.`STATUS`!=0 
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				  GROUP BY olb.NOMOR
		');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanResponTimeIGD
DROP PROCEDURE IF EXISTS `LaporanResponTimeIGD`;
DELIMITER //
CREATE PROCEDURE `LaporanResponTimeIGD`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
			SELECT ab.*
					, TIMEDIFF(TGL_REG_IRNA,TGL_REG_TRIASE) SELISIH1
					, TIMEDIFF(TGL_TERIMA_RUANGAN,TGL_REG_IRNA) SELISIH2
					, TIMEDIFF(TGL_MUTASI,TGL_REG_IRNA) SELISIH3
					, TIMEDIFF(TGL_TERIMA_RUANGAN,TGL_REG_TRIASE) SELISIH4
					, TIMEDIFF(TGL_MUTASI,TGL_REG_TRIASE) SELISIH5
					, TIMEDIFF(TGL_KELUAR_IRD,TGL_REG_TRIASE) SELISIH6
					, TIME_FORMAT(TIMEDIFF(TINDAKAN_AWAL_IGD,TGL_REG_TRIASE),''%H:%i:%s'') SELISIH7
					, ''Laporan Respon Time'' JENISLAPORAN
					, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
					, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
					, INST.NAMAINST, INST.ALAMATINST
					
				FROM (
						SELECT cd.NORM, NAMALENGKAP, NOPEN_IRD, NOPEN_IRNA, TGL_REG_TRIASE, ID_RUANGAN_TRIASE, RUANGAN_TRIASE, pir.TANGGAL TGL_REG_IRNA, ri.DESKRIPSI RUANGAN_IRNA
							, (SELECT k.MASUK FROM pendaftaran.kunjungan k WHERE k.NOPEN=NOPEN_IRNA AND k.REF IS NULL AND k.`STATUS`!=0 LIMIT 1) TGL_TERIMA_RUANGAN
							, (SELECT m.MASUK FROM pendaftaran.kunjungan m WHERE m.NOPEN=NOPEN_IRNA  AND m.RUANG_KAMAR_TIDUR!=0 AND  m.REF IS NOT NULL AND m.`STATUS`!=0 ORDER BY MASUK ASC LIMIT 1) TGL_MUTASI
					 	   , (SELECT mg.DESKRIPSI FROM pendaftaran.kunjungan m, `master`.ruangan mg WHERE m.NOPEN=NOPEN_IRNA AND m.RUANGAN=mg.ID AND m.RUANG_KAMAR_TIDUR!=0 AND  m.REF IS NOT NULL AND m.`STATUS`!=0 ORDER BY MASUK ASC LIMIT 1) RUANGAN_MUTASI
							, (SELECT k.KELUAR FROM pendaftaran.kunjungan k, `master`.ruangan rg WHERE k.RUANGAN=rg.ID AND rg.JENIS_KUNJUNGAN=2 AND k.NOPEN=NOPEN_IRD AND k.`STATUS`!=0 LIMIT 1) TGL_KELUAR_IRD
							, master.getTglTindakanAwal((SELECT k.NOMOR FROM pendaftaran.kunjungan k, `master`.ruangan rg WHERE k.RUANGAN=rg.ID AND rg.JENIS_KUNJUNGAN=2 AND k.NOPEN=NOPEN_IRD AND k.`STATUS`!=0 LIMIT 1)) TINDAKAN_AWAL_IGD
						FROM (
								SELECT LPAD(pd.NORM,8,''0'') NORM, CONCAT(master.getNamaLengkap(pd.NORM)) NAMALENGKAP, pd.NOMOR NOPEN_IRD
									,  `master`.getNopenIRNA(pd.NORM, pd.TANGGAL) NOPEN_IRNA
									, pd.tanggal TGL_REG_TRIASE
									, r.DESKRIPSI RUANGAN_TRIASE
									, r.ID ID_RUANGAN_TRIASE
								FROM pendaftaran.pendaftaran pd
										, pendaftaran.tujuan_pasien tp
										, `master`.ruangan r
									WHERE pd.NOMOR=tp.NOPEN AND pd.`STATUS`!=0 AND tp.`STATUS`!=0
									  AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=2
									 AND pd.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
									 AND tp.RUANGAN LIKE ''',vRUANGAN,'''
									) cd
									LEFT JOIN pendaftaran.pendaftaran pir ON cd.NOPEN_IRNA=pir.NOMOR AND pir.`STATUS`!=0
									LEFT JOIN pendaftaran.tujuan_pasien tir ON pir.NOMOR=tir.NOPEN AND tir.`STATUS`!=0
									LEFT JOIN `master`.ruangan ri ON tir.RUANGAN=ri.ID
			
				
				 ) ab
				 , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
					');
					

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanResponTimeLabPA
DROP PROCEDURE IF EXISTS `LaporanResponTimeLabPA`;
DELIMITER //
CREATE PROCEDURE `LaporanResponTimeLabPA`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN


	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
					SELECT RAND() IDX, olb.NOMOR, olb.KUNJUNGAN, olb.TANGGAL TGL_ORDER, r.DESKRIPSI RUANGAN, k.MASUK TGL_TERIMA, IFNULL(ra.DESKRIPSI,''Langsung ke Loket'') RUANGAN_AWAL
						, pa.TANGGAL TGL_HASIL, t.NAMA NAMATINDAKAN
						, TIMEDIFF(k.MASUK,olb.TANGGAL) SELISIH1
						, TIMEDIFF(pa.TANGGAL,k.MASUK) SELISIH2
						, TIMEDIFF(pa.TANGGAL,olb.TANGGAL) SELISIH3
						, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
						, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
						, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(dok.NIP)) DOKTERHEADER
						, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
						, INST.NAMAINST, INST.ALAMATINST
						, p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
						, p.TANGGAL_LAHIR TGL_LAHIR
						, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
						, ref.DESKRIPSI CARABAYAR
						, master.getNamaLengkapPegawai(drh.NIP) DOKTER, tm.ID
						, pa.NOMOR_PA
						, pa.LOKASI
						, pa.DIAGNOSA_KLINIK
						, pa.KESIMPULAN
					
						, (SELECT CONCAT(DATEDIFF(pa.TANGGAL,k.MASUK) - (
								(SELECT COUNT(*)
								FROM `master`.tanggal tgl WHERE tgl.TANGGAL BETWEEN k.MASUK AND pa.TANGGAL AND tgl.NAMAHARI IN (''Saturday'',''Sunday'')) +
								(SELECT COUNT(*) FROM pegawai.libur_nasional lns WHERE lns.TANGGAL_LIBUR BETWEEN k.MASUK AND pa.TANGGAL AND lns.`STATUS`=1)
								) ,'' hari \r * libur: '',
								((SELECT COUNT(*)
								FROM `master`.tanggal tgl WHERE tgl.TANGGAL BETWEEN k.MASUK AND pa.TANGGAL AND tgl.NAMAHARI IN (''Saturday'',''Sunday'')) +
								(SELECT COUNT(*) FROM pegawai.libur_nasional lns WHERE lns.TANGGAL_LIBUR BETWEEN k.MASUK AND pa.TANGGAL AND lns.`STATUS`=1)),'' hari'')) LAMA_PELAYANAN
						, IF(pa.JENIS_PEMERIKSAAN=1,''Histopatologi'',	IF(pa.JENIS_PEMERIKSAAN=2,	''Sitologi'', IF(pa.JENIS_PEMERIKSAAN=3, ''IHC'',''''))) KET
					FROM pendaftaran.kunjungan k
						  LEFT JOIN layanan.tindakan_medis tm ON k.NOMOR=tm.KUNJUNGAN AND tm.`STATUS`!=0
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN pendaftaran.pendaftaran pp ON k.NOPEN=pp.NOMOR AND pp.`STATUS`!=0
						  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
						  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10 
						  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						  LEFT JOIN layanan.hasil_pa pa ON k.NOMOR=pa.KUNJUNGAN AND pa.`STATUS`!=0
						  LEFT JOIN master.dokter drh ON pa.DOKTER =drh.ID
						  LEFT JOIN layanan.order_lab olb ON olb.NOMOR=k.REF AND olb.`STATUS`!=0
						  LEFT JOIN pendaftaran.kunjungan a ON olb.KUNJUNGAN=a.NOMOR AND a.`STATUS`!=0
					     LEFT JOIN master.ruangan ra ON a.RUANGAN=ra.ID
						, master.ruangan r
						, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
										FROM aplikasi.instansi ai
											, master.ppk p
										WHERE ai.PPK=p.ID) INST
					WHERE k.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
					  AND k.RUANGAN=r.ID AND k.`STATUS`!=0 
					 
					  AND k.RUANGAN LIKE ''',vRUANGAN,'''
					 ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
						',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
				GROUP BY k.NOMOR
				
		');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanRL31PerUnit
DROP PROCEDURE IF EXISTS `LaporanRL31PerUnit`;
DELIMITER //
CREATE PROCEDURE `LaporanRL31PerUnit`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN	

	 DECLARE vTGLAWAL DATE;
	 DECLARE vTGLAKHIR DATE;
	 DECLARE vRUANGAN VARCHAR(11);
	 

	 SET vRUANGAN = CONCAT(RUANGAN,'%');     
	 SET vTGLAWAL = DATE(TGLAWAL);
	 SET vTGLAKHIR = DATE(TGLAKHIR);
	
	SET @sqlText = CONCAT('
		SELECT INST.*
			   , IF(''',RUANGAN,'''='''' OR LENGTH(''',RUANGAN,''')<5	
					, IF(mr.JENIS=2, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
					, IF(mr.JENIS=3, CONCAT(SPACE(mr.JENIS*2), mr.DESKRIPSI)
					, IF(mr.JENIS=4, CONCAT(SPACE(mr.JENIS*3), mr.DESKRIPSI)
					, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*4), mr.DESKRIPSI)
					, mr.DESKRIPSI))))
				, IF(LENGTH(''',RUANGAN,''')<7
					, IF(mr.JENIS=4, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
					, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*2), mr.DESKRIPSI)
					, mr.DESKRIPSI))
				, IF(LENGTH(''',RUANGAN,''')<9
					, IF(mr.JENIS=5, CONCAT(SPACE(mr.JENIS*1), mr.DESKRIPSI)
					, mr.DESKRIPSI)
				, mr.DESKRIPSI))) RUANGAN
			   , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		      , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER 
	         , mr.ID, DESKRIPSI
				, SUM(AWAL) AWAL, SUM(AWALLK) AWALLK, SUM(AWALPR) AWALPR
				, SUM(MASUK) MASUK, SUM(MASUKLK) MASUKLK, SUM(MASUKPR) MASUKPR
				, SUM(PINDAHAN) PINDAHAN, SUM(PINDAHANLK) PINDAHANLK, SUM(PINDAHANPR) PINDAHANPR
				, SUM(DIPINDAHKAN) DIPINDAHKAN, SUM(DIPINDAHKANLK) DIPINDAHKANLK, SUM(DIPINDAHKANPR) DIPINDAHKANPR
				, SUM(HIDUP) HIDUP, SUM(HIDUPLK) HIDUPLK, SUM(HIDUPPR) HIDUPPR
				, SUM(MATI) MATI, SUM(MATILK) MATILK, SUM(MATIPR) MATIPR
				, SUM(MATIKURANG48) MATIKURANG48, SUM(MATIKURANG48LK) MATIKURANG48LK, SUM(MATIKURANG48PR) MATIKURANG48PR
				, SUM(MATILEBIH48) MATILEBIH48, SUM(MATILEBIH48LK) MATILEBIH48LK, SUM(MATILEBIH48PR) MATILEBIH48PR
				, SUM(LD) LD, SUM(LDLK) LDLK, SUM(LDPR) LDPR
				, SUM(SISA) SISA, SUM(SISALK) SISALK, SUM(SISAPR) SISAPR
				, SUM(HP) HP, SUM(HPLK) HPLK, SUM(HPPR) HPPR
				, SUM(VVIP) VVIP, SUM(VVIPLK) VVIPLK, SUM(VVIPPR) VVIPPR
				, SUM(VIP) VIP, SUM(VIPLK) VIPLK, SUM(VIPPR) VIPPR
				, SUM(KLSI) KLSI, SUM(KLSILK) KLSILK, SUM(KLSIPR) KLSIPR
				, SUM(KLSII) KLSII, SUM(KLSIILK) KLSIILK, SUM(KLSIIPR) KLSIIPR
				, SUM(KLSIII) KLSIII, SUM(KLSIIILK) KLSIIILK, SUM(KLSIIIPR) KLSIIIPR
				, SUM(KLSKHUSUS) KLSKHUSUS, SUM(KLSKHUSUSLK) KLSKHUSUSLK, SUM(KLSKHUSUSPR) KLSKHUSUSPR
		      , SUM(JUMLAHTT) JMLTT
		   	, IF(SUM(HP)=0 OR SUM(JUMLAHTT)=0,0,ROUND((SUM(HP) * 100) / (SUM(JUMLAHTT) * (DATEDIFF(''',TGLAKHIR,''',''',TGLAWAL,''')+1)),2)) BOR
				, ROUND(SUM(LD)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48),2) AVLOS
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0 OR SUM(JUMLAHTT)=0,0, ROUND(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48) / (SUM(JUMLAHTT)),2)) BTO
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 ,ROUND(((SUM(JUMLAHTT) * (DATEDIFF(''',TGLAKHIR,''',''',TGLAWAL,''')+1)) - SUM(HP)) / (SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)),2)) TOI
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 , (SUM(MATILEBIH48)*1000)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)) NDR
				, IF(SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)=0, 0 , (SUM(MATI)*1000)/SUM(DIPINDAHKAN+HIDUP+MATIKURANG48+MATILEBIH48)) GDR
		FROM master.ruangan mr
			  LEFT JOIN (
			  				SELECT RAND() IDX, pk.RUANGAN
		 					  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) AWAL
		 					  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) AWALLK
		 					  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) AWALPR
						     , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
					  FROM pendaftaran.kunjungan pk
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND DATE(pk.MASUK) < ''',vTGLAWAL,'''
							AND (DATE(pk.KELUAR) >= ''',vTGLAWAL,''' OR pk.KELUAR IS NULL)
							AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, tp.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
						     , SUM(IF(pk.`STATUS` IN (1,2),1,0)) MASUK
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) MASUKLK
						     , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						FROM pendaftaran.pendaftaran pp
							     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
								, pendaftaran.tujuan_pasien tp
								  LEFT JOIN master.rl31_smf rlr ON tp.SMF=rlr.ID
								, master.ruangan r
								, pendaftaran.kunjungan pk
						  WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS` IN (1,2) AND pk.REF IS NULL
						    AND pp.NOMOR=tp.NOPEN AND tp.RUANGAN=pk.RUANGAN AND tp.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
						    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						    AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						    AND INSTR(r.DESKRIPSI,''IRNA'') = 0
				   	GROUP BY tp.RUANGAN
						UNION
						SELECT RAND() IDX, pk.RUANGAN
							  , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR 
							  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) DIPINDAHKAN
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) DIPINDAHKANLK
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						 FROM pendaftaran.mutasi pm
						     , master.ruangan r
							  , pendaftaran.kunjungan pk
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM							    
						 WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`=2 AND pm.TUJUAN !=pk.RUANGAN AND pk.NOPEN=pp.NOMOR
						   AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2)
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						   AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, pk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) PINDAHAN
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) PINDAHANLK
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						 FROM pendaftaran.kunjungan pk
							  , master.ruangan r
							  , pendaftaran.mutasi pm
							  , pendaftaran.kunjungan asal
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.REF IS NOT NULL AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						 	AND pk.REF=pm.NOMOR AND pm.KUNJUNGAN=asal.NOMOR AND pk.RUANGAN !=asal.RUANGAN
						 	AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						 	',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						   AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX,pk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , SUM(IF(pp.CARA NOT IN (6,7),1,0)) HIDUP
							  , SUM(IF(pp.CARA NOT IN (6,7) AND p.JENIS_KELAMIN=1,1,0)) HIDUPLK
							  , SUM(IF(pp.CARA NOT IN (6,7) AND p.JENIS_KELAMIN!=1,1,0)) HIDUPPR
							  , SUM(IF(pp.CARA IN (6,7),1,0)) MATI
							  , SUM(IF(pp.CARA IN (6,7) AND p.JENIS_KELAMIN=1,1,0)) MATILK
							  , SUM(IF(pp.CARA IN (6,7) AND p.JENIS_KELAMIN!=1,1,0)) MATIPR
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48,1,0)) MATIKURANG48
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48 AND p.JENIS_KELAMIN=1,1,0)) MATIKURANG48LK
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) < 48 AND p.JENIS_KELAMIN!=1,1,0)) MATIKURANG48PR
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48,1,0)) MATILEBIH48
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48 AND p.JENIS_KELAMIN=1,1,0)) MATILEBIH48LK
							  , SUM(IF(pp.CARA IN (6,7) AND HOUR(TIMEDIFF(pp.TANGGAL, pd.TANGGAL)) >= 48 AND p.JENIS_KELAMIN!=1,1,0)) MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						FROM layanan.pasien_pulang pp
								, master.ruangan r
								, pendaftaran.kunjungan pk
								, pendaftaran.pendaftaran pd
								  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
								  LEFT JOIN pendaftaran.tujuan_pasien ptp ON pd.NOMOR=ptp.NOPEN
							     LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							     LEFT JOIN master.pasien p ON pd.NORM=p.NORM
						  WHERE pp.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2) AND pp.TANGGAL=pk.KELUAR
						    AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.NOPEN=pd.NOMOR AND pd.`STATUS`!=0
						    AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						    ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						    AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						    AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, pk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , SUM(DATEDIFF(pk.KELUAR, pk.MASUK)) LD
							  , SUM(IF(p.JENIS_KELAMIN=1,DATEDIFF(pk.KELUAR, pk.MASUK),0)) LDLK
							  , SUM(IF(p.JENIS_KELAMIN!=1,DATEDIFF(pk.KELUAR, pk.MASUK),0)) LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						 FROM pendaftaran.kunjungan pk
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						     ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
  						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND pk.KELUAR BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
						   AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, pk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR 
							  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) SISA
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) SISALK
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , 0 JUMLAHTT
						 FROM pendaftaran.kunjungan pk
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND DATE(pk.MASUK) < DATE_ADD(''',vTGLAKHIR,''',INTERVAL 1 DAY)
							AND (DATE(pk.KELUAR) > ''',vTGLAKHIR,''' OR pk.KELUAR IS NULL)
							AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, pk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR  
							  , SUM(IF(pk.`STATUS` IN (1,2),1,0)) HP
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN=1,1,0)) HPLK
							  , SUM(IF(pk.`STATUS` IN (1,2) AND p.JENIS_KELAMIN!=1,1,0)) HPPR
							  , SUM(IF(mapkls.RL_KELAS=1,1,0)) VVIP
							  , SUM(IF(mapkls.RL_KELAS=1 AND p.JENIS_KELAMIN=1,1,0)) VVIPLK
							  , SUM(IF(mapkls.RL_KELAS=1 AND p.JENIS_KELAMIN!=1,1,0)) VVIPPR
							  , SUM(IF(mapkls.RL_KELAS=2,1,0)) VIP
							  , SUM(IF(mapkls.RL_KELAS=2 AND p.JENIS_KELAMIN=1,1,0)) VIPLK
							  , SUM(IF(mapkls.RL_KELAS=2 AND p.JENIS_KELAMIN!=1,1,0)) VIPPR
							  , SUM(IF(mapkls.RL_KELAS=3,1,0)) KLSI
							  , SUM(IF(mapkls.RL_KELAS=3 AND p.JENIS_KELAMIN=1,1,0)) KLSILK
							  , SUM(IF(mapkls.RL_KELAS=3 AND p.JENIS_KELAMIN!=1,1,0)) KLSIPR
							  , SUM(IF(mapkls.RL_KELAS=4,1,0)) KLSII
							  , SUM(IF(mapkls.RL_KELAS=4 AND p.JENIS_KELAMIN=1,1,0)) KLSIILK
							  , SUM(IF(mapkls.RL_KELAS=4 AND p.JENIS_KELAMIN!=1,1,0)) KLSIIPR
							  , SUM(IF(mapkls.RL_KELAS=5,1,0)) KLSIII
							  , SUM(IF(mapkls.RL_KELAS=5 AND p.JENIS_KELAMIN=1,1,0)) KLSIIILK
							  , SUM(IF(mapkls.RL_KELAS=5 AND p.JENIS_KELAMIN!=1,1,0)) KLSIIIPR
							  , SUM(IF(mapkls.RL_KELAS=6,1,0)) KLSKHUSUS
							  , SUM(IF(mapkls.RL_KELAS=6 AND p.JENIS_KELAMIN=1,1,0)) KLSKHUSUSLK
							  , SUM(IF(mapkls.RL_KELAS=6 AND p.JENIS_KELAMIN!=1,1,0)) KLSKHUSUSPR
							  , 0 JUMLAHTT
						 FROM pendaftaran.kunjungan pk
						       LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
							    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
								 LEFT JOIN master.kelas_simrs_rl mapkls ON rk.KELAS=mapkls.KELAS
							  , master.ruangan r
							  , pendaftaran.pendaftaran pp
							    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
							    LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN
							    LEFT JOIN master.rl31_smf rlr ON ptp.SMF=rlr.ID
							    LEFT JOIN master.pasien p ON pp.NORM=p.NORM
							  , (SELECT TANGGAL TGL
									  FROM master.tanggal 
									 WHERE TANGGAL BETWEEN ''',vTGLAWAL,''' AND ''',vTGLAKHIR,''') bts
						 WHERE pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3 AND pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
						   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
						   AND pk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
						   AND DATE(pk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
							AND (DATE(pk.KELUAR) > bts.TGL OR pk.KELUAR IS NULL)
							AND INSTR(r.DESKRIPSI,''IRNA'') = 0
						GROUP BY pk.RUANGAN
						UNION
						SELECT RAND() IDX, rk.RUANGAN
						     , 0 AWAL
						     , 0 AWALLK
						     , 0 AWALPR
							  , 0 MASUK
						     , 0 MASUKLK
						     , 0 MASUKPR
							  , 0 PINDAHAN
							  , 0 PINDAHANLK
							  , 0 PINDAHANPR
							  , 0 DIPINDAHKAN
							  , 0 DIPINDAHKANLK
							  , 0 DIPINDAHKANPR
							  , 0 HIDUP
							  , 0 HIDUPLK
							  , 0 HIDUPPR
							  , 0 MATI
							  , 0 MATILK
							  , 0 MATIPR
							  , 0 MATIKURANG48
							  , 0 MATIKURANG48LK
							  , 0 MATIKURANG48PR
							  , 0 MATILEBIH48
							  , 0 MATILEBIH48LK
							  , 0 MATILEBIH48PR
							  , 0 LD
							  , 0 LDLK
							  , 0 LDPR 
							  , 0 SISA
							  , 0 SISALK
							  , 0 SISAPR
							  , 0 HP
							  , 0 HPLK
							  , 0 HPPR
							  , 0 VVIP
							  , 0 VVIPLK
							  , 0 VVIPPR
							  , 0 VIP
							  , 0 VIPLK
							  , 0 VIPPR
							  , 0 KLSI
							  , 0 KLSILK
							  , 0 KLSIPR
							  , 0 KLSII
							  , 0 KLSIILK
							  , 0 KLSIIPR
							  , 0 KLSIII
							  , 0 KLSIIILK
							  , 0 KLSIIIPR
							  , 0 KLSKHUSUS
							  , 0 KLSKHUSUSLK
							  , 0 KLSKHUSUSPR
							  , COUNT(TEMPAT_TIDUR) JUMLAHTT
					FROM master.ruang_kamar_tidur rkt
					   , master.ruang_kamar rk 
					   , master.ruangan r
					WHERE rkt.`STATUS`!=0 AND rkt.RUANG_KAMAR=rk.ID AND rk.STATUS!=0 
					  AND rk.RUANGAN=r.ID AND rk.RUANGAN LIKE ''',vRUANGAN,''' AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''
					  AND INSTR(r.DESKRIPSI,''IRNA'') = 0
					GROUP BY rk.RUANGAN) b ON b.RUANGAN LIKE CONCAT(mr.ID,''%'')
	, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE mr.ID LIKE ''',vRUANGAN,''' AND mr.JENIS_KUNJUNGAN=3 AND mr.STATUS!=0 AND mr.JENIS_KUNJUNGAN=''',LAPORAN,'''
	 AND INSTR(mr.DESKRIPSI,''IRNA'') = 0
	GROUP BY mr.ID');
			
 
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanVolTindakanGroupTindakan
DROP PROCEDURE IF EXISTS `LaporanVolTindakanGroupTindakan`;
DELIMITER //
CREATE PROCEDURE `LaporanVolTindakanGroupTindakan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
    DECLARE vRUANGAN VARCHAR(11);
    SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT('
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, kjgn.NOPEN,
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
					 ) RUANGAN,
					 t.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
					 SUM(rt.JUMLAH) JUMLAH, rt.TARIF, SUM(rt.JUMLAH * rt.TARIF) TOTALTAGIHAN,rt.`STATUS`,
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.ID IS NULL,0,kls.ID), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.ID IS NULL,0,klsol.ID), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.ID IS NULL,0,klsorad.ID),''''))) IDKLS, 
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.DESKRIPSI IS NULL,''Non Kelas'',kls.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.DESKRIPSI IS NULL,''Non Kelas'',klsol.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.DESKRIPSI IS NULL,''Non Kelas'',klsorad.DESKRIPSI),''''))) KELAS,
					 pj.JENIS IDCARABAYAR, cr.DESKRIPSI CARABAYAR,kgl.ID IDKLP, kgl.DESKRIPSI KLPLAB, ggl.DESKRIPSI GROUPLAB,
					 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
					 IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER,
				    IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER,
				    IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER,
				    INST.NAMAINST, INST.ALAMATINST
				    , SUM(IF(pj.JENIS=1,1,0)) UMUM 
					 , SUM(IF(pj.JENIS=2,1,0)) BPJS 
					 , SUM(IF(pj.JENIS NOT IN (1,2),1,0)) IKS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
			  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
					 LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1 AND ptm.STATUS!=0
					 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					 LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					 /*group dan kelompok lab */
					 LEFT JOIN master.mapping_group_pemeriksaan mgp ON t.ID=mgp.PEMERIKSAAN AND mgp.STATUS = 1
					 LEFT JOIN master.group_pemeriksaan kgl ON mgp.GROUP_PEMERIKSAAN_ID=kgl.ID AND kgl.JENIS=8 AND kgl.STATUS=1
					 LEFT JOIN master.group_pemeriksaan ggl ON ggl.KODE=LEFT(kgl.KODE,2) AND ggl.JENIS=8 AND ggl.STATUS=1
			  		 /*order lab*/
			  		 LEFT JOIN layanan.order_lab ol ON kjgn.REF=ol.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuol ON ol.KUNJUNGAN=kuol.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktol ON rktol.ID = kuol.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkol ON rkol.ID = rktol.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsol ON klsol.JENIS = 19 AND klsol.ID = rkol.KELAS
			  		 /*order rad*/
			  		 LEFT JOIN layanan.order_rad orad ON kjgn.REF=orad.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuorad ON orad.KUNJUNGAN=kuorad.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktorad ON rktorad.ID = kuorad.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkorad ON rk.ID = rktorad.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsorad ON klsorad.JENIS = 19 AND klsorad.ID = rkorad.KELAS
			  		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
							FROM aplikasi.instansi ai
								, master.ppk p
							WHERE ai.PPK=p.ID) INST
			 WHERE rt.`STATUS`!=0 AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''
			   AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			   AND rt.JENIS = 3
			   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
				',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),'
			GROUP BY kjgn.RUANGAN,kgl.ID, tm.TINDAKAN
		');
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanVolTindakanPerpasien
DROP PROCEDURE IF EXISTS `LaporanVolTindakanPerpasien`;
DELIMITER //
CREATE PROCEDURE `LaporanVolTindakanPerpasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN
		, INST.NAMAINST, INST.ALAMATINST
		, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
		, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER
		, master.getNamaLengkapPegawai(mp.NIP) DOKTER, smf.DESKRIPSI SMF, kip.NOMOR NIK
		, mtt.TARIF TARIFTINDAKAN, mtt.DOKTER_OPERATOR JASADOKTER
		, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
		, CONCAT(op.WAKTU_MULAI,'' s.d '',op.WAKTU_SELESAI) WAKTUOPERASI
		, jk.DESKRIPSI JENISKUNJUNGAN, jktp.DESKRIPSI JENISKUNJUNGAN_PENGANTAR
	FROM layanan.tindakan_medis tm
			LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
			LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
			LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dok.ID
			LEFT JOIN master.referensi smf ON ds.SMF=smf.ID AND smf.JENIS=26
			LEFT JOIN medicalrecord.operasi_di_tindakan mot ON tm.ID=mot.TINDAKAN_MEDIS AND mot.`STATUS`!=0
			LEFT JOIN medicalrecord.operasi op ON mot.ID=op.ID AND op.`STATUS`!=0
			LEFT JOIN pegawai.kartu_identitas kip ON kip.NIP=mp.NIP AND kip.JENIS=1
		, pendaftaran.pendaftaran pp
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
			LEFT JOIN master.ruangan rtp ON tp.RUANGAN=rtp.ID AND rtp.JENIS=5
		   LEFT JOIN master.referensi jktp ON rtp.JENIS_KUNJUNGAN=jktp.ID AND jktp.JENIS=15
		, pendaftaran.kunjungan pk 
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.referensi jk ON r.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
		, master.pasien p
		, pembayaran.rincian_tagihan rt
		  LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID AND mtt.STATUS = 1
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR 
		AND tm.ID = rt.REF_ID AND rt.STATUS !=0
		AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		AND pk.RUANGAN LIKE ''',vRUANGAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
		',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
	ORDER BY tm.TINDAKAN');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanVolTindakanRekap
DROP PROCEDURE IF EXISTS `LaporanVolTindakanRekap`;
DELIMITER //
CREATE PROCEDURE `LaporanVolTindakanRekap`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN

	DECLARE vRUANGAN VARCHAR(11);
	      
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT r.DESKRIPSI UNITPELAYANAN
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		  	, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALTINDAKAN
		  	, t.NAMA NAMATINDAKAN, COUNT(tm.TINDAKAN) JUMLAH
		  	, SUM(IF(rtp.JENIS_KUNJUNGAN=3,1,0)) RI
		  	, SUM(IF(rtp.JENIS_KUNJUNGAN=2,1,0)) RD
		  	, SUM(IF(rtp.JENIS_KUNJUNGAN NOT IN (3,2),1,0)) RJ
		  	, SUM(IF(pj.JENIS=1,1,0)) UMUM 
		  	, SUM(IF(pj.JENIS=2,1,0)) BPJS 
		  	, SUM(IF(pj.JENIS NOT IN (1,2),1,0)) IKS
		  	, INST.NAMAINST, INST.ALAMATINST
		  	, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
		  	, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER
		  	, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
		  	, kgl.DESKRIPSI KLP, ggl.DESKRIPSI GRUP
		  	, master.getNamaLengkapPegawai(mp.NIP) DOKTER, smf.DESKRIPSI SMF, kip.NOMOR NIK
			, mtt.TARIF TARIFTINDAKAN, mtt.DOKTER_OPERATOR JASADOKTER
		FROM 
		  	layanan.tindakan_medis tm
		  	LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		  	LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
		  	LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
		  	LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
		  	LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dok.ID
			LEFT JOIN master.referensi smf ON ds.SMF=smf.ID AND smf.JENIS=26
			LEFT JOIN pegawai.kartu_identitas kip ON kip.NIP=mp.NIP AND kip.JENIS=1
		  	LEFT JOIN master.mapping_group_pemeriksaan mgp ON t.ID=mgp.PEMERIKSAAN AND mgp.STATUS = 1
			LEFT JOIN master.group_pemeriksaan kgl ON mgp.GROUP_PEMERIKSAAN_ID=kgl.ID AND kgl.JENIS=8 AND kgl.STATUS=1
			LEFT JOIN master.group_pemeriksaan ggl ON ggl.KODE=LEFT(kgl.KODE,2) AND ggl.JENIS=8 AND ggl.STATUS=1
			, pendaftaran.pendaftaran pp
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk
			LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
			, pendaftaran.tujuan_pasien tp
			LEFT JOIN master.ruangan rtp ON tp.RUANGAN=rtp.ID AND rtp.JENIS=5
			, pembayaran.rincian_tagihan rt
		  LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID AND mtt.STATUS = 1
			, master.pasien p
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
				   	, master.ppk p
				   WHERE ai.PPK=p.ID) INST
		WHERE tm.STATUS IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND tp.NOPEN=pp.NOMOR
			AND tm.ID = rt.REF_ID AND rt.STATUS !=0
			AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			AND pk.RUANGAN LIKE ''',vRUANGAN,'''
			',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
			',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
			',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
		GROUP BY DOKTER, tm.TINDAKAN
		ORDER BY SMF, DOKTER, tm.TINDAKAN
		');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanWaktuTunggu
DROP PROCEDURE IF EXISTS `LaporanWaktuTunggu`;
DELIMITER //
CREATE PROCEDURE `LaporanWaktuTunggu`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT ''LAPORAN WAKTU PELAYANAN'' JENISLAPORAN
				, p.NORM NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, master.getTglTindakanAwal(tk.NOMOR) TGL_TINDAKAN_AWAL
				, master.getTglAsesmenAwal(tk.NOMOR) ASESMEN
				, DATE_FORMAT(TIMEDIFF(tk.MASUK,pd.TANGGAL),''%H:%i:%s'') SELISIH
				, DATE_FORMAT(TIMEDIFF(tk.KELUAR,tk.MASUK),''%H:%i:%s'') WKTPELAYANAN
				, DATE_FORMAT(TIMEDIFF(master.getTglTindakanAwal(tk.NOMOR),tk.MASUK),''%H:%i:%s'') WKTTINDAKAN
				, DATE_FORMAT(TIMEDIFF(master.getTglAsesmenAwal(tk.NOMOR),tk.MASUK),''%H:%i:%s'') ASESMENAWAL
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, IF(SUM(odr.RACIKAN)>0,CONCAT(DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s''),'' (Ada Racikan)''),DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'')) TGLORDER
				, DATE_FORMAT(TIMEDIFF(kf.MASUK,orr.TANGGAL),''%H:%i:%s'') TERIMARESEP
				, DATE_FORMAT(TIMEDIFF(kf.KELUAR,kf.MASUK),''%H:%i:%s'') OBATSIAP
				, IF(kf.KELUAR IS NULL,DATE_FORMAT(TIMEDIFF(tk.KELUAR,pd.TANGGAL),''%H:%i:%s''),DATE_FORMAT(TIMEDIFF(kf.KELUAR,pd.TANGGAL),''%H:%i:%s'')) WPRJ
				, ref.DESKRIPSI CARABAYAR
				, IF(SUM(odr.RACIKAN)>0,''1'',''0'') RACIKAN
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU
				, (SELECT CONCAT(
			        i.DESKRIPSI,''-'', u.DESKRIPSI) INSTALASI
						FROM master.ruangan r
							  LEFT JOIN master.ruangan u ON r.ID LIKE CONCAT(u.ID,''%'') AND u.JENIS=4
							  LEFT JOIN master.ruangan i ON r.ID LIKE CONCAT(i.ID,''%'') AND i.JENIS=3
						WHERE r.ID LIKE tp.RUANGAN AND r.JENIS=5
						LIMIT 1) INSTALASI1
				, r.DESKRIPSI UNITPELAYANAN
				, INST.NAMAINST, INST.ALAMATINST
				, IF(master.getNamaLengkapPegawai(mp.NIP) IS NULL,''Anjungan Mandiri'',master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
        		, master.getTindakanKunjungan(tk.NOMOR) TINDAKAN
        		, master.getTindakanTanpaKonsultasi(tk.NOMOR) TINDAKAN_LAIN
        		, jkr.JENIS_KUNJUNGAN JNSK
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
				  LEFT JOIN layanan.order_detil_resep odr ON orr.NOMOR=odr.ORDER_ID
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN 
					AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND tp.RUANGAN LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					ORDER BY INSTALASI1, UNITPELAYANAN, pd.TANGGAL	
					');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

-- Dumping structure for procedure laporan.LaporanWaktuTungguFarmasi
DROP PROCEDURE IF EXISTS `LaporanWaktuTungguFarmasi`;
DELIMITER //
CREATE PROCEDURE `LaporanWaktuTungguFarmasi`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	
	SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
		SELECT ''LAPORAN WAKTU TUNGGU FARMASI'' JENISLAPORAN
				, LPAD(p.NORM,8,''0'') NORM, CONCAT(master.getNamaLengkap(p.NORM)) NAMALENGKAP
				, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
				, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
				, IF(DATE_FORMAT(p.TANGGAL,''%d-%m-%Y'')=DATE_FORMAT(tk.MASUK,''%d-%m-%Y''),''Baru'',''Lama'') STATUSPENGUNJUNG
				, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG, DATE_FORMAT(tk.MASUK,''%d-%m-%Y %H:%i:%s'') TGLTERIMA
				, DATE_FORMAT(tk.KELUAR,''%d-%m-%Y %H:%i:%s'') TGLKELUAR
				, master.getTglTindakanAwal(tk.NOMOR) TGL_TINDAKAN_AWAL
				, master.getTglAsesmenAwal(tk.NOMOR) ASESMEN
				, TIMEDIFF(tk.MASUK,pd.TANGGAL) SELISIH
				, TIMEDIFF(tk.KELUAR,tk.MASUK) WKTPELAYANAN
				, TIMEDIFF(master.getTglTindakanAwal(tk.NOMOR),tk.MASUK) WKTTINDAKAN
				, TIMEDIFF(master.getTglAsesmenAwal(tk.NOMOR),tk.MASUK) ASESMENAWAL
				, DATE_FORMAT(kf.MASUK,''%d-%m-%Y %H:%i:%s'') MASUKFARMASI
				, DATE_FORMAT(kf.KELUAR,''%d-%m-%Y %H:%i:%s'') KELUARFARMASI
				, IF(SUM(odr.RACIKAN)>0,CONCAT(DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s''),'' (Ada Racikan)''),DATE_FORMAT(orr.TANGGAL,''%d-%m-%Y %H:%i:%s'')) TGLORDER
				, TIMEDIFF(kf.MASUK,orr.TANGGAL) TERIMARESEP
				, TIMEDIFF(kf.KELUAR,kf.MASUK) OBATSIAP
				, TIME_TO_SEC(TIMEDIFF(kf.MASUK,orr.TANGGAL))/60 TERIMARESEPMENIT
				, TIME_TO_SEC(TIMEDIFF(kf.KELUAR,kf.MASUK))/60 OBATSIAPMENIT  
				, IF(kf.KELUAR IS NULL,TIMEDIFF(tk.KELUAR,pd.TANGGAL),TIMEDIFF(kf.KELUAR,pd.TANGGAL)) WPRJ
				, ref.DESKRIPSI CARABAYAR
				, IF(SUM(odr.RACIKAN)>0,''RACIKAN'',''OBAT JADI'') RACIKAN
				, rr.DESKRIPSI DEPOLAYANAN
				, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			   , IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
				, pj.NOMOR NOMORSEP, kap.NOMOR NOMORKARTU
				, (SELECT CONCAT(
			        i.DESKRIPSI,''-'', u.DESKRIPSI) INSTALASI
						FROM master.ruangan r
							  LEFT JOIN master.ruangan u ON r.ID LIKE CONCAT(u.ID,''%'') AND u.JENIS=4
							  LEFT JOIN master.ruangan i ON r.ID LIKE CONCAT(i.ID,''%'') AND i.JENIS=3
						WHERE r.ID LIKE tp.RUANGAN AND r.JENIS=5
						LIMIT 1) INSTALASI1
				, r.DESKRIPSI UNITPELAYANAN
				, INST.NAMAINST, INST.ALAMATINST
				, IF(master.getNamaLengkapPegawai(mp.NIP) IS NULL,''Anjungan Mandiri'',master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA
				, master.getNamaLengkapPegawai(mpf.NIP) USERFARMASI
        		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
        		, master.getTindakanKunjungan(tk.NOMOR) TINDAKAN
        		, master.getTindakanTanpaKonsultasi(tk.NOMOR) TINDAKAN_LAIN
        		, jkr.JENIS_KUNJUNGAN JNSK, asal.DESKRIPSI ASALRESEP
			FROM master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				, pendaftaran.pendaftaran pd
				  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				  LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID AND us.`STATUS`!=0
		        LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP AND mp.`STATUS`!=0
		      , pendaftaran.tujuan_pasien tp
				  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
				  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
				, pendaftaran.kunjungan tk
				  LEFT JOIN master.ruangan asr ON tk.RUANGAN=asr.ID AND asr.JENIS=5
				  LEFT JOIN master.referensi asal ON asr.JENIS_KUNJUNGAN=asal.ID AND asal.JENIS=15
				  LEFT JOIN layanan.order_resep orr ON tk.NOMOR=orr.KUNJUNGAN
				  LEFT JOIN pendaftaran.kunjungan kf ON orr.NOMOR=kf.REF
				  LEFT JOIN layanan.order_detil_resep odr ON orr.NOMOR=odr.ORDER_ID
				  LEFT JOIN master.ruangan rr ON kf.RUANGAN = rr.ID 
				  left join layanan.farmasi lf ON kf.NOMOR = lf.KUNJUNGAN
				  LEFT JOIN aplikasi.pengguna usf ON lf.OLEH=usf.ID AND usf.`STATUS`!=0
		        LEFT JOIN master.pegawai mpf ON usf.NIP=mpf.NIP AND mpf.`STATUS`!=0
				, master.ruangan jkr  
				  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
				, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
					FROM aplikasi.instansi ai
						, master.ppk p
					WHERE ai.PPK=p.ID) INST
				, (SELECT ID, DESKRIPSI FROM master.referensi jk WHERE jk.ID=',LAPORAN,' AND jk.JENIS=15) jk
			WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN  AND pd.NOMOR=tk.NOPEN AND tp.RUANGAN=tk.RUANGAN 
					AND pd.STATUS IN (1,2) AND tk.REF IS NULL
					AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND tk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND tk.STATUS IN (1,2)
					AND rr.ID LIKE ''',vRUANGAN,'''
					',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
					GROUP BY pd.NOMOR
					ORDER BY INSTALASI1, UNITPELAYANAN, pd.TANGGAL	
					');
		
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;


-- Dumping database structure for pembayaran
CREATE DATABASE IF NOT EXISTS `pembayaran` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pembayaran`;

-- Dumping structure for procedure pembayaran.CetakSetoranIKS
DROP PROCEDURE IF EXISTS `CetakSetoranIKS`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranIKS`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, INST.KOTA, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
			 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	     , (	SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST, w.DESKRIPSI KOTA
				   FROM aplikasi.instansi ai
				       , `master`.ppk p
				       , `master`.wilayah w
			    	WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 
	 AND pt.TOTAL = 0	AND pj.JENIS !=1
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR = ',PKASIR ,'
      ORDER BY rf.ID, JENISKUNJUNGAN, DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasir
DROP PROCEDURE IF EXISTS `CetakSetoranKasir`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasir`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT CONCAT(''PERIODE : '',  DATE_FORMAT(MIN(BUKA),''%d-%m-%Y %H:%i:%s''), '' s/d '', DATE_FORMAT(MAX(TUTUP),''%d-%m-%Y %H:%i:%s''))
	  INTO @PERIODE
	  FROM pembayaran.transaksi_kasir sk WHERE NOMOR IN (',PNOMOR,')'); 
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST, w.DESKRIPSI KOTA
	  INTO @NAMAINST, @ALAMATINST, @KOTA
     FROM aplikasi.instansi ai
	       , `master`.ppk p
	       , `master`.wilayah w
    WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID;
    
	SET @sqlText = CONCAT('
	SELECT *
	  FROM (
		SELECT @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, @KOTA KOTA, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, CONCAT(''Layanan pasien An. '', master.getNamaLengkap(p.NORM)) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, ''Pembayaran tunai layanan pasien'' JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 @PERIODE TUTUPKASIR,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 AND pt.TOTAL > 0
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR = ',PKASIR ,'
	  AND tg.JENIS = 1
	 UNION
	 SELECT @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, @KOTA KOTA, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 p.NORM, CONCAT(''Piutang pasien An. '', master.getNamaLengkap(p.NORM)) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, ''Pembayaran tunai piutang pasien'' JENISBAYAR, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, 99, rf.ID) IDJENISKUNJUNGAN, CONCAT(rf.DESKRIPSI, IF(r.REF_ID = 1 AND INSTR(r.DESKRIPSI, ''Sore'') > 0, '' (Sore)'', '''')) JENISKUNJUNGAN,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, ROUND(tg.PEMBULATAN) PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, ROUND(pt.TOTAL) PENERIMAAN, 
			 @PERIODE TUTUPKASIR,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
	 FROM pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	     LEFT JOIN pembayaran.pelunasan_piutang_pasien p3 ON p3.ID = tg.REF
	     LEFT JOIN pembayaran.tagihan tg2 ON tg2.ID = p3.TAGIHAN_PIUTANG
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON ptp.TAGIHAN = tg2.ID AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` = 2 AND pt.JENIS = 1 AND pt.JENIS_LAYANAN_ID = 1 AND pt.TOTAL > 0
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR = ',PKASIR ,'
	  AND tg.JENIS = 2
	) a
     ORDER BY a.JENISKUNJUNGAN, DATE(a.TANGGAL), a.CARABAYAR');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirNonTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirNonTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirNonTunai`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT CONCAT(''PERIODE : '',  DATE_FORMAT(MIN(BUKA),''%d-%m-%Y %H:%i:%s''), '' s/d '', DATE_FORMAT(MAX(TUTUP),''%d-%m-%Y %H:%i:%s''))
	  INTO @PERIODE
	  FROM pembayaran.transaksi_kasir sk WHERE NOMOR IN (',PNOMOR,')'); 
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
	SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
	  INTO @NAMAINST, @ALAMATINST
     FROM aplikasi.instansi ai
	       , `master`.ppk p
    WHERE ai.PPK=p.ID;
	
	SET @sqlText = CONCAT('
	SELECT *
	  FROM (
		SELECT @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, 
				 @PERIODE PERIODE,
				 `master`.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`, 
				 pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR, crbyr.DESKRIPSI CARABAYAR,
				 rf.DESKRIPSI JENISKUNJUNGAN,
				 p.NORM, CONCAT(''Layanan pasien An. '', `master`.getNamaLengkap(p.NORM)) NAMAPASIEN, 
				 pp.NOMOR NOPEN,
				 CONCAT(ly.DESKRIPSI, ''<br>An. '', pt.NAMA, '' - '', pt.NO_ID, ''<br>No. Ref: '', pt.REF) JENIS_LAYANAN,
				 pt.TOTAL, pj.JENIS
		  FROM pembayaran.transaksi_kasir tk
				 LEFT JOIN aplikasi.pengguna us ON tk.KASIR = us.ID
				 LEFT JOIN `master`.pegawai mp ON us.NIP = mp.NIP
				 , pembayaran.pembayaran_tagihan pt
				 LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN = ptp.TAGIHAN AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
			    LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN = pp.NOMOR
			    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR = pj.NOPEN
			    LEFT JOIN `master`.referensi crbyr ON pj.JENIS = crbyr.ID AND crbyr.JENIS = 10
			    LEFT JOIN `master`.pasien p ON pp.NORM = p.NORM
			    LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR = tp.NOPEN
			    LEFT JOIN `master`.ruangan r ON tp.RUANGAN = r.ID AND r.JENIS = 5
			    LEFT JOIN `master`.referensi rf ON r.JENIS_KUNJUNGAN = rf.ID AND rf.JENIS = 15
				 LEFT JOIN `master`.referensi ly ON ly.JENIS = 172 AND ly.ID = pt.JENIS_LAYANAN_ID
		 WHERE tk.`STATUS` IN (1, 2)
			AND pt.TRANSAKSI_KASIR_NOMOR = tk.NOMOR 
			AND pt.`STATUS` != 0 
			AND pt.JENIS = 2
			AND tk.NOMOR IN (',PNOMOR,')
			AND tk.KASIR = ',PKASIR ,'
		UNION
		SELECT @NAMAINST NAMAINST, @ALAMATINST ALAMATINST, 
				 @PERIODE PERIODE,
				 `master`.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`, 
				 pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR, crbyr.DESKRIPSI CARABAYAR,
				 rf.DESKRIPSI JENISKUNJUNGAN,
				 p.NORM, CONCAT(''Piutang pasien An. '', `master`.getNamaLengkap(p.NORM)) NAMAPASIEN, 
				 pp.NOMOR NOPEN,
				 CONCAT(ly.DESKRIPSI, ''<br>An. '', pt.NAMA, '' - '', pt.NO_ID, ''<br>No. Ref: '', pt.REF) JENIS_LAYANAN,
				 pt.TOTAL, pj.JENIS
		  FROM pembayaran.transaksi_kasir tk
				 LEFT JOIN aplikasi.pengguna us ON tk.KASIR = us.ID
				 LEFT JOIN `master`.pegawai mp ON us.NIP = mp.NIP
				 , pembayaran.pembayaran_tagihan pt
				 LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	       	 LEFT JOIN pembayaran.pelunasan_piutang_pasien p3 ON p3.ID = tg.REF
	       	 LEFT JOIN pembayaran.tagihan tg2 ON tg2.ID = p3.TAGIHAN_PIUTANG
			 	 LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON ptp.TAGIHAN = tg2.ID AND ptp.`STATUS` = 1 AND ptp.UTAMA = 1
			    LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN = pp.NOMOR
			    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR = pj.NOPEN
			    LEFT JOIN `master`.referensi crbyr ON pj.JENIS = crbyr.ID AND crbyr.JENIS = 10
			    LEFT JOIN `master`.pasien p ON pp.NORM = p.NORM
			    LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR = tp.NOPEN
			    LEFT JOIN `master`.ruangan r ON tp.RUANGAN = r.ID AND r.JENIS = 5
			    LEFT JOIN `master`.referensi rf ON r.JENIS_KUNJUNGAN = rf.ID AND rf.JENIS = 15
				 LEFT JOIN `master`.referensi ly ON ly.JENIS = 172 AND ly.ID = pt.JENIS_LAYANAN_ID
		 WHERE tk.`STATUS` IN (1, 2)
			AND pt.TRANSAKSI_KASIR_NOMOR = tk.NOMOR 
			AND pt.`STATUS` != 0 
			AND pt.JENIS = 5
			AND tk.NOMOR IN (',PNOMOR,')
			AND tk.KASIR = ',PKASIR ,'
	 ) a
	 ORDER BY a.JENISKUNJUNGAN, a.TGLBAYAR, a.JENIS');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirPenjualanNonTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirPenjualanNonTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirPenjualanNonTunai`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
		 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
		 bk.DESKRIPSI BANK, kt.DESKRIPSI KARTUKREDIT, dc.NOMOR NOMORKARTU, dc.PEMILIK
	from pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	   , pembayaran.edc dc
	     LEFT JOIN master.referensi bk ON dc.BANK=bk.ID AND bk.JENIS=16
	     LEFT JOIN master.referensi kt ON dc.JENIS_KARTU=kt.ID AND kt.JENIS=17
	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE tk.NOMOR = pt.REF AND pt.`STATUS` != 0 AND pt.JENIS = 8
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS` = 2 AND pt.TAGIHAN = dc.TAGIHAN
	  AND tk.KASIR = ',PKASIR ,' AND dc.STATUS IN (1,2)
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirPenjualanTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirPenjualanTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirPenjualanTunai`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, ppj.PENGUNJUNG NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, ROUND(tg.PEMBULATAN) PEMBULATAN, 
		 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR
	from pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	   , penjualan.penjualan ppj
	     LEFT JOIN master.ruangan r ON ppj.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE tk.NOMOR = pt.REF AND pt.`STATUS` != 0 AND pt.JENIS = 8 AND pt.TAGIHAN = ppj.NOMOR AND ppj.STATUS IN (1,2)
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS` = 2
	  AND tk.KASIR = ',PKASIR ,'
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;