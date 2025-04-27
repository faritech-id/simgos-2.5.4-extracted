USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakLapOperasi
DROP PROCEDURE IF EXISTS `CetakLapOperasi`;
DELIMITER //
CREATE PROCEDURE `CetakLapOperasi`(
	IN `PID` INT
)
BEGIN
	SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI,LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR
			, IFNULL(pg.NIP,mpdok.NIP) NIP, r.ID IDRUANG
			, CONCAT('Bagian/SMF : ',r.DESKRIPSI,' / ',IFNULL(smf1.DESKRIPSI,smf.DESKRIPSI)) SMF
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 1),master.getNamaLengkapPegawai(mpdok.NIP)) DOKTEROPERATOR
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 2),op.ASISTEN_DOKTER) ASISTEN_DOKTER
			, master.`getPelaksanaOperasi`(op.ID, 3) DRPERFUSI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 4),master.getNamaLengkapPegawai(mpanas.NIP)) DOKTERANASTESI
			, IFNULL(master.`getPelaksanaOperasi`(op.ID, 5),op.ASISTEN_ANASTESI) ASISTEN_ANASTESI
			, master.`getPelaksanaOperasi`(op.ID, 6) PENATA
			, master.`getPelaksanaOperasi`(op.ID, 7) SCRUB
			, master.`getPelaksanaOperasi`(op.ID, 8) SIRKULER
			, master.`getPelaksanaOperasi`(op.ID, 9) PERFUSI
			, master.`getPelaksanaOperasi`(op.ID, 10) DRTAMU
			, master.`getPelaksanaOperasi`(op.ID, 11) RADIOGRAFER
			, ja.DESKRIPSI JENISANASTESI, gol.DESKRIPSI GOLONGANOPERASI, jop.DESKRIPSI JENISOPERASI
			, IF(op.PA=1,'Ya','Tidak') PEMERIKSAANPA
			, DATE_FORMAT(op.TANGGAL,'%d-%m-%Y') TGLOPERASI
			, DATE_FORMAT(op.DIBUAT_TANGGAL,'%d-%m-%Y') DBUATTANGGAL
			, pk.NOPEN, pk.MASUK TGLREG,  r.DESKRIPSI UNITPENGANTAR
			, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=3 AND jbr.ID=4) KODEMR1
			, op.*, rt.DESKRIPSI JNSTRANSFUSI
			, REPLACE(`master`.getReplaceFont(op.PRA_BEDAH),'<div>','<br><div>') PRA_BEDAH1
			, REPLACE(`master`.getReplaceFont(op.PASCA_BEDAH),'<div>','<br><div>') PASCA_BEDAH1
			, REPLACE(REPLACE(`master`.getReplaceFont(op.LAPORAN_OPERASI),'<div>','<br><div>'),'<p','<br><p') LAPORAN_OPERASI1
			, IF(op.JUMLAH_TRANSFUSI=0,'Tidak ada',CONCAT(REPLACE(ROUND(op.JUMLAH_TRANSFUSI,2),'.',','),' Mililiter')) JML_TRANSFUSI
		FROM medicalrecord.operasi op
			  LEFT JOIN master.dokter dok ON op.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
			  LEFT JOIN master.dokter_smf dsmf ON dok.ID=dsmf.DOKTER
			  LEFT JOIN master.referensi smf ON dsmf.SMF=smf.ID AND smf.JENIS=26
			  LEFT JOIN master.dokter anas ON op.ANASTESI=anas.ID
			  LEFT JOIN master.pegawai mpanas ON anas.NIP=mpanas.NIP
			  LEFT JOIN master.referensi ja ON op.JENIS_ANASTESI=ja.ID AND ja.JENIS=52
			  LEFT JOIN master.referensi gol ON op.GOLONGAN_OPERASI=gol.ID AND gol.JENIS=53
			  LEFT JOIN master.referensi jop ON op.JENIS_OPERASI=jop.ID AND jop.JENIS=87
			  LEFT JOIN master.referensi rt ON op.JENIS_TRANSFUSI=rt.ID AND rt.JENIS=213
			  LEFT JOIN medicalrecord.pelaksana_operasi po ON po.OPERASI_ID=op.ID AND po.JENIS=1 AND po.`STATUS`=1
		     LEFT JOIN master.pegawai pg ON po.PELAKSANA=pg.ID
		     LEFT JOIN master.referensi smf1 ON pg.SMF=smf1.ID AND smf1.JENIS=26
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN pendaftaran.konsul ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan rasal ON kj.RUANGAN=rasal.ID AND rasal.JENIS=5
			  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT mp.NAMA, ai.PPK  
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	WHERE pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND op.KUNJUNGAN=pk.NOMOR AND op.`STATUS` IN (1, 2)
		AND op.ID=PID
	GROUP BY op.ID;
END//
DELIMITER ;