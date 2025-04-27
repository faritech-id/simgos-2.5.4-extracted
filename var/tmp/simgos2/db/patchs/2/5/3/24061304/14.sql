USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakMR5
DROP PROCEDURE IF EXISTS `CetakMR5`;
DELIMITER //
CREATE PROCEDURE `CetakMR5`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
		SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, pp.NOMOR NOPEN
		     , master.getNamaLengkap(pp.NORM) NAMAPASIEN, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y'),' (',rjk.DESKRIPSI,')') TANGGAL_LAHIR
			  , DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TGLLHR, IF(wl.ID IS NULL,p.TEMPAT_LAHIR,wl.DESKRIPSI) TEMPATLHR, IF(p.JENIS_KELAMIN=1,'L','P') JENIS_KELAMIN
		     , pk.NOMOR KUNJUNGAN
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK
		     , (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=2) KODEMR1
		     , r.DESKRIPSI UNIT
		     , nu.BERAT_BADAN, nu.TINGGI_BADAN, nu.INDEX_MASSA_TUBUH, nu.LINGKAR_KEPALA
		     ,  sfu.TANPA_ALAT_BANTU, sfu.TONGKAT, sfu.KURSI_RODA, sfu.BRANKARD, sfu.WALKER
			  , sfu.CACAT_TUBUH_TIDAK, sfu.CACAT_TUBUH_YA, sfu.KET_CACAT_TUBUH, fu.ALAT_BANTU , fu.PROTHESA, fu.CACAT_TUBUH CACATTUBUH
			  , IF(pn.NYERI=1,'Ya','Tidak') NYERI
			  , IF(pn.ONSET=1,'Akut',IF(pn.ONSET=2,'Kronis','')) ONSET, pn.SKALA, mt.DESKRIPSI METODE, pn.PENCETUS, pn.GAMBARAN, pn.DURASI, pn.LOKASI
			  , rcnt.DESKRIPSI RNCTERAPI, anm.DESKRIPSI ANAMNESIS
			  , IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
				   FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
					FROM medicalrecord.keluhan_utama ku
					LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
					WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))) KELUHAN
			  , (SELECT tv.KEADAAN_UMUM
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) KEADAAN_UMUM
			  , (SELECT tv.FREKUENSI_NAFAS
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) FREKUENSI_NAFAS
			   , (SELECT tv.FREKUENSI_NADI
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1) FREKUENSI_NADI
			  , (SELECT tv.SUHU
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0 
						ORDER BY tv.TANGGAL DESC LIMIT 1) SUHU
			  , CONCAT((SELECT ROUND(tv.SISTOLIK,0)
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1),'/'
			  , (SELECT ROUND(tv.DISTOLIK,0)
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0
						ORDER BY tv.TANGGAL DESC LIMIT 1)) DARAH
			  , (SELECT DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%H:%i:%s')
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0 
						ORDER BY tv.TANGGAL DESC LIMIT 1) JAM
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
						FROM medicalrecord.tanda_vital tv
						LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
						LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
						LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP 
						WHERE pkrp.NOMOR=pk.NOMOR AND tv.`STATUS` !=0 AND pg.PROFESI !=4
						ORDER BY tv.TANGGAL DESC LIMIT 1) PERAWAT
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y') TGLPERIKSA ,DATE_FORMAT(pk.MASUK,'%H:%i:%s') JAMPERIKSA
			  , IF(master.getDiagnosaPasien(pp.NOMOR) IS NULL,dg.DIAGNOSIS,master.getDiagnosaPasien(pp.NOMOR)) DIAGNOSIS
			  , CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL
			  , IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))) RIWAYATPENYAKIT
			  , IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR  LIMIT 1))) RPS
			 , (SELECT REPLACE(REPLACE(REPLACE(REPLACE
					 (master.getReplaceFont((pf1.DESKRIPSI))
						,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pp.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1) FISIK
			  , (SELECT  REPLACE(GROUP_CONCAT(DISTINCT(ib.NAMA)),',','; ')
						FROM layanan.farmasi lf
							  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
							, pendaftaran.kunjungan pk
						     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
						     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
							  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
							  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
							  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
						     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
						   , pendaftaran.pendaftaran pp1
							  LEFT JOIN master.pasien ps ON pp1.NORM=ps.NORM
							, inventory.barang ib
							, pembayaran.rincian_tagihan rt
						WHERE  lf.`STATUS`!=0 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
							AND pk.NOPEN=pp1.NOMOR AND lf.FARMASI=ib.ID
							AND pp1.NORM=pp.NORM AND pp1.NOMOR!=pp.NOMOR
							AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') RIWAYATOBAT
				, (SELECT GROUP_CONCAT(CONCAT('=',ib.NAMA, '; ',ref.DESKRIPSI,'=')) 
					FROM layanan.farmasi lf
						  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
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
						, pembayaran.rincian_tagihan rt
					WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
						AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
						AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG!=1
						AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') OBATRJ
				, CONCAT('Anamnesis / Riwayat Penyakit Sekarang : ',IFNULL(anm.DESKRIPSI,''),'\r',
							'Keluhan Utama : ',IFNULL(IF(IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
							   FROM medicalrecord.keluhan_utama ku
								LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
								WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))='-','Tidak Ada',IFNULL(ku.DESKRIPSI, (SELECT ku.DESKRIPSI
								FROM medicalrecord.keluhan_utama ku
								LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
								WHERE pku.NOPEN=pp.NOMOR AND pku.REF IS NULL LIMIT 1))),''),'\r',
							'Riwayat Penyakit Terdahulu : ',IFNULL(rpp.DESKRIPSI,''),'\r',
							IFNULL((SELECT sub.SUBYEKTIF
							FROM medicalrecord.cppt sub
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=sub.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY sub.TANGGAL DESC LIMIT 1),'')) SUBYEKTIF
				, CONCAT('Pemeriksaan Umum : ','\r',
							'Keadaan Umum : ',IFNULL(tv.KEADAAN_UMUM,''),'; ','Kesadaran : ',IFNULL(tv.KESADARAN,''),'; ','Tekanan Darah : ',IFNULL(tv.SISTOLIK,''),'/',IFNULL(tv.DISTOLIK,''),
							'; ','Nadi : ',IFNULL(tv.FREKUENSI_NADI,''),'; ','Pernafasan : ',IFNULL(tv.FREKUENSI_NAFAS,''),'; ','Suhu Tubuh : ',IFNULL(tv.SUHU,''),'\r',
							IFNULL((SELECT 
								REPLACE(REPLACE(REPLACE(REPLACE
								 (master.getReplaceFont((pf1.DESKRIPSI))
									,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')
						   FROM medicalrecord.pemeriksaan_fisik pf1
							WHERE pf1.PENDAFTARAN=pp.NOMOR
							ORDER BY pf1.TANGGAL DESC LIMIT 1),''),'\r',
							IFNULL((SELECT oby.OBYEKTIF
							FROM medicalrecord.cppt oby
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=oby.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY oby.TANGGAL DESC LIMIT 1),'')) OBYEKTIF
				, CONCAT(IF(master.getDiagnosaPasien(pp.NOMOR) IS NULL,IFNULL(dg.DIAGNOSIS,''),master.getDiagnosaPasien(pp.NOMOR)),'\r',
							IFNULL((SELECT ass.ASSESMENT
							FROM medicalrecord.cppt ass
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY ass.TANGGAL DESC LIMIT 1),'')) ASSESMENT
				, CONCAT(IFNULL(rcnt.DESKRIPSI,''),'\r',
							IFNULL((SELECT pln.PLANNING
							FROM medicalrecord.cppt pln
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pln.KUNJUNGAN
							WHERE pkrp.NOMOR=pk.NOMOR 
							ORDER BY pln.TANGGAL DESC LIMIT 1),'')) PLANNING
				, (SELECT 
					REPLACE(REPLACE(REPLACE(REPLACE
								 (master.getReplaceFont((ins.INSTRUKSI))
									,'<p','<br><p'),'\n','<br/>'),'<div style="">','<br/>'),'<div>','<br/>')
					FROM medicalrecord.cppt ins
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR 
					ORDER BY ins.TANGGAL DESC LIMIT 1) INSTRUKSI
				, IF(master.getNamaLengkapPegawai(dpjp.NIP) IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(dpjp.NIP)) DOKTER
				, IF(dpjp.NIP IS NULL,drreg.NIP,dpjp.NIP) NIP
				, IF(master.getJawabanKonsul(pk.NOPEN) IS NULL, '',REPLACE(master.getJawabanKonsul(pk.NOPEN),'UICTFontTextStyleBody','Arial')) KONSUL
				, master.getTindakanKunjungan(pk.NOMOR) TINDAKAN
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.wilayah wl ON p.TEMPAT_LAHIR=wl.ID
				, pendaftaran.kunjungan pk
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
			  	  LEFT JOIN master.referensi smf ON ds.SMF=smf.ID AND smf.JENIS=26
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_fungsional sfu ON pk.NOMOR=sfu.KUNJUNGAN AND sfu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.anamnesis anm ON pk.NOMOR=anm.KUNJUNGAN AND anm.`STATUS`!=0
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN medicalrecord.rps rps ON pk.NOMOR=rps.KUNJUNGAN AND rps.`STATUS`!=0
				  LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP AND pg.PROFESI !=4
				, master.ruangan r
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pp.NORM=p.NORM AND pk.RUANGAN=r.ID
			  AND pk.NOPEN=PNOPEN AND pk.NOMOR=PKUNJUNGAN
			  GROUP BY pk.NOMOR;
END//
DELIMITER ;