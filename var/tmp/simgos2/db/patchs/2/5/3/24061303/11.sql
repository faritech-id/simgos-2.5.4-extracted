USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilRad
DROP PROCEDURE IF EXISTS `CetakHasilRad`;
DELIMITER //
CREATE PROCEDURE `CetakHasilRad`(
	IN `PTINDAKAN` CHAR(11)
)
BEGIN
	SELECT INST.*
			, DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i:%s') TGLSKRG, LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, CONCAT(rjk.DESKRIPSI,' / ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) JKTGLALHIR
			, hrad.TANGGAL, hrad.KLINIS, hrad.KESAN, hrad.USUL, hrad.HASIL, hrad.BTK
			, master.getNamaLengkapPegawai(mp.NIP) DOKTER, mp.NIP NIPDOKTER
			, pk.NOPEN, pk.MASUK TGLREG, t.NAMA NAMATINDAKAN, r.DESKRIPSI UNITPENGANTAR, orad.ALASAN DIAGNOSA
			, p.ALAMAT
			, master.getNamaLengkapPegawai(dokasal.NIP) DOKTERASAL, master.getNamaLengkapPegawai(prad.NIP) RADIOGRAFER
		FROM layanan.hasil_rad hrad
			  LEFT JOIN master.dokter dok ON hrad.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			, layanan.tindakan_medis tm
			  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			  LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR = tm.KUNJUNGAN
			  LEFT JOIN layanan.order_rad orad ON orad.NOMOR = pku.REF AND orad.`STATUS` IN (1,2)
			  LEFT JOIN master.dokter dokasal ON orad.DOKTER_ASAL=dokasal.ID
			  LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS=tm.ID AND ptm.JENIS=3 AND ptm.KE=1 AND ptm.STATUS!=0
			  LEFT JOIN master.perawat prad ON ptm.MEDIS=prad.ID
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN layanan.order_rad ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
		AND hrad.TINDAKAN_MEDIS=PTINDAKAN AND hrad.`STATUS` !=0
	;

END//
DELIMITER ;