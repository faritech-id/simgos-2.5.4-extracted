USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilKultur
DROP PROCEDURE IF EXISTS `CetakHasilKultur`;
DELIMITER //
CREATE PROCEDURE `CetakHasilKultur`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
	   SELECT ol.NOMOR NO_LAB, pd.NORM  
			    , master.getNamaLengkap(pd.NORM) NAMA_PASIEN, master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR, rasal.DESKRIPSI RUANG_ASAL
			    , CONCAT(master.getNamaLengkap(pd.NORM),'' / '', master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) ,'' / '', rasal.DESKRIPSI) NAMALENGKAP
			    , IF(kp.NOMOR IS NULL,master.getNamaLengkapPegawai(ds.NIP), CONCAT(master.getNamaLengkapPegawai(ds.NIP),'' / '',kp.NOMOR)) DOKTER_PENGIRIM, ol.ALASAN DIAGNOSA
			    , kj.MASUK TGLTERIMA, kj.KELUAR TGL_HASIL
			    , lk.BAHAN, lk.GRAM, lk.AEROB, lk.KESIMPULAN, lk.ANJURAN, lk.CATATAN
			    , master.getNamaLengkapPegawai(dlab.NIP) DOKTER_LAB
			    , dlab.NIP
			    , INST.IDPPK, INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
			    #, lm.TERAPI_ANTIBIOTIK TERAPI_ANTIBIOTIK
			    , '''' TERAPI_ANTIBIOTIK
				 , '''' KEPALA_INSTALASI
		  FROM layanan.hasil_lab_kultur lk
		       LEFT JOIN master.dokter dlab ON lk.DOKTER=dlab.ID
		       #LEFT JOIN layanan.hasil_lab_mikroskopik lm ON lk.KUNJUNGAN=lm.KUNJUNGAN AND lm.`STATUS`!=0
		  	  , pendaftaran.kunjungan kj
			  , layanan.order_lab ol
				 LEFT JOIN pendaftaran.kunjungan asal ON ol.KUNJUNGAN=asal.NOMOR AND asal.`STATUS`!=0
				 LEFT JOIN master.ruangan rasal ON asal.RUANGAN=rasal.ID
				 LEFT JOIN master.dokter ds ON ol.DOKTER_ASAL=ds.ID
				 LEFT JOIN pegawai.kontak_pegawai kp ON ds.NIP=kp.NIP AND kp.JENIS=3 AND kp.`STATUS`!=0
			  , pendaftaran.pendaftaran pd
			  , master.pasien p
			  	, (SELECT w.DESKRIPSI KOTA, ai.PPK IDPPK
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		 WHERE lk.KUNJUNGAN=''',PKUNJUNGAN, ''' AND lk.`STATUS`!=0
		   AND lk.KUNJUNGAN=kj.NOMOR AND kj.`STATUS`!=0
			AND kj.REF=ol.NOMOR AND ol.`STATUS`!=0
			AND kj.NOPEN=pd.NOMOR AND pd.`STATUS`!=0
			AND pd.NORM=p.NORM 
		');
	 
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;