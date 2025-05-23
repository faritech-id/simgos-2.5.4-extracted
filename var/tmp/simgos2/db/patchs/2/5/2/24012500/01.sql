USE `laporan`;
DROP PROCEDURE IF EXISTS `LaporanKlaimTerpisah`;
DELIMITER //
CREATE PROCEDURE `LaporanKlaimTerpisah`(
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
	IN `JENISFORMULARIUM` INT,
	IN `PENGGOLONGAN` INT
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
		SELECT inst.PPK, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
			, CONCAT(''LAPORAN KLAIM TERPISAH FARMASI'') JENISLAPORAN
			, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
			, LPAD(pp.NORM,8,''0'') NORM, master.getNamaLengkap(pp.NORM) NM_PASIEN
			, kap.NOMOR NOMORKARTU, pj.NOMOR NOMORSEP
			, f.ID,f.FARMASI, b.NAMA OBAT, f.JUMLAH, if(f.RACIKAN=0,''Bukan Racikan'',''Racikan'') RACIKAN
			, f.JUMLAH_RACIKAN , rt.JUMLAH JML_OBAT_TAGIHAN, rt.TARIF, (rt.JUMLAH*rt.TARIF)HRG_TOT
			, master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI, ik.NAMA KTG
			, f.FREKUENSI, far.FREKUENSI DESC_FREKUENSI
			, f.SIGNA1, f.SIGNA2, f.DOSIS
			, pk.MASUK
		FROM 
			layanan.farmasi f
			LEFT JOIN pembayaran.rincian_tagihan rt ON f.ID=rt.REF_ID AND rt.JENIS=4
			LEFT JOIN `master`.frekuensi_aturan_resep far ON far.ID=f.FREKUENSI
			, inventory.barang b
			LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
			LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID
			, pendaftaran.kunjungan pk
			LEFT JOIN pendaftaran.pendaftaran pp ON pk.NOPEN=pp.NOMOR
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			LEFT JOIN master.kartu_asuransi_pasien kap ON pp.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
			, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
									FROM aplikasi.instansi ai
										, master.ppk mp
									WHERE ai.PPK=mp.ID) inst
		WHERE f.KUNJUNGAN=pk.NOMOR AND f.FARMASI=b.ID AND f.`STATUS`=2 AND f.KLAIM_TERPISAH = 1
		AND pk.MASUK BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' 
		',IF(RUANGAN='0','',CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''')),'
		',IF(CARABAYAR='0','',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(KATEGORI='0','',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
		',IF(BARANG='0','',CONCAT(' AND b.ID=',BARANG)),'
		',IF(JENISINVENTORY='0','',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
		',IF(JENISKATEGORI='0','',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
		',IF(KATEGORIBARANG='0','',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
		',IF(JENISGENERIK='0','',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
		',IF(JENISFORMULARIUM='0','',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
		',IF(PENGGOLONGAN='0','',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
		');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;


END//
DELIMITER ;