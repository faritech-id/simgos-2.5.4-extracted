USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilMikroskopik
DROP PROCEDURE IF EXISTS `CetakHasilMikroskopik`;
DELIMITER //
CREATE PROCEDURE `CetakHasilMikroskopik`(
	IN `P_KUNJUNGAN` CHAR(19)
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.IDPPK, INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y'') TGLSKRG
				 , hlm.ID, hlm.KUNJUNGAN, hlm.BAHAN, hlm.DIAGNOSA, hlm.TERAPI_ANTIBIOTIK
				 , hlmd.HASIL
				 , ref_p.DESKRIPSI
				 , master.getNamaLengkapPegawai(d.NIP) AS DOKTER
				 , d.NIP
				 , ps.NORM, master.getNamaLengkap(ps.NORM) AS PASIEN
				 , master.getNamaLengkapPegawai(da.NIP) AS DOKTER_ASAL
				 , DATE_FORMAT(k.MASUK, ''%d-%m-%Y %H:%i:%s'') AS TGL_TERIMA
				 , DATE_FORMAT(k.KELUAR, ''%d-%m-%Y %H:%i:%s'') AS TGL_SELESAI
				 , ol.NOMOR AS NOMOR_LAB, k.NOMOR
				 , '''' PEMERIKSA
		  FROM pendaftaran.kunjungan k
				 , pendaftaran.pendaftaran p
				 , layanan.hasil_lab_mikroskopik hlm
				 , layanan.hasil_lab_mikroskopik_detail hlmd
				 , layanan.order_lab ol
				 , master.referensi ref_p
				 , master.dokter d
				 , master.dokter da
				 , master.pegawai pa
				 , master.pasien ps
				 , (SELECT w.DESKRIPSI KOTA, ai.PPK IDPPK
					   FROM aplikasi.instansi ai
						     , master.ppk p
							  , master.wilayah w
					  WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
		 WHERE hlm.KUNJUNGAN = hlmd.KUNJUNGAN
			AND ref_p.JENIS = 134
			AND hlmd.PEMERIKSAAN = ref_p.ID
			AND hlmd.STATUS = 1
			AND hlm.DOKTER = d.ID
			AND k.NOMOR =  hlm.KUNJUNGAN
			AND k.NOPEN = p.NOMOR
			AND p.NORM = ps.NORM
			AND k.REF = ol.NOMOR
			AND ol.DOKTER_ASAL = da.ID
			AND da.NIP = pa.NIP
			AND k.NOMOR = "',P_KUNJUNGAN, '"');
	 
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;