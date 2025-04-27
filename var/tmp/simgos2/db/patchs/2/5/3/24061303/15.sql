USE `layanan`;

-- Dumping structure for procedure layanan.CetakOrderResep
DROP PROCEDURE IF EXISTS `CetakOrderResep`;
DELIMITER //
CREATE PROCEDURE `CetakOrderResep`(IN `PNOMOR` CHAR(21))
BEGIN
	
	SELECT inst.PPK, inst.NAMA INSTASI, o.NOMOR, o.KUNJUNGAN, DATE_FORMAT(o.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(o.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
		, o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
		, IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
		, r.DESKRIPSI ASALPENGIRIM, master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
		, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
		, CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP
		FROM layanan.order_resep o
			  LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
			  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			, pendaftaran.kunjungan pk
		     LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
			, pendaftaran.pendaftaran pp
			  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
			, (SELECT mp.NAMA, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
		WHERE  o.`STATUS`IN (1,2) AND o.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR
			AND o.NOMOR=PNOMOR
	;
END//
DELIMITER ;