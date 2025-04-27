USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakSuratSakit
DROP PROCEDURE IF EXISTS `CetakSuratSakit`;
DELIMITER //
CREATE PROCEDURE `CetakSuratSakit`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
	       , skt.NOMOR NOMORSK, skt.LAMA, DATE_FORMAT(skt.TANGGAL,'%d-%m-%Y') MULAI
			 , DATE_FORMAT(skt.TANGGAL + INTERVAL skt.LAMA-1 DAY,'%d-%m-%Y') BERAKHIR, skt.DESKRIPSI KETERANGAN
	       , `master`.getNamaDanGelar(p.GELAR_DEPAN, p.NAMA, p.GELAR_BELAKANG) NAMA
			 , `master`.getFormatNorm(p.NORM, '.') NORM, jk.DESKRIPSI JENIS_KELAMIN
	       , `master`.getCariUmur(pdf.TANGGAL, p.TANGGAL_LAHIR) UMUR
	       , IFNULL(p.ALAMAT,'') ALAMAT_PASIEN, IFNULL(pkrj.DESKRIPSI,'') PEKERJAAN
	       , IFNULL(kec.DESKRIPSI,'') KECAMATAN
	       , IFNULL(kel.DESKRIPSI,'') KELURAHAN
	       , master.getNamaLengkapPegawai(dok.NIP) DPJP
	       , dok.NIP, IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	       , skt.DIBUAT_TANGGAL
	       , DATE_FORMAT(skt.DIBUAT_TANGGAL,'%Y') TAHUN
	       , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	  FROM medicalrecord.surat_sakit skt
	  		 , pendaftaran.kunjungan k
	  		 	LEFT JOIN master.kode_surat_ruangan ksr ON k.RUANGAN=ksr.RUANGAN
	  		 , pendaftaran.pendaftaran pdf
	  		 , `master`.pasien p
	  		 LEFT JOIN master.wilayah kec ON kec.ID = LEFT(p.WILAYAH, 6)
	  		 LEFT JOIN master.wilayah kel ON kel.ID = p.WILAYAH
	  		 , `master`.referensi jk
	  		 , `master`.referensi pkrj
	  		 , `master`.dokter dok
			 , (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE skt.KUNJUNGAN = PKUNJUNGAN
	  AND skt.`STATUS` = 1
	  AND k.NOMOR = skt.KUNJUNGAN
	  AND pdf.NOMOR = k.NOPEN
	  AND p.NORM = pdf.NORM
	  AND jk.JENIS = 2 AND jk.ID = p.JENIS_KELAMIN
	  AND pkrj.JENIS = 4 AND pkrj.ID = p.PEKERJAAN
	  AND dok.ID = k.DPJP
	  GROUP BY skt.KUNJUNGAN;
END//
DELIMITER ;