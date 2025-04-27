USE `laporan`;

DROP PROCEDURE IF EXISTS `LaporanPenjualanDetil`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPenjualanDetil`(
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
   SET @HRG=0; 
   
	SET @sqlText = CONCAT('
		SELECT  pp.NOMOR, pp.PENGUNJUNG, pp.KETERANGAN, pp.TANGGAL, ib.ID
				  , ib.NAMA NAMAOBAT, IF(ref.DESKRIPSI IS NULL, ppd.ATURAN_PAKAI, ref.DESKRIPSI) ATURAN_PAKAI
				  , SUM(ppd.JUMLAH) JUMLAH,
				  (SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) RETUR,
				  (SUM(ppd.JUMLAH) - IF((SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) IS NULL, 0,(SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG))) JMLJUAL,
				   @TOTALJUAL:=((SUM(ppd.JUMLAH) - IF((SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) IS NULL, 0,(SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG))) * inventory.getHargaJual(ppd.BARANG, ppd.HARGA_BARANG, ppd.MARGIN, ppd.PPN)) TOTALJUAL
					, pt.TOTAL, @HRG:=inventory.getHargaJual(ppd.BARANG, ppd.HARGA_BARANG, ppd.MARGIN, ppd.PPN) HARGA_JUAL, ppn.PPN
					, @HRG_DASAR:=inventory.getHrgDasarBarang(ppd.BARANG, pp.TANGGAL) HRG_DASAR	
					, @MARGIN_FIX:=(@HRG_DASAR*mpf.MARGIN/100) MARGIN_FIX
					, @HRG_SATUAN:=(@MARGIN_FIX+@HRG_DASAR) HARGA_JUAL
					, @TOTAL_HRG:=(@HRG_SATUAN*ppd.JUMLAH) TOTAL_HARGA
					, (@TOTAL_HRG* ppn.PPN/100) NILAI_PPN
					, mpf.MARGIN NILAI_MARGIN
					, IF(pp.`STATUS`=2,''Sudah Bayar'',IF(pp.`STATUS`=1,''Belum Bayar'',''Batal'')) KET,
					CONCAT(''LAPORAN PENJUALAN '',UPPER(jk.DESKRIPSI)) JENISLAPORAN, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
					, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			      , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
	FROM penjualan.penjualan pp
	     LEFT JOIN master.ruangan rg ON pp.RUANGAN=rg.ID AND rg.JENIS=5
	     LEFT JOIN master.referensi jk ON rg.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
	     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
		, penjualan.penjualan_detil ppd
		  LEFT JOIN master.referensi ref ON ref.ID LIKE LEFT(ppd.ATURAN_PAKAI,3) AND ref.JENIS=41
		  LEFT JOIN inventory.harga_barang hb ON ppd.HARGA_BARANG=hb.ID 
		  LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = ppd.MARGIN
		  LEFT JOIN penjualan.ppn_penjualan ppn ON ppn.ID=ppd.PPN
		, inventory.barang ib
		  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
		  ',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
		, pembayaran.tagihan pt
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pp.NOMOR=ppd.PENJUALAN_ID AND pp.`STATUS` IN (1,2) AND ppd.`STATUS` IN (1,2) AND rg.JENIS_KUNJUNGAN=',LAPORAN,'
	  AND pp.NOMOR=pt.ID AND pt.JENIS=4 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
	  AND pp.RUANGAN LIKE ''',vRUANGAN,''' 
	  ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
	  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
	  ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
	  ',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
	  ',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
	  ',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
	  ',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
	  ',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
	  ',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
	  AND ppd.BARANG=ib.ID
	GROUP BY pp.NOMOR, ppd.BARANG
	ORDER BY pp.TANGGAL
				
		
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;