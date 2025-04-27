USE `laporan`;
DROP PROCEDURE IF EXISTS `LaporanPelayananBonSisa`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPelayananBonSisa`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT, IN `KATEGORI` INT, IN `BARANG` INT, IN `JENISINVENTORY` INT, IN `JENISKATEGORI` INT, IN `KATEGORIBARANG` INT, IN `JENISGENERIK` TINYINT, IN `JENISFORMULARIUM` INT, IN `PENGGOLONGAN` INT
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
   	SELECT
		  bon.TANGGAL TGL_BON, lb.INPUT_TIME TGL_LYN, bon.REF
		  ,pk.REF NO_RESEP, LPAD(pp.NORM,8,''0'') NORM
		  ,master.getNamaLengkap(pp.NORM) NAMAPS , crbyr.DESKRIPSI CARA_BYR
		  , b.ID ,b.NAMA OBAT ,pk.RUANGAN , mr.DESKRIPSI DEPO 
		  , f.JUMLAH JML_ORDER
		  , bon.JUMLAH JML_BON
		  , if (lb.JUMLAH IS NULL,''0'',SUM(lb.JUMLAH)) JML_BON_DILAYANI
		  , bon.SISA SISA		  
		  , pk.NOMOR
		  ,inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
		  ,master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
		  ,master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		  ,IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
		  ,IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
		
	FROM 
		layanan.bon_sisa_farmasi bon
		LEFT JOIN layanan.layanan_bon_sisa_farmasi lb ON lb.REF=bon.ID
		, inventory.barang b 
		LEFT JOIN inventory.kategori ik ON b.KATEGORI=ik.ID
		LEFT JOIN inventory.penggolongan_barang pb ON b.ID=pb.BARANG
		, layanan.farmasi f 
		LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR=f.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR=pk.NOPEN
		LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS = 10
		LEFT JOIN master.ruangan mr ON pk.RUANGAN=mr.ID	
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			            FROM aplikasi.instansi ai
			              , master.ppk mp
			            WHERE ai.PPK=mp.ID) inst
		WHERE f.ID=bon.REF AND bon.FARMASI=b.ID 
				AND f.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND pk.RUANGAN LIKE ''',vRUANGAN,'''
				',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(BARANG=0,'',CONCAT(' AND b.ID=',BARANG)),'
				',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
				',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
				',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
				',IF(JENISGENERIK=0,'',CONCAT(' AND b.JENIS_GENERIK=',JENISGENERIK)),'
				',IF(JENISFORMULARIUM=0,'',CONCAT(' AND b.FORMULARIUM=',JENISFORMULARIUM)),'
				',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
			GROUP BY bon.REF 
			ORDER BY bon.TANGGAL
				
	');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;