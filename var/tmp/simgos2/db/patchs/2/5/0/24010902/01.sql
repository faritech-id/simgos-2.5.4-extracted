USE `medicalrecord`;
DROP PROCEDURE IF EXISTS `CetakRekonsiliasiAdmisi`;
DELIMITER //
CREATE PROCEDURE `CetakRekonsiliasiAdmisi`(
	IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT 
		inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, inst.PPK IDPPK
		, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
		, DATE_FORMAT(pasien.TANGGAL_LAHIR ,'%d-%m-%Y') TANGGAL_LAHIR
		, if (pasien.JENIS_KELAMIN=1, 'L','P') JK
		, pk.RUANGAN, r.DESKRIPSI
		, `master`.getNamaLengkap(pp.NORM) NM_PASIEN
		, mra.KUNJUNGAN, mrad.OBAT_DARI_LUAR KD_OBAT,if(b.ID IS NULL, mrad.OBAT_DARI_LUAR,b.NAMA) NM_OBAT
		, mrad.DOSIS
		, mrad.FREKUENSI KD_F ,f.FREKUENSI DESC_FREKUENSI
		, mrad.RUTE KD_RUTE, mr.DESKRIPSI DESC_RUTE
		, mrad.TINDAK_LANJUT KD_TL , tl.DESKRIPSI TINDAK_LANJUT
		, mra.TIDAK_MENGGUNAKAN_OBAT_SEBELUM_ADMISI STATUS
		, mrad.PERUBAHAN_ATURAN_PAKAI PAP , f2.FREKUENSI DESC_PAP
		, DATE_FORMAT(mra.TANGGAL, '%d-%m-%Y %H:%i:%s') TANGGAL
		, mra.OLEH , `master`.getNamaLengkapPegawai(mp.NIP) USER
		
	
	FROM 
		pendaftaran.kunjungan pk
		LEFT JOIN `master`.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		, pendaftaran.pendaftaran pp
		LEFT JOIN `master`.pasien pasien ON pasien.NORM= pp.NORM
		, medicalrecord.rekonsiliasi_admisi mra
		LEFT JOIN aplikasi.pengguna mp ON mp.ID=mra.OLEH
		, medicalrecord.rekonsiliasi_admisi_detil mrad
		LEFT JOIN `master`.frekuensi_aturan_resep f ON f.ID=mrad.FREKUENSI 
		LEFT JOIN `master`.frekuensi_aturan_resep f2 ON f2.ID=mrad.PERUBAHAN_ATURAN_PAKAI 
		LEFT JOIN `master`.referensi mr ON mr.ID=mrad.RUTE AND mr.JENIS=217
		LEFT JOIN `master`.referensi tl ON tl.ID=mrad.TINDAK_LANJUT AND tl.JENIS=245
		LEFT JOIN inventory.barang b ON b.ID=mrad.OBAT_DARI_LUAR
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			            FROM aplikasi.instansi ai
			              , master.ppk mp
			            WHERE ai.PPK=mp.ID) inst
	WHERE mra.ID= mrad.REKONSILIASI_ADMISI AND pk.NOMOR=mra.KUNJUNGAN AND pk.NOPEN=pp.NOMOR
	AND pk.NOMOR=PKUNJUNGAN;

END//
DELIMITER ;