USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakKeteranganOpname
DROP PROCEDURE IF EXISTS `CetakKeteranganOpname`;
DELIMITER //
CREATE PROCEDURE `CetakKeteranganOpname`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
	       , `master`.getNamaDanGelar(p.GELAR_DEPAN, p.NAMA, p.GELAR_BELAKANG) NAMA
			 , `master`.getFormatNorm(p.NORM, '.') NORM, jk.DESKRIPSI JENIS_KELAMIN
	       , `master`.getCariUmur(pdf.TANGGAL, p.TANGGAL_LAHIR) UMUR
	       , p.ALAMAT AS ALAMAT_PASIEN, pkrj.DESKRIPSI PEKERJAAN
	       , kec.DESKRIPSI KECAMATAN
	       , kel.DESKRIPSI KELURAHAN
	       , master.getNamaLengkapPegawai(dok.NIP) DPJP, dok.NIP
	       , opn.NOMOR NOMOROPN, opn.KETERANGAN KETERANGAN
			 , IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	       , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	       , IFNULL(DATE_FORMAT(lpp.TANGGAL,'%d-%m-%Y'), 'sekarang') TGLKELUAR
	       , DATE_FORMAT(opn.DIBUAT_TANGGAL,'%d-%m-%Y') DIBUAT_TANGGAL
			 , DATE_FORMAT(pdf.TANGGAL,'%d-%m-%Y') TGLMSK
			 , DATE_FORMAT(opn.DIBUAT_TANGGAL,'%Y') TAHUN
	  FROM medicalrecord.surat_opname opn
	  		 , pendaftaran.kunjungan k
	  		 LEFT JOIN layanan.pasien_pulang lpp ON k.NOPEN=lpp.NOPEN AND lpp.`STATUS`=1
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
	WHERE opn.KUNJUNGAN = PKUNJUNGAN
	  AND opn.`STATUS` = 1
	  AND k.NOMOR = opn.KUNJUNGAN
	  AND pdf.NOMOR = k.NOPEN
	  AND p.NORM = pdf.NORM
	  AND jk.JENIS = 2 AND jk.ID = p.JENIS_KELAMIN
	  AND pkrj.JENIS = 4 AND pkrj.ID = p.PEKERJAAN
	  AND dok.ID = k.DPJP;
END//
DELIMITER ;