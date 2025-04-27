-- Dumping database structure for layanan
USE `layanan`;

-- Dumping structure for procedure layanan.CetakFakturDetilResep
DROP PROCEDURE IF EXISTS `CetakFakturDetilResep`;
DELIMITER //
CREATE PROCEDURE `CetakFakturDetilResep`(IN `PKUNJUNGAN` CHAR(21)
)
BEGIN
	SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI, lf.ID NOMOR, lf.KUNJUNGAN, DATE_FORMAT(lf.TANGGAL,'%d-%m-%Y') TANGGAL, TIME(lf.TANGGAL) WAKTU, master.getNamaLengkapPegawai(mp.NIP) NAMADOKTER, o.BERAT_BADAN, o.TINGGI_BADAN
		, o.DIAGNOSA, o.ALERGI_OBAT, IF(o.GANGGUAN_FUNGSI_GINJAL=0,'Tidak','Ya') GANGGUAN_FUNGSI_GINJAL
		, IF(o.MENYUSUI=0,'Tidak','Ya') MENYUSUI , IF(o.HAMIL=0,'Tidak','Ya') HAMIL
		, r.DESKRIPSI ASALPENGIRIM, master.getNamaLengkap(ps.NORM) NAMAPASIEN, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
		, ps.ALAMAT,LPAD(ps.NORM,8,'0') NORM
		, CONCAT('RESEP ',UPPER(jenisk.DESKRIPSI)) JENISRESEP
		, ib.NAMA NAMAOBAT, lf.JUMLAH
		
		, master.getAturanPakai2(lf.FREKUENSI, lf.DOSIS, lf.RUTE_PEMBERIAN) ATURANPAKAI
		, lf.KETERANGAN, CONCAT(lf.RACIKAN,lf.GROUP_RACIKAN) RACIKAN, lf.PETUNJUK_RACIKAN, lf.`STATUS` STATUSLAYANAN
		, rt.TARIF HARGA, (rt.TARIF * lf.JUMLAH) JML_HRG, usr.NAMA PETUGAS
		FROM layanan.farmasi lf
			  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
			  LEFT JOIN  pembayaran.rincian_tagihan rt ON lf.ID = rt.REF_ID AND rt.JENIS = 4
			  LEFT JOIN inventory.harga_barang hb ON hb.ID = rt.TARIF_ID
			  LEFT JOIN aplikasi.pengguna usr ON usr.ID = lf.OLEH
			, pendaftaran.kunjungan pk
		     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
		     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
			  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
			  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
			  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
		     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
		   , pendaftaran.pendaftaran pp
			  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
			, inventory.barang ib
			, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
		WHERE lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
			AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
			AND lf.KUNJUNGAN=PKUNJUNGAN
		ORDER BY lf.RACIKAN, lf.GROUP_RACIKAN;
END//
DELIMITER ;