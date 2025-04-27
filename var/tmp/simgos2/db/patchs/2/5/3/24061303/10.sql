USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilPCR
DROP PROCEDURE IF EXISTS `CetakHasilPCR`;
DELIMITER //
CREATE PROCEDURE `CetakHasilPCR`(
	IN `P_KUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.IDPPK, INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
				 , hlm.*				 
				 , master.getNamaLengkapPegawai(d.NIP) AS NAMA_DOKTER
				 , d.NIP
				 , ps.NORM, master.getNamaLengkap(ps.NORM) AS PASIEN
				 , master.getNamaLengkapPegawai(da.NIP) AS DOKTER_ASAL				
				 , DATE_FORMAT(k.MASUK, ''%d-%m-%Y %H:%i:%s'') AS TGL_TERIMA
				 , DATE_FORMAT(k.KELUAR, ''%d-%m-%Y %H:%i:%s'') AS TGL_SELESAI
				 , ol.NOMOR AS NOMOR_LAB, k.NOMOR
		  FROM pendaftaran.kunjungan k
				 , pendaftaran.pendaftaran p
				 , layanan.hasil_lab_pcr hlm
				 , layanan.order_lab ol
				 , master.dokter d
				 , master.dokter da
				 , master.pegawai pa
				 , master.pasien ps
				 , (SELECT w.DESKRIPSI KOTA, ai.PPK IDPPK
						FROM aplikasi.instansi ai
							  , master.ppk p
							  , master.wilayah w
					  WHERE ai.PPK = p.ID AND p.WILAYAH = w.ID) INST
		 WHERE k.NOMOR = ''',P_KUNJUNGAN, '''
		   AND hlm.DOKTER = d.ID
		   AND k.NOMOR =  hlm.KUNJUNGAN
		   AND k.NOPEN = p.NOMOR
		   AND p.NORM = ps.NORM
		   AND k.REF = ol.NOMOR
		   AND ol.DOKTER_ASAL = da.ID
		   AND da.NIP = pa.NIP');
   	 
   	
   	PREPARE stmt FROM @sqlText;
   	EXECUTE stmt;
   	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;