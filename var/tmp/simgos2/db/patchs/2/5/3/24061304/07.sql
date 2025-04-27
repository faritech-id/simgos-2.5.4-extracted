USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakHemodialisa1
DROP PROCEDURE IF EXISTS `CetakHemodialisa1`;
DELIMITER //
CREATE PROCEDURE `CetakHemodialisa1`(
	IN `PKUNJUNGAN` CHAR(20)
)
BEGIN
SELECT 
	inst.inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, inst.PPK IDPPK,  inst.KOTA KOTA
	, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM 
	, master.getNamaLengkap(pp.NORM) NAMAPASIEN, CONCAT (DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' / ',if(p.JENIS_KELAMIN=1, 'Laki-laki','Perempuan')) TANGGAL_LAHIR
	, ref.DESKRIPSI CARABAYAR, pp.NOMOR NOPEN
	, DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK , DATE_FORMAT(pk.KELUAR,'%d-%m-%Y %H:%i:%s') TGLKELUAR
	, pk.NOMOR NOKUN, pk.RUANGAN, mr.DESKRIPSI DESC_RUANGAN
	, hd.KUNJUNGAN, DATE_FORMAT(hd.WAKTU_PEMERIKSAAN,'%d-%m-%Y %H:%i:%s')WAKTU_PEMERIKSAAN, if (ku.DESKRIPSI IS NULL, '-',ku.DESKRIPSI) KELUHAN_UTAMA
	, tv.TINGKAT_KESADARAN TK , if(r.DESKRIPSI IS NULL, '-',r.DESKRIPSI) DESC_TK
	, if(CONCAT(tv.SISTOLIK,'/', tv.DISTOLIK) IS NULL, '-',CONCAT(ROUND(tv.SISTOLIK,0),' / ',ROUND(tv.DISTOLIK,0))) DARAH , IF(tv.FREKUENSI_NAFAS IS NULL, '-', ROUND(tv.FREKUENSI_NAFAS,0)) FREKUENSI_NAFAS
	, IF(tv.SUHU IS NULL, '-', CONCAT(tv.SUHU, ' Â°C')) SUHU 
	, ROUND(hd.QUICK_BLOOD,0) QB, ROUND(hd.QUICK_DIALISIS,0) QD, ROUND(hd.ULTRA_FILTRASI_VOLUME,0) UV, ROUND(hd.ULTRA_FILTRASI_RATE,0) UR
	, bal.WAKTU_PEMERIKSAAN
	, IF(bal.TOTAL_INTAKE IS NULL, '-', ROUND(bal.TOTAL_INTAKE,0)) INTAKE
	, IF(bal.TOTAL_OUTPUT IS NULL, '-', ROUND(bal.TOTAL_OUTPUT,0)) OUTPUT
	, (SELECT ROUND(bal.SKOR_BALLANCER_CAIRAN)
		FROM medicalrecord.penilaian_ballance_cairan bal
		ORDER BY bal.SKOR_BALLANCER_CAIRAN DESC LIMIT 1) BALLANCE_CAIRAN
	, pk.DPJP, master.getNamaLengkapPegawai(dokdpjp.NIP) NM_DPJP
	, dokdpjp.NIP NIP
	, CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) KONTROL
	, jk.RUANGAN, mr2.DESKRIPSI RUANG_KONTROL
	, e.EDUKASI
	, hd.OLEH,`master`.getNamaLengkapPegawai(mp.NIP) USER
	, medicalrecord.getHasilPenunjang(pp.NOMOR) PENUNJANG
	, DATE_FORMAT(LOCALTIME,'%d-%M-%Y %H:%m:%s') TIME_SIGN
FROM 
	pendaftaran.pendaftaran pp
	LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
	LEFT JOIN master.pasien p ON pp.NORM=p.NORM 
	, pendaftaran.kunjungan pk
	LEFT JOIN `master`.ruangan mr ON pk.RUANGAN=mr.ID
	LEFT JOIN `master`.dokter dokdpjp ON pk.DPJP= dokdpjp.ID
	LEFT JOIN `master`.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
	LEFT JOIN medicalrecord.edukasi_emergency e ON e.KUNJUNGAN=pk.NOMOR
	LEFT JOIN medicalrecord.jadwal_kontrol jk ON jk.KUNJUNGAN=pk.NOMOR
	LEFT JOIN `master`.ruangan mr2 ON mr2.ID=jk.RUANGAN
	, medicalrecord.pemantuan_hd_intradialitik hd
	LEFT JOIN medicalrecord.keluhan_utama ku ON hd.KUNJUNGAN=ku.KUNJUNGAN
	LEFT JOIN medicalrecord.tanda_vital tv ON hd.KUNJUNGAN=tv.KUNJUNGAN
	LEFT JOIN medicalrecord.penilaian_ballance_cairan bal ON bal.KUNJUNGAN=hd.KUNJUNGAN 
	LEFT JOIN `master`.referensi r ON tv.TINGKAT_KESADARAN=r.ID AND r.JENIS=179
	LEFT JOIN `master`.pegawai mp ON hd.OLEH=mp.ID
	, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT , mp.TELEPON, mp.FAX
					, ai.EMAIL, ai.WEBSITE
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pk.NOMOR=hd.KUNJUNGAN AND DATE(hd.WAKTU_PEMERIKSAAN)=DATE(bal.WAKTU_PEMERIKSAAN)
			AND pk.NOMOR=PKUNJUNGAN
	ORDER BY hd.WAKTU_PEMERIKSAAN ASC
	;
END//
DELIMITER ;