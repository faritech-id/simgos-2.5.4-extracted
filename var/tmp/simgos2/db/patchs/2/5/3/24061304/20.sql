USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakSuratSehat
DROP PROCEDURE IF EXISTS `CetakSuratSehat`;
DELIMITER //
CREATE PROCEDURE `CetakSuratSehat`(
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, inst.NAMA NAMA_INSTANSI, inst.ALAMAT AS ALAMAT_INSTANSI, inst.DESWILAYAH WILAYAH_INSTANSI
		, CONCAT(ss.NOMOR) NOMOR_SURAT, `master`.getNamaLengkapPegawai(ds.NIP) DPJP, ds.NIP
	   , p.NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
	   , jk.DESKRIPSI JENIS_KELAMIN, p.ALAMAT ALAMATPASIEN, ss.TANGGAL
	   , ss.ATAS_PERMINTAAN, ss.HASIL_PEMERIKSAAN, UPPER(REPLACE(REPLACE(REPLACE(REPLACE
				 (master.getReplaceFont(ss.KETERANGAN)
					,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')) KETERANGAN
		, ss.DIBUAT_TANGGAL, DATE_FORMAT(ss.DIBUAT_TANGGAL,'Y') TAHUN
	   , IFNULL(ksr.KODE_SURAT,'      ') KODE_SURAT
	   , (SELECT jns.KODE FROM master.jenis_nomor_surat jns WHERE jns.ID=1) JNSSURAT
	
	FROM medicalrecord.surat_sehat ss
		, pendaftaran.kunjungan pk
		  LEFT JOIN `master`.dokter ds ON pk.DPJP=ds.ID
		  LEFT JOIN master.kode_surat_ruangan ksr ON pk.RUANGAN=ksr.RUANGAN
		, pendaftaran.pendaftaran pd
		, `master`.pasien p
		  LEFT JOIN `master`.referensi jk ON p.JENIS_KELAMIN=jk.ID AND jk.JENIS=2
		, (SELECT mp.NAMA, ai.PPK, CONCAT(mp.ALAMAT, ' Telp. ', mp.TELEPON, ' Fax. ', mp.FAX) ALAMAT, mp.DESWILAYAH
					FROM aplikasi.instansi ai
						  , master.ppk mp
				  WHERE ai.PPK=mp.ID) inst
	WHERE ss.KUNJUNGAN=pk.NOMOR AND ss.`STATUS`!=0 
	AND pk.`STATUS`!=0
		AND pk.NOPEN=pd.NOMOR AND pd.`STATUS`!=0 AND pd.NORM=p.NORM
		AND ss.KUNJUNGAN=PKUNJUNGAN;
END//
DELIMITER ;