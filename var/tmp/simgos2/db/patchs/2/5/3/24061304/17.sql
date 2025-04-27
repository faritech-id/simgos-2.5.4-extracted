USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakSuratKelahiran
DROP PROCEDURE IF EXISTS `CetakSuratKelahiran`;
DELIMITER //
CREATE PROCEDURE `CetakSuratKelahiran`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
	       , `master`.getNamaDanGelar(p.GELAR_DEPAN, p.NAMA, p.GELAR_BELAKANG) NAMA
			 , `master`.getFormatNorm(p.NORM, '.') NORM, jk.DESKRIPSI JENIS_KELAMIN
	       , `master`.getCariUmur(pdf.TANGGAL, p.TANGGAL_LAHIR) UMUR
	       , DATE_FORMAT(skk.TANGGAL,'%d-%m-%Y') TGLLHR, DATE_FORMAT(skk.JAM,'%H:%i:%s') JAMLHR
	       , p.ALAMAT AS ALAMAT_PASIEN, pkrj.DESKRIPSI PEKERJAAN
	       , kec.DESKRIPSI KECAMATAN
	       , kel.DESKRIPSI KELURAHAN
	       , master.getNamaLengkapPegawai(dok.NIP) DPJP, dok.NIP
	       , master.getNamaLengkapPegawai(pr.NIP) BIDAN, pr.NIP PRNIP
	       , skk.NOMOR NOMORSKK, ayah.NAMA AYAH, ibu.NAMA IBU, `master`.getFormatNorm(skk.NORM_IBU, '.') NORM_IBU
	       , ktpayah.NOMOR KTPAYAH, ktpibu.NOMOR KTPIBU
	       , IF(master.getAlamatPasien(p.NORM) IS NULL, IFNULL(ktpayah.ALAMAT,ktpibu.ALAMAT),master.getAlamatPasien(p.NORM)) ALAMATORTU
			 , IFNULL(ksr.KODE_SURAT,'             ') KODE_SURAT
	       , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	       , skk.DIBUAT_TANGGAL, DATE_FORMAT(pdf.TANGGAL,'%d-%m-%Y') TGLMSK
	       , FLOOR(skk.BERAT) BERAT_BAYI , FLOOR(skk.PANJANG) PANJANG_BAYI
	       , DATE_FORMAT(skk.DIBUAT_TANGGAL,'%Y') TAHUN
	  FROM medicalrecord.surat_kelahiran skk
	       LEFT JOIN master.keluarga_pasien ayah ON skk.BAPAK = ayah.ID
	       LEFT JOIN master.kartu_identitas_keluarga ktpayah ON ayah.ID = ktpayah.KELUARGA_PASIEN_ID AND ktpayah.JENIS=1
	       LEFT JOIN master.keluarga_pasien ibu ON skk.IBU = ibu.ID
	       LEFT JOIN master.kartu_identitas_keluarga ktpibu ON ibu.ID = ktpibu.KELUARGA_PASIEN_ID AND ktpibu.JENIS=1
	       LEFT JOIN master.perawat pr ON skk.BIDAN = pr.ID
	       LEFT JOIN medicalrecord.nutrisi mn ON skk.KUNJUNGAN=mn.KUNJUNGAN AND mn.`STATUS`=1
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
	WHERE skk.KUNJUNGAN = PKUNJUNGAN
	  AND skk.`STATUS` = 1
	  AND k.NOMOR = skk.KUNJUNGAN
	  AND pdf.NOMOR = k.NOPEN
	  AND p.NORM = pdf.NORM
	  AND jk.JENIS = 2 AND jk.ID = p.JENIS_KELAMIN
	  AND pkrj.JENIS = 4 AND pkrj.ID = p.PEKERJAAN
	  AND dok.ID = skk.DPJP;
END//
DELIMITER ;