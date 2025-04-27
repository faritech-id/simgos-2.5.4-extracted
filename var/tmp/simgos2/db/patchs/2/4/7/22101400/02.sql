-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakMR2
DROP PROCEDURE IF EXISTS `CetakMR2`;
DELIMITER //
CREATE PROCEDURE `CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN 	
	SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.KOTA KOTA, inst.ALAMAT ALAMATINST
		, inst.TELEPON TLP, inst.FAX, inst.EMAIL, inst.WEBSITE 
		, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM1
		, LPAD(p.NORM,8,'0') NORM
		, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR, p.ALAMAT PSALAMAT
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL, master.getCariUmur(pd.TANGGAL, p.TANGGAL_LAHIR) UMUR
		, rjk.DESKRIPSI JENISKELAMIN
		, rpd.DESKRIPSI PENDIDIKAN
		, rpk.DESKRIPSI PEKERJAAN, rsk.ID STATUSKAWIN
		, rag.DESKRIPSI AGAMA, kip.NOMOR KTP
		, pjp.NAMA NAMAPJ, pjp.ALAMAT ALAMATPJ, kpjp.NOMOR KONTAKPJ
		, (SELECT IF(r.JENIS_KUNJUNGAN=1,'Rawat Jalan','Rawat Darurat') 
					FROM pendaftaran.pendaftaran tpd
						, pendaftaran.tujuan_pasien tp
					   , master.ruangan r 
					WHERE tpd.NOMOR=tp.NOPEN AND tp.RUANGAN=r.ID AND r.JENIS=5 AND tpd.TANGGAL < pd.TANGGAL
							AND r.JENIS=5 AND r.JENIS_KUNJUNGAN IN (1,2) AND tpd.NORM=pd.NORM
					ORDER BY tpd.TANGGAL DESC
					LIMIT 1) CARAPENERIMAAN
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y') TGLREG, DATE_FORMAT(pd.TANGGAL,'%H:%i:%s') JAMREG
		, IF(r.JENIS_KUNJUNGAN=3,DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y'),IFNULL(DATE_FORMAT(pk.KELUAR,'%d-%m-%Y'),'Belum Final')) TGLKLR
		, IF(r.JENIS_KUNJUNGAN=3,DATE_FORMAT(pl.TANGGAL,'%H:%i:%s'),IFNULL(DATE_FORMAT(pk.KELUAR,'%H:%i:%s'),'')) JAMKLR
		, IF(pl.TANGGAL IS NULL,DATEDIFF(SYSDATE(),pd.TANGGAL),DATEDIFF(pl.TANGGAL,pd.TANGGAL)) LOS, IF(r.JENIS_KUNJUNGAN=3,DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y'),IFNULL(DATE_FORMAT(pk.KELUAR,'%d-%m-%Y'),'Belum Final')) TGLKELUAR
		, cr.ID IDCARAKELUAR, cr.DESKRIPSI CARAKELUAR, kd.ID IDKEADAANKELUAR, kd.DESKRIPSI KEADAANKELUAR, IF(pruj.NAMA IS NULL,'',pruj.NAMA) PPKRUJUK
		, pm.DIAGNOSA DIAGNOSAMENINGGAL
		, (master.getKodeDiagnosaMeninggal(PNOPEN)) KODESEBABMATI, (master.getDiagnosaMeninggal(PNOPEN)) SEBABMATI
		, ref.ID IDCARABAYAR, ref.DESKRIPSI CARABAYAR, kap.NOMOR NOKARTU,pj.NOMOR SEP
		, r.JENIS_KUNJUNGAN, IF(r.JENIS_KUNJUNGAN=1,r.DESKRIPSI,u.DESKRIPSI) UNITPELAYANAN, IF(rk.KAMAR IS NULL,'',rk.KAMAR) KAMAR, IF(rkt.TEMPAT_TIDUR IS NULL,'',rkt.TEMPAT_TIDUR) TEMPAT_TIDUR
		, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=3) KODEMR1
		, dms.DIAGNOSA DIAGNOSAMASUK, dms.ICD KODEDIAGNOSAMASUK
		, UPPER((master.getDiagnosa(PNOPEN,1))) DIAGNOSAUTAMA, (master.getKodeDiagnosa(PNOPEN,1)) KODEDIAGNOSAUTAMA
		, (master.getDiagnosa(PNOPEN,2)) DIAGNOSASEKUNDER, (master.getKodeDiagnosa(PNOPEN,2)) KODEDIAGNOSASEKUNDER
		, (master.getICD9CM(PNOPEN)) TINDAKAN, (master.getKodeICD9CM(PNOPEN)) KODETINDAKAN
		, master.getDokterTindakan(PNOPEN) DOKTERTINDAKAN
		, IF(pl.DOKTER IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(mpdokdpjp.NIP)) DPJP
		, IF(pl.DOKTER IS NULL,drreg.NIP,mpdokdpjp.NIP) NIP
		, (SELECT master.getNamaLengkapPegawai(mpdok.NIP) DOKTEROPERATOR
				FROM operasi o
				     LEFT JOIN master.dokter dok ON o.DOKTER=dok.ID
					  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					, pendaftaran.kunjungan pk
				WHERE o.`STATUS`=1 AND pk.NOMOR=o.KUNJUNGAN AND pk.`STATUS`!=0
					AND pk.NOPEN=PNOPEN
			    LIMIT 1) DOKTEROPERATOR
		, 0 TOTALBIAYA
		, (SELECT SUM(rt.JUMLAH)
					  FROM pembayaran.rincian_tagihan rt
					  , pembayaran.tagihan_pendaftaran tp
					  WHERE rt.TAGIHAN = tp.TAGIHAN
					   AND rt.JENIS = 2
						AND tp.PENDAFTARAN=PNOPEN) LOSTAGIHAN
			, IFNULL(an.DESKRIPSI,(SELECT a.DESKRIPSI FROM medicalrecord.anamnesis a WHERE a.PENDAFTARAN=pd.NOMOR LIMIT 1)) ANAMNESI
			, IFNULL(rp.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rpp rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR LIMIT 1)) RPP
			, CONCAT(IFNULL((SELECT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
				(pf1.DESKRIPSI,'font-family: &quot;Open Sans&quot;, &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif;','')
				,'Open Sans, Helvetica Neue, Helvetica, ','')
				,'face="open sans"','')
				,'style="font-family:','style="font-face:'),' style=""',''))
			   FROM medicalrecord.pemeriksaan_fisik pf1
				WHERE pf1.PENDAFTARAN=pd.NOMOR
				ORDER BY pf1.TANGGAL DESC LIMIT 1),''),'; ',' \r'
			, IFNULL(CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ','Kesadaran : ',tv.KESADARAN,'; ','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ','Nadi : ',tv.FREKUENSI_NADI,'; ','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ','Suhu Tubuh : ',tv.SUHU)
			, (SELECT CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ','Kesadaran : ',tv.KESADARAN,'; ','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ','Nadi : ',tv.FREKUENSI_NADI,'; ','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ','Suhu Tubuh : ',tv.SUHU)
				FROM medicalrecord.tanda_vital tv
				LEFT JOIN pendaftaran.kunjungan ptv ON ptv.NOMOR=tv.KUNJUNGAN
				WHERE ptv.NOPEN=pd.NOMOR 
				ORDER BY tv.WAKTU_PEMERIKSAAN DESC LIMIT 1))) FISIK
			, IFNULL((SELECT diag.DIAGNOSIS
				FROM medicalrecord.diagnosis diag
				LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=diag.KUNJUNGAN
				WHERE pku.NOPEN=pd.NOMOR AND pku.REF IS NULL LIMIT 1),'') DIAGNOSE
			, IFNULL((SELECT ku.DESKRIPSI
				FROM medicalrecord.keluhan_utama ku
				LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR=ku.KUNJUNGAN
				WHERE pku.NOPEN=pd.NOMOR AND pku.REF IS NULL LIMIT 1),'') KELUHANUTAMA
			, CONCAT((SELECT GROUP_CONCAT(rks.DESKRIPSI,' : ', IFNULL(diagks.DIAGNOSIS,''))
				FROM medicalrecord.diagnosis diagks
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=diagks.KUNJUNGAN
				LEFT JOIN pendaftaran.konsul kns ON pkrp.REF=kns.NOMOR
				LEFT JOIN master.ruangan rks ON kns.TUJUAN=rks.ID AND rks.JENIS=5
				WHERE pkrp.NOPEN=pd.NOMOR AND kns.NOMOR IS NOT NULL AND rks.JENIS_KUNJUNGAN=1),'; ',' \r','Tindakan : ', master.getTindakanKonsul(PNOPEN)) KONSUL
			,  master.getJawabanKonsul(PNOPEN) KONSULTASI
			, (SELECT sub.SUBYEKTIF
				FROM medicalrecord.cppt sub
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=sub.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND sub.JENIS = 1 AND sub.`STATUS`=1
				ORDER BY sub.TANGGAL DESC LIMIT 1) SUBYEKTIF
			, (SELECT oby.OBYEKTIF
				FROM medicalrecord.cppt oby
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=oby.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND oby.JENIS = 1 AND oby.`STATUS`=1
				ORDER BY oby.TANGGAL DESC LIMIT 1) OBYEKTIF
			, (SELECT ass.ASSESMENT
				FROM medicalrecord.cppt ass
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ass.JENIS = 1 AND ass.`STATUS`=1
				ORDER BY ass.TANGGAL DESC LIMIT 1) ASSESMENT
			, (SELECT pln.PLANNING
				FROM medicalrecord.cppt pln
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pln.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND pln.JENIS = 1 AND pln.`STATUS`=1
				ORDER BY pln.TANGGAL DESC LIMIT 1) PLANNING
			, (SELECT ins.INSTRUKSI
				FROM medicalrecord.cppt ins
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ins.JENIS = 1 AND ins.`STATUS`=1
				ORDER BY ins.TANGGAL DESC LIMIT 1) INSTRUKSI
			,  (SELECT CONCAT (
	 		  'Subyektif : ',
	 			(SELECT sub.SUBYEKTIF
				FROM medicalrecord.cppt sub
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=sub.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND sub.JENIS = 1 AND sub.`STATUS`=1
				ORDER BY sub.TANGGAL DESC LIMIT 1),
		     ' \r','Obyektif : ',
			  (SELECT oby.OBYEKTIF
				FROM medicalrecord.cppt oby
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=oby.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND oby.JENIS = 1 AND oby.`STATUS`=1
				ORDER BY oby.TANGGAL DESC LIMIT 1),
			  ' \r','Assesment : ',
			  (SELECT ass.ASSESMENT
				FROM medicalrecord.cppt ass
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ass.JENIS = 1 AND ass.`STATUS`=1
				ORDER BY ass.TANGGAL DESC LIMIT 1),
			 ' \r','Planning : ',
			  (SELECT pln.PLANNING
				FROM medicalrecord.cppt pln
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pln.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND pln.JENIS = 1 AND pln.`STATUS`=1
				ORDER BY pln.TANGGAL DESC LIMIT 1),
			  ' \r','Instruksi : ',
			  (SELECT ins.INSTRUKSI
				FROM medicalrecord.cppt ins
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
				WHERE pkrp.NOPEN=pd.NOMOR AND ins.JENIS = 1 AND ins.`STATUS`=1
				ORDER BY ins.TANGGAL DESC LIMIT 1))) CPPT
			, (SELECT GROUP_CONCAT(DISTINCT(ib.NAMA)) 
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
						AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') OBATRS
			, (SELECT GROUP_CONCAT(CONCAT('=',ib.NAMA, '; ',master.getAturanPakai(lf.ATURAN_PAKAI),'=')) 
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
	   , (SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) 
				FROM layanan.hasil_lab hlab,
					  layanan.tindakan_medis tm,
					  master.parameter_tindakan_lab ptl
					  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
					  master.tindakan mt
					  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN
					  LEFT JOIN master.group_lab kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.ID
					  LEFT JOIN master.group_lab ggl ON gtl.GROUP_LAB=ggl.ID,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
					  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN,
					  pendaftaran.kunjungan pk 
					  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
					  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
					  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
					  
				WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
						AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`!=0
						AND tpp.TAGIHAN=tpdf.TAGIHAN
						AND (hlab.HASIL!='' AND hlab.HASIL IS NOT NULL)
						AND pp.`STATUS`!=0 AND pk.`STATUS`!=0 AND r.JENIS_KUNJUNGAN=4
				ORDER BY hlab.ID) LAB
		, (SELECT GROUP_CONCAT(t.NAMA,' = ',hrad.HASIL)
					FROM layanan.hasil_rad hrad
						, layanan.tindakan_medis tm
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						, pendaftaran.pendaftaran pp
						  LEFT JOIN pembayaran.tagihan_pendaftaran tpp ON pp.NOMOR=tpp.PENDAFTARAN
						, pendaftaran.kunjungan pk 
				WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR 
					AND hrad.TINDAKAN_MEDIS=tm.ID
					AND tpp.TAGIHAN=tpdf.TAGIHAN
					AND hrad.`STATUS`!=0 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
				) RAD
		, IFNULL(CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ',' \r','Kesadaran : ',tv.KESADARAN,'; ',' \r','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ',' \r','Nadi : ',tv.FREKUENSI_NADI,'; ',' \r','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ',' \r','Suhu Tubuh : ',tv.SUHU,'; ',' \r','Waktu Pemeriksaan : ',tv.WAKTU_PEMERIKSAAN)
			, (SELECT CONCAT('Keadaan Umum : ',tv.KEADAAN_UMUM,'; ',' \r','Kesadaran : ',tv.KESADARAN,'; ',' \r','Tekanan Darah : ',tv.SISTOLIK,'/',tv.DISTOLIK,'; ',' \r','Nadi : ',tv.FREKUENSI_NADI,'; ',' \r','Pernafasan : ',tv.FREKUENSI_NAFAS,'; ',' \r','Suhu Tubuh : ',tv.SUHU,'; ',' \r','Waktu Pemeriksaan : ',tv.WAKTU_PEMERIKSAAN)
				FROM medicalrecord.tanda_vital tv
				LEFT JOIN pendaftaran.kunjungan ptv ON ptv.NOMOR=tv.KUNJUNGAN
				WHERE ptv.NOPEN=pd.NOMOR 
				ORDER BY tv.WAKTU_PEMERIKSAAN DESC LIMIT 1)) TVPULANG
		, IF(ee.EDUKASI IS NULL,'',ee.EDUKASI) EDUKASI, IF(ee.KEMBALI_KE_UGD IS NULL,'',ee.KEMBALI_KE_UGD) KEMBALI_KE_UGD
		, IF(jkt.TANGGAL IS NULL,'',DATE_FORMAT(jkt.TANGGAL,'%d-%m-%Y')) TGLKTRL, IF(jkt.JAM IS NULL,'',jkt.JAM) JAMKTRL, IF(jkt.DESKRIPSI IS NULL,'',jkt.DESKRIPSI) KETKTRL
		, layanan.getResepPulang(PNOPEN) RESEPPULANG
  FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		  LEFT JOIN master.kartu_identitas_pasien kip ON p.NORM=kip.NORM AND kip.JENIS=1
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN AND pl.`STATUS`=1
		  LEFT JOIN layanan.pasien_meninggal pm ON pm.KUNJUNGAN=pl.KUNJUNGAN AND pl.`STATUS`=1
		  LEFT JOIN master.dokter dokdpjp ON pl.DOKTER=dokdpjp.ID
		  LEFT JOIN master.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
	 	  LEFT JOIN master.referensi cr ON pl.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON pl.KEADAAN=kd.ID AND kd.JENIS=46
		  LEFT JOIN pendaftaran.kunjungan pk ON pl.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
		  LEFT JOIN master.ruangan u ON pk.RUANGAN=u.ID AND u.JENIS=5		  
		  LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID=pk.RUANG_KAMAR_TIDUR
		  LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR=rk.ID
		  LEFT JOIN medicalrecord.anamnesis an ON pd.NOMOR=an.PENDAFTARAN AND an.`STATUS`=1
		  LEFT JOIN medicalrecord.rpp rp ON rp.KUNJUNGAN = an.KUNJUNGAN
		  LEFT JOIN medicalrecord.pemeriksaan_fisik pf ON pd.NOMOR=pf.PENDAFTARAN AND pf.`STATUS`=1
		  LEFT JOIN medicalrecord.diagnosis diag ON pk.NOMOR=diag.KUNJUNGAN
		  LEFT JOIN medicalrecord.keluhan_utama klu ON pk.NOMOR=klu.KUNJUNGAN
		  LEFT JOIN medicalrecord.edukasi_emergency ee ON pk.NOMOR=ee.KUNJUNGAN
		  LEFT JOIN medicalrecord.rencana_terapi rct ON pk.NOMOR=rct.KUNJUNGAN
		  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN
		  LEFT JOIN medicalrecord.jadwal_kontrol jkt ON pk.NOMOR=jkt.KUNJUNGAN AND jkt.`STATUS`=1
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pd.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
		  LEFT JOIN pendaftaran.penanggung_jawab_pasien pjp ON pd.NOMOR=pjp.NOPEN
		  LEFT JOIN pendaftaran.kontak_penanggung_jawab kpjp ON pjp.ID=kpjp.ID
		  LEFT JOIN master.diagnosa_masuk dms ON pd.DIAGNOSA_MASUK=dms.ID
		  LEFT JOIN pendaftaran.rujukan_keluar ruj ON pd.NOMOR=ruj.NOPEN
		  LEFT JOIN master.ppk pruj ON ruj.TUJUAN=pruj.ID
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN master.dokter drreg ON tp.DOKTER=drreg.ID
		, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT , mp.TELEPON, mp.FAX
					, ai.EMAIL, ai.WEBSITE
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=PNOPEN
	GROUP BY pd.NOMOR;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
