-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakMR4RDRI
DROP PROCEDURE IF EXISTS `CetakMR4RDRI`;
DELIMITER //
CREATE PROCEDURE `CetakMR4RDRI`(
	IN `PNOPEN` CHAR(10)
)
SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(pp.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, pp.NOMOR NOPEN
		     , master.getNamaLengkap(pp.NORM) NAMAPASIEN, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR , rjk.DESKRIPSI JENISKELAMIN, ROUND(DATEDIFF(pp.TANGGAL,p.TANGGAL_LAHIR)/365) USIATAHUN
		     , pk.NOMOR KUNJUNGAN, p.ALAMAT ALAMATPASIEN, ref.DESKRIPSI CARABAYAR, rsk.DESKRIPSI STATUSKAWIN 
		     , DATE_FORMAT(pk.MASUK,'%d-%m-%Y %H:%i:%s') TGLMASUK, rpd.DESKRIPSI PENDIDIKAN, rag.DESKRIPSI AGAMA_DESKRIPSI, p.AGAMA IDAGAMA, p.PEKERJAAN IDPEKERJAAN
		     , r.DESKRIPSI UNIT
			  , (SELECT an.DESKRIPSI 
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) ANAMNESIS
			  , (SELECT an.OLEH 
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) IDDOKTERKAJI
			  , (SELECT master.getNamaLengkapPegawai(md.NIP) 
							FROM medicalrecord.anamnesis an
							LEFT JOIN aplikasi.pengguna pan ON an.OLEH=pan.ID
							LEFT JOIN master.dokter md ON pan.NIP=md.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) DOKTERKAJI
			  , (SELECT DATE_FORMAT(an.TANGGAL,'%d-%m-%Y %H:%i:%s')  
							FROM medicalrecord.anamnesis an
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=an.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND an.`STATUS` !=0
							ORDER BY an.TANGGAL ASC LIMIT 1) TGLKAJI 
			  , (SELECT anm.AUTOANAMNESIS
							FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) AUTOANAMNESIS
			  , (SELECT anm.ALLOANAMNESIS 
			  				FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) ALLOANAMNESIS
			  , (SELECT anm.DARI
			  				FROM medicalrecord.anamnesis_diperoleh anm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=anm.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND anm.`STATUS` !=0
							ORDER BY anm.TANGGAL ASC LIMIT 1) DIPEROLEH_SECARA
		     , (SELECT fr.HIPERTENSI 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_HIPERTENSI
			  , (SELECT fr.DIABETES_MELITUS 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_DIABETES_MELITUS
			  , (SELECT fr.PENYAKIT_JANTUNG 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_PENYAKIT_JANTUNG
			  , (SELECT fr.ASMA 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ASMA
			  , (SELECT fr.STROKE 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_STROKE
			  , (SELECT fr.LIVER 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_LIVER
			  , (SELECT fr.GINJAL 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_GINJAL
			  , (SELECT fr.TUBERCULOSIS_PARU 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_TB_PARU
			  , (SELECT fr.ROKOK 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ROKOK
			  , (SELECT fr.MINUM_ALKOHOL 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_ALKOHOL
			  , (SELECT fr.PENYAKIT_LAIN 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) FR_LAINNYA
			  , (SELECT fr.PERNAH_DIRAWAT_TIDAK AND fr.`STATUS` !=0
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_TIDAK
			  , (SELECT fr.PERNAH_DIRAWAT_YA
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_YA
			  , (SELECT DATE_FORMAT(fr.PERNAH_DIRAWAT_KAPAN,'%d-%m-%Y') 
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_KAPAN
		     , (SELECT fr.PERNAH_DIRAWAT_DIMANA
			  				FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_DIMANA
			  , (SELECT fr.PERNAH_DIRAWAT_DIAGNOSIS
							FROM medicalrecord.faktor_risiko fr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fr.`STATUS` !=0
							ORDER BY fr.TANGGAL ASC LIMIT 1) PERNAH_DIRAWAT_DIAGNOSIS
		     , (SELECT rpk.HIPERTENSI
		     				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_HIPERTENSI
			  , (SELECT rpk.DIABETES_MELITUS
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_DIABETES_MELITUS
			  , (SELECT rpk.PENYAKIT_JANTUNG
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_PENYAKIT_JANTUNG
			  , (SELECT rpk.ASMA
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_ASMA
			  , (SELECT rpk.LAINNYA
			  				FROM medicalrecord.riwayat_penyakit_keluarga rpk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rpk.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND rpk.`STATUS` !=0
							ORDER BY rpk.TANGGAL ASC LIMIT 1) RPK_LAINNYA
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
						   FROM medicalrecord.penilaian_fisik pf1
						   LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pf1.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pf1.`STATUS` !=0
							ORDER BY pf1.TANGGAL ASC LIMIT 1) NILAIFISIK
			  , (SELECT REPLACE(REPLACE(pf1.DESKRIPSI,'<div','<br><div'),'<p','<br><p')
						   FROM medicalrecord.pemeriksaan_fisik pf1
						   LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pf1.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pf1.`STATUS` !=0
							ORDER BY pf1.TANGGAL ASC LIMIT 1) FISIK
		     , (SELECT ku.DESKRIPSI
						   FROM medicalrecord.keluhan_utama ku
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ku.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND ku.`STATUS` !=0
							ORDER BY ku.TANGGAL ASC LIMIT 1) KELUHAN			 	
		     , (SELECT tv.KEADAAN_UMUM
		     				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) KEADAAN_UMUM
			  , (SELECT tv.KESADARAN
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) KESADARAN
			  , (SELECT rtv.DESKRIPSI
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							LEFT JOIN `master`.referensi rtv ON tv.TINGKAT_KESADARAN=rtv.ID AND rtv.JENIS=179
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TINGKAT_KESADARAN
			  , (SELECT CONCAT(tv.SISTOLIK,'/', tv.DISTOLIK, ' mmHg') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) DARAH
			  , (SELECT CONCAT(tv.FREKUENSI_NADI, ' X/Menit') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) FREKUENSI_NADI
			  , (SELECT CONCAT(tv.FREKUENSI_NAFAS, ' X/Menit')
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) FREKUENSI_NAFAS
			  , (SELECT CONCAT(tv.SUHU, ' Â°C') 
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) SUHU
			  , (SELECT tv.EYE
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_EYE
			  , (SELECT tv.MOTORIK
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_MOTORIK
			  , (SELECT tv.VERBAL
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_VERBAL
			  , (SELECT tv.GCS
			  				FROM medicalrecord.tanda_vital tv
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TV_GCS
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
			  				FROM medicalrecord.tanda_vital tv
			  				LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  			LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) PERAWAT
			  , (SELECT DATE_FORMAT(tv.WAKTU_PEMERIKSAAN,'%d-%m-%Y %H:%i:%s')
			  				FROM medicalrecord.tanda_vital tv		  				
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tv.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND tv.`STATUS` !=0
							ORDER BY tv.TANGGAL ASC LIMIT 1) TGLASUHAN
			  , (SELECT pmt.ANEMIS
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_ANEMIS
			  , (SELECT pmt.IKTERUS
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_IKTERUS
			  , (SELECT pmt.PUPIL_ISOKOR
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_PUPIL_ISOKOR
			  , (SELECT pmt.PUPIL_ANISOKOR
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_PUPIL_ANISOKOR
			  , (SELECT pmt.DIAMETER_ISIAN
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DIAMETER_ISIAN
			  , (SELECT pmt.DIAMETER_MM
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DIAMETER_MM
			  , (SELECT pmt.UDEM
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_UDEM
			  , (SELECT rmt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							LEFT JOIN `master`.referensi rmt ON pmt.ADA_KELAINAN=rmt.ID AND rmt.JENIS=178
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_KELAINAN_MATA
			  , (SELECT pmt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_mata pmt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pmt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pmt.`STATUS` !=0
							ORDER BY pmt.TANGGAL ASC LIMIT 1) PMT_DESK_MATA
			  , (SELECT pts.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_tonsil pts
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pts.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pts.`STATUS` !=0
							ORDER BY pts.TANGGAL ASC LIMIT 1) PTS_KELAINAN_TONSIL
			  , (SELECT pts.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_tonsil pts
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pts.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pts.`STATUS` !=0
							ORDER BY pts.TANGGAL ASC LIMIT 1) PTS_DESK_TONSIL
			  , (SELECT pfr.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_faring pfr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pfr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pfr.`STATUS` !=0
							ORDER BY pfr.TANGGAL ASC LIMIT 1) PFR_KELAINAN_FARING
			  , (SELECT pfr.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_faring pfr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pfr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pfr.`STATUS` !=0
							ORDER BY pfr.TANGGAL ASC LIMIT 1) PFR_DESK_FARING
			  , (SELECT pld.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_lidah pld
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pld.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pld.`STATUS` !=0
							ORDER BY pld.TANGGAL ASC LIMIT 1) PLD_KELAINAN_LIDAH
			  , (SELECT pld.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_lidah pld
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pld.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pld.`STATUS` !=0
							ORDER BY pld.TANGGAL ASC LIMIT 1) PLD_DESK_LIDAH
			  , (SELECT pbr.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_bibir pbr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pbr.`STATUS` !=0
							ORDER BY pbr.TANGGAL ASC LIMIT 1) PBR_KELAINAN_BIBIR
			  , (SELECT pbr.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_bibir pbr
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbr.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pbr.`STATUS` !=0
							ORDER BY pbr.TANGGAL ASC LIMIT 1) PBR_DESK_BIBIR
			  , (SELECT plh.JVP 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_JVP
			  , (SELECT plh.PKL 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_PKL
			  , (SELECT plh.PKL_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_PKL_DESKRIPSI
			  , (SELECT plh.KAKUDUK 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KAKUDUK
			  , (SELECT plh.KAKUDUK_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KAKUDUK_DESKRIPSI
			  , (SELECT plh.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_KELAINAN_LEHER
			  , (SELECT plh.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_leher plh
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=plh.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND plh.`STATUS` !=0
							ORDER BY plh.TANGGAL ASC LIMIT 1) PLH_DESK_LEHER
			  , (SELECT pdd.THORAKS_SIMETRIS 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_SIMETRIS
			  , (SELECT pdd.THORAKS_ASIMETRIS
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_ASIMETRIS
			  , (SELECT pdd.THORAKS_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_THORAKS_DESKRIPSI
			  , (SELECT pdd.COR 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_COR
			  , (SELECT pdd.REGULER 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_REGULER
			  , (SELECT pdd.IREGULER 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_IREGULER
			  , (SELECT pdd.MURMUR 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_MURMUR
			  , (SELECT pdd.LAIN_LAIN 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_LAINLAIN
			  , (SELECT pdd.PULMO_SUARA_NAFAS 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_PULMO_SUARA_NAFAS
			  , (SELECT pdd.RONCHI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_RONCHI
			  , (SELECT pdd.RONCHI_DEKSRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_RONCHI_DESKRIPSI
			  , (SELECT pdd.WHEEZING 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_WHEEZING
			  , (SELECT pdd.WHEEZING_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_WHEEZING_DESKRIPSI
			  , (SELECT pdd.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_KELAINAN_PDD
			  , (SELECT pdd.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_dada pdd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdd.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND pdd.`STATUS` !=0
							ORDER BY pdd.TANGGAL ASC LIMIT 1) PDD_DESK_PDD
			  , (SELECT prt.ABDOMEN_DISTENDED 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ABDOMEN_DISTENDED
			  , (SELECT prt.ABDOMEN_METEORISMUS 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ABDOMEN_METEORISMUS
			  , (SELECT prt.PERISTALTIK_NORMAL 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_NORMAL
			  , (SELECT prt.PERISTALTIK_MENINGKAT 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_MENINGKAT
			  , (SELECT prt.PERISTALTIK_MENURUN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_MENURUN
			  , (SELECT prt.PERISTALTIK_TIDAK_ADA 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_PERISTALTIK_TIDAK_ADA
			  , (SELECT prt.ASITES 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_ASITES
			  , (SELECT prt.NYERI_TEKAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_NYERI_TEKAN
			  , (SELECT prt.NYERI_TEKAN_LOKASI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_NYERI_TEKAN_LOKASI
			  , (SELECT prt.HEPAR 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_HEPAR
			  , (SELECT prt.LIEN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_LIEN
			  , (SELECT prt.EXTREMITAS_HANGAT 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_EXTREMITAS_HANGAT
			  , (SELECT prt.EXTREMITAS_DINGIN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_EXTREMITAS_DINGIN
			  , (SELECT prt.UDEM 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM
			  , (SELECT prt.UDEM_DEKSRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM_DEKSRIPSI
			  , (SELECT prt.LAIN_LAIN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_UDEM_LAINLAIN
			  , (SELECT prt.DEFEKASI_ANUS 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS 
			  , (SELECT prt.DEFEKASI_ANUS_FREKUENSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS_FREKUENSI
			  , (SELECT prt.DEFEKASI_ANUS_KONSISTENSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_ANUS_KONSISTENSI
			  , (SELECT prt.DEFEKASI_STOMA 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_STOMA
			  , (SELECT prt.DEFEKASI_STOMA_DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DEFEKASI_STOMA_DESKRIPSI
			  , (SELECT prt.URIN_SPONTAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_SPONTAN
			  , (SELECT prt.URIN_KATETER 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_KATETER
			  , (SELECT prt.URIN_CYTOSTOMY 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_URIN_CYTOSTOMY
			  , (SELECT prt.ADA_KELAINAN 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_KELAINAN_PERUT
			  , (SELECT prt.DESKRIPSI 
			  				FROM medicalrecord.pemeriksaan_perut prt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=prt.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND prt.`STATUS` !=0
							ORDER BY prt.TANGGAL ASC LIMIT 1) PRT_DESK_PERUT
			  , (SELECT kss.TIDAK_ADA_KELAINAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TDK_ADA_KELAINAN
			  , (SELECT kss.MARAH 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_MARAH
			  , (SELECT kss.CEMAS 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_CEMAS
			  , (SELECT kss.TAKUT 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TAKUT
			  , (SELECT kss.BUNUH_DIRI 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_BUNUH_DIRI
			  , (SELECT kss.SEDIH 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_SEDIH
			  , (SELECT kss.LAINNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_LAINNYA
			  , (SELECT kss.STATUS_MENTAL 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_STATUS_MENTAL
			  , (SELECT kss.MASALAH_PERILAKU 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_MASALAH_PERILAKU
			  , (SELECT kss.PERILAKU_KEKERASAN_DIALAMI_SEBELUMNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PERILAKU_KEKERASAN_DIALAMI_SEBELUMNYA
			  , (SELECT kss.HUBUNGAN_PASIEN_DENGAN_KELUARGA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_HUBUNGAN_PASIEN_DENGAN_KELUARGA
			  , (SELECT kss.TEMPAT_TINGGAL 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TEMPAT_TINGGAL
			  , (SELECT kss.TEMPAT_TINGGAL_LAINNYA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_TEMPAT_TINGGAL_LAINNYA
			  , (SELECT kss.KEBIASAAN_BERIBADAH_TERATUR 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_KEBIASAAN_BERIBADAH_TERATUR
			  , (SELECT kss.NILAI_KEPERCAYAAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_NILAI_KEPERCAYAAN
			  , (SELECT kss.NILAI_KEPERCAYAAN_DESKRIPSI 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_NILAI_KEPERCAYAAN_DESKRIPSI
			  , (SELECT kss.PENGAMBIL_KEPUTUSAN_DALAM_KELUARGA 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PENGAMBIL_KEPUTUSAN_DALAM_KELUARGA
			  , (SELECT kss.PENGHASILAN_PERBULAN 
			  				FROM medicalrecord.kondisi_sosial kss
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=kss.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND kss.`STATUS` !=0
							ORDER BY kss.TANGGAL ASC LIMIT 1) KSS_PENGHASILAN_PERBULAN
			  , (SELECT dpf.PASIEN_TINGGAL_SENDIRI 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_TINGGAL_SENDIRI
			  , (SELECT dpf.PASIEN_KHAWATIR_KETIKA_DIRUMAH 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_KHAWATIR_KETIKA_DIRUMAH
			  , (SELECT dpf.PASIEN_TAK_ADA_YANG_MERAWAT 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_TAK_ADA_YANG_MERAWAT
			  , (SELECT dpf.PASIEN_DILANTAI_ATAS 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PASIEN_DILANTAI_ATAS
			  , (SELECT dpf.PERAWATAN_LANJUTAN_PASIEN 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PERAWATAN_LANJUTAN_PASIEN
			  , (SELECT dpf.PENGAJUAN_PENDAMPINGAN_PASIEN 
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_PENGAJUAN_PENDAMPINGAN_PASIEN
			  , (SELECT dpf.REASSESSMENT
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_REASSESSMENT
			  , (SELECT DATE_FORMAT(dpf.TANGGAL_REASSESSMENT,'%d-%m-%Y')
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_TANGGAL_REASSESSMENT
			  , (SELECT DATE_FORMAT(dpf.TANGGAL_REASSESSMENT,'%H:%i:%s')
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_JAM_REASSESSMENT			  
			  , (SELECT dpf.USER
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_USER
			  , (SELECT master.getNamaLengkapPegawai(pg.NIP)
			  				FROM medicalrecord.discharge_planning_faktor_risiko dpf
			  				LEFT JOIN aplikasi.pengguna us ON dpf.USER_REASSESSMENT=us.ID
				  			LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dpf.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dpf.`STATUS` !=0
							ORDER BY dpf.TANGGAL ASC LIMIT 1) DPF_USER_REASSESSMENT	
			  , (SELECT dps.KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB
			  , (SELECT dps.KPB_RAWAT_LUKA
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_RAWAT_LUKA
			  , (SELECT dps.KPB_HIV
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_HIV
			  , (SELECT dps.KPB_TB
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_TB
			  , (SELECT dps.KPB_DM
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_DM
			  , (SELECT dps.KPB_DM_TERAPI_INSULIN
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_DM_TERAPI_INSULIN
			  , (SELECT dps.KPB_STROKE
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_STROKE
			  , (SELECT dps.KPB_PPOK
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_PPOK
			  , (SELECT dps.KPB_CKD
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_CKD
			  , (SELECT dps.KPB_PASIEN_KEMO
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_KPB_PASIEN_KEMO
			  , (SELECT dps.PENGGUNAAN_ALAT_MEDIS_PAM
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PENGGUNAAN_ALAT_MEDIS_PAM
			  , (SELECT dps.PAM_KATETER_URIN
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_KATETER_URIN
			  , (SELECT dps.PAM_NGT
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_NGT
			  , (SELECT dps.PAM_TRAECHOSTOMY
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_TRAECHOSTOMY
			  , (SELECT dps.PAM_COLOSTOMY
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_COLOSTOMY
			  , (SELECT dps.PAM_LAINNYA
			  				FROM medicalrecord.discharge_planning_skrining dps
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=dps.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND dps.`STATUS` !=0
							ORDER BY dps.TANGGAL ASC LIMIT 1) DPS_PAM_LAINNYA	
		     , (SELECT nu.BERAT_BADAN 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_BERAT_BADAN
			  , (SELECT nu.TINGGI_BADAN 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_TINGGI_BADAN
			  , (SELECT nu.INDEX_MASSA_TUBUH 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_INDEX_MASSA
			  , (SELECT nu.LINGKAR_KEPALA 
			  				FROM medicalrecord.nutrisi nu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=nu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND nu.`STATUS` !=0
							ORDER BY nu.TANGGAL ASC LIMIT 1) NU_LINGKAR_KEPALA
		     , (SELECT fu.ALAT_BANTU
		     				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_ALAT_BANTU
			  , (SELECT fu.PROTHESA
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_PROTHESA
			  , (SELECT fu.CACAT_TUBUH
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_CACAT_TUBUH
			  , (SELECT DATE_FORMAT(fu.TANGGAL,'%H:%i:%s')
			  				FROM medicalrecord.fungsional fu
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=fu.KUNJUNGAN
							WHERE pkrp.NOPEN=pp.NOMOR AND fu.`STATUS` !=0
							ORDER BY fu.TANGGAL ASC LIMIT 1) FU_JAM			
		     , (SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0))
							FROM medicalrecord.penilaian_dekubitus pdek
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pdek.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pdek.KONDISI_FISIK=krd.ID AND krd.JENIS=181
							LEFT JOIN master.referensi krk ON pdek.KESADARAN=krk.ID AND krk.JENIS=182
							LEFT JOIN master.referensi bd ON pdek.AKTIVITAS=bd.ID AND bd.JENIS=183
							LEFT JOIN master.referensi pjn ON pdek.MOBILITAS=pjn.ID AND pjn.JENIS=184
							LEFT JOIN master.referensi mk ON pdek.INKONTINENSIA=mk.ID AND mk.JENIS=185
							WHERE pkrp.NOPEN=pp.NOMOR AND pdek.`STATUS` !=0
							ORDER BY pdek.TANGGAL ASC LIMIT 1) NILAIDEKUBITUS
		     , (SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+
			  					IFNULL(ps.SCORING,0)+IFNULL(pjl.SCORING,0)+IFNULL(pb.SCORING,0)+IFNULL(ntt.SCORING,0)+IFNULL(mn.SCORING,0))
							FROM medicalrecord.penilaian_barthel_index pbi
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pbi.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pbi.KENDALI_RANGSANG_DEFEKASI=krd.ID AND krd.JENIS=232
							LEFT JOIN master.referensi krk ON pbi.KENDALI_RANGSANG_KEMIH=krk.ID AND krk.JENIS=233
							LEFT JOIN master.referensi bd ON pbi.BERSIH_DIRI=bd.ID AND bd.JENIS=234
							LEFT JOIN master.referensi pjn ON pbi.PENGGUNAAN_JAMBAN=pjn.ID AND pjn.JENIS=235
							LEFT JOIN master.referensi mk ON pbi.MAKAN=mk.ID AND mk.JENIS=236
							LEFT JOIN master.referensi ps ON pbi.PERUBAHAN_SIKAP=ps.ID AND ps.JENIS=237
							LEFT JOIN master.referensi pjl ON pbi.PINDAH_JALAN=pjl.ID AND pjl.JENIS=238
							LEFT JOIN master.referensi pb ON pbi.PAKAI_BAJU=pb.ID AND pb.JENIS=239
							LEFT JOIN master.referensi ntt ON pbi.NAIK_TURUN_TANGGA=ntt.ID AND ntt.JENIS=240
							LEFT JOIN master.referensi mn ON pbi.MANDI=mn.ID AND mn.JENIS=241
							WHERE pkrp.NOPEN=pp.NOMOR AND pbi.`STATUS` !=0
							ORDER BY pbi.TANGGAL ASC LIMIT 1) SKORBARTHELINDEX
				, @SKORMORSE:=(SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+IFNULL(ps.SCORING,0))
							FROM medicalrecord.penilaian_skala_morse psm
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=psm.KUNJUNGAN
							LEFT JOIN master.referensi krd ON psm.RIWAYAT_JATUH=krd.ID AND krd.JENIS=186
							LEFT JOIN master.referensi krk ON psm.DIAGNOSIS=krk.ID AND krk.JENIS=187
							LEFT JOIN master.referensi bd ON psm.ALAT_BANTU=bd.ID AND bd.JENIS=188
							LEFT JOIN master.referensi pjn ON psm.HEPARIN=pjn.ID AND pjn.JENIS=189
							LEFT JOIN master.referensi mk ON psm.GAYA_BERJALAN=mk.ID AND mk.JENIS=190
							LEFT JOIN master.referensi ps ON psm.KESADARAN=ps.ID AND ps.JENIS=191
							WHERE pkrp.NOPEN=pp.NOMOR AND psm.`STATUS` !=0
							ORDER BY psm.TANGGAL ASC LIMIT 1) SKORMORSE
			  , @SKORHUMPTYDUMPTY:=(SELECT (IFNULL(krd.SCORING,0)+IFNULL(krk.SCORING,0)+IFNULL(bd.SCORING,0)+IFNULL(pjn.SCORING,0)+IFNULL(mk.SCORING,0)+IFNULL(ps.SCORING,0)+IFNULL(pjl.SCORING,0))
							FROM medicalrecord.penilaian_skala_humpty_dumpty pshd
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pshd.KUNJUNGAN
							LEFT JOIN master.referensi krd ON pshd.UMUR=krd.ID AND krd.JENIS=192
							LEFT JOIN master.referensi krk ON pshd.JENIS_KELAMIN=krk.ID AND krk.JENIS=193
							LEFT JOIN master.referensi bd ON pshd.DIAGNOSA=bd.ID AND bd.JENIS=194
							LEFT JOIN master.referensi pjn ON pshd.GANGGUAN_KONGNITIF=pjn.ID AND pjn.JENIS=195
							LEFT JOIN master.referensi mk ON pshd.FAKTOR_LINGKUNGAN=mk.ID AND mk.JENIS=196
							LEFT JOIN master.referensi ps ON pshd.RESPON=ps.ID AND ps.JENIS=197
							LEFT JOIN master.referensi pjl ON pshd.PENGGUNAAN_OBAT=pjl.ID AND pjl.JENIS=198
							WHERE pkrp.NOPEN=pp.NOMOR AND pshd.`STATUS` !=0
							ORDER BY pshd.TANGGAL ASC LIMIT 1) SKORHUMPTYDUMPTY
			  , @MORSE_TIDAK_ADA:=IF(@SKORMORSE = 0, 1,0) MORSE_TIDAK_ADA
			  , @MORSE_RENDAH:=IF(@SKORMORSE BETWEEN 1 AND 24, 1,0) MORSE_RENDAH
			  , @MORSE_SEDANG:=IF(@SKORMORSE BETWEEN 25 AND 44, 1,0) MORSE_SEDANG
			  , @MORSE_TINGGI:=IF(@SKORMORSE >= 45, 1,0) MORSE_TINGGI
			  , @HUMPTY_TIDAK_ADA:=IF(@SKORHUMPTYDUMPTY < 7 , 1,0) HUMPTY_TIDAK_ADA
			  , @HUMPTY_RENDAH:=IF(@SKORHUMPTYDUMPTY BETWEEN 7 AND 11, 1,0) HUMPTY_RENDAH
			  , @HUMPTY_TINGGI:=IF(@SKORHUMPTYDUMPTY > 11, 1,0) HUMPTY_TINGGI
			  , IF(@SKORMORSE IS NULL, @HUMPTY_TIDAK_ADA, @MORSE_TIDAK_ADA) RESIKO_TIDAK_ADA
			  , IF(@SKORMORSE IS NULL, @HUMPTY_RENDAH, @MORSE_RENDAH) RESIKO_RENDAH
			  , @MORSE_SEDANG RESIKO_SEDANG
			  , IF(@SKORMORSE IS NULL, @HUMPTY_TINGGI, @MORSE_TINGGI) RESIKO_TINGGI
		     , IF((SELECT pn.NYERI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1)=1,'Ya','Tidak') NYERI
			  , IF((SELECT pn.ONSET
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1)=1,'Akut','Kronis') ONSET
           , (SELECT pn.SKALA
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) SKALA
	        , (SELECT mt.DESKRIPSI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) METODE
	        , (SELECT pn.PENCETUS
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) PENCETUS
	        , (SELECT pn.GAMBARAN
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) GAMBARAN
	        , (SELECT pn.DURASI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) DURASI
	        , (SELECT pn.LOKASI
							FROM medicalrecord.penilaian_nyeri pn
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pn.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pn.`STATUS` !=0
							ORDER BY pn.TANGGAL ASC LIMIT 1) LOKASI
			  , CONCAT(IFNULL(master.getDiagnosaPasien(pp.NOMOR),''),'\r',
							IFNULL((SELECT ass.ASSESMENT
							FROM medicalrecord.cppt ass
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN 
							WHERE pkrp.NOMOR=pk.NOMOR AND pk.NOPEN=pp.NOMOR
							AND ass.JENIS !=3 AND ass.`STATUS` !=0
							ORDER BY ass.TANGGAL ASC LIMIT 1),'')) DIAGNOSIS
			  , CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL
			  , IF(IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))='-','Tidak Ada',IFNULL(rpp.DESKRIPSI,(SELECT rp.DESKRIPSI
					FROM medicalrecord.rpp rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))) RIWAYATPENYAKIT
			 , IF(IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))='-','Tidak Ada',IFNULL(rps.DESKRIPSI,(SELECT rp.DESKRIPSI
				FROM medicalrecord.rps rp
				LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
				WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1))) rps
			 , (SELECT ask.OLEH
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) IDASK
			 , (SELECT master.getNamaLengkapPegawai(askep.NIP)
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN aplikasi.pengguna askep ON ask.OLEH=askep.ID 
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN 
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) PASK	
			 , (SELECT DATE_FORMAT(ask.TANGGAL,'%d-%m-%Y %H:%i:%s')
					FROM medicalrecord.asuhan_keperawatan ask
					LEFT JOIN aplikasi.pengguna askep ON ask.OLEH=askep.ID 
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ask.KUNJUNGAN 
					WHERE pkrp.NOPEN=pp.NOMOR AND ask.`STATUS` !=0
					ORDER BY ask.TANGGAL DESC LIMIT 1) TASK			 	  
			  , (SELECT IF(ks.MARAH IS NULL, 0, ks.MARAH)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) MARAH
			  , (SELECT IF(ks.CEMAS IS NULL, 0, ks.CEMAS)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) CEMAS
			  , (SELECT IF(ks.TAKUT IS NULL, 0, ks.TAKUT)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) TAKUT
			  , (SELECT IF(ks.BUNUH_DIRI IS NULL, 0, ks.BUNUH_DIRI)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) BUNUH_DIRI
			  , (SELECT IF(ks.SEDIH IS NULL, 0, ks.SEDIH)
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) SEDIH
			  , (SELECT ks.LAINNYA
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) LAINNYA
			  , (SELECT ks.MASALAH_PERILAKU
			  				FROM medicalrecord.kondisi_sosial ks
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ks.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ks.`STATUS` !=0
							ORDER BY ks.TANGGAL ASC LIMIT 1) MASALAH_PERILAKU
			  , (SELECT pgz.BERAT_BADAN_SIGNIFIKAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) BERAT_BADAN_SIGNIFIKAN	
				, (SELECT pgz.INTAKE_MAKANAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) INTAKE_MAKANAN
				, (SELECT pgz.KONDISI_KHUSUS
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) KONDISI_KHUSUS
				, (SELECT pgz.SKOR
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) SKOR
				, IF((SELECT pgz.STATUS_SKOR
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=1,'Ya','Tidak') STATUS_SKOR
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=1,1,0) PBB1
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=2,2,0) PBB2
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=3,3,0) PBB3
				, IF((SELECT pgz.PERUBAHAN_BERAT_BADAN
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1)=4,4,0) PBB4
				, (SELECT pgz.STATUS_VALIDASI
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) STATUS_VALIDASI	
				, (SELECT DATE_FORMAT(pgz.TANGGAL_VALIDASI,'%d-%m-%Y %H:%i:%s')
			  				FROM medicalrecord.permasalahan_gizi pgz
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) TANGGAL_VALIDASI
				, (SELECT master.getNamaLengkapPegawai(ugz.NIP)
			  				FROM medicalrecord.permasalahan_gizi pgz
			  				LEFT JOIN aplikasi.pengguna ugz ON pgz.USER_VALIDASI=ugz.ID
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pgz.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND pgz.`STATUS` !=0
							ORDER BY pgz.TANGGAL ASC LIMIT 1) DIETISEN	  
			  , IF(pgz.PERUBAHAN_BERAT_BADAN=1,'0,5-5 kg'
			  		,IF(pgz.PERUBAHAN_BERAT_BADAN=2,'>5-10 kg'
					  ,IF(pgz.PERUBAHAN_BERAT_BADAN=3,'>10-15 kg'
					  	  ,IF(pgz.PERUBAHAN_BERAT_BADAN=4,'>15 kg','')))) PERUBAHAN_BERAT_BADAN
			  , (SELECT IF(epk.KESEDIAAN=1,'Ya','Tidak')
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) KESEDIAAN
			  , (SELECT IF(epk.HAMBATAN=1,'Ya','Tidak')
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN
			  , (SELECT IF(epk.HAMBATAN_PENDENGARAN IS NULL, 0, epk.HAMBATAN_PENDENGARAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_PENDENGARAN
			  , (SELECT IF(epk.HAMBATAN_PENGLIHATAN IS NULL, 0, epk.HAMBATAN_PENGLIHATAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_PENGLIHATAN
			  , (SELECT IF(epk.HAMBATAN_KOGNITIF IS NULL, 0, epk.HAMBATAN_KOGNITIF)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_KOGNITIF
			  , (SELECT IF(epk.HAMBATAN_FISIK IS NULL, 0, epk.HAMBATAN_FISIK)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_FISIK
			  , (SELECT IF(epk.HAMBATAN_BUDAYA IS NULL, 0, epk.HAMBATAN_BUDAYA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_BUDAYA
			  , (SELECT IF(epk.HAMBATAN_EMOSI IS NULL, 0, epk.HAMBATAN_EMOSI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_EMOSI
			  , (SELECT IF(epk.HAMBATAN_BAHASA IS NULL, 0, epk.HAMBATAN_BAHASA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_BAHASA
			  , (SELECT epk.HAMBATAN_LAINNYA
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) HAMBATAN_LAINNYA
			  , (SELECT epk.PENERJEMAH
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) PENERJEMAH
			  , (SELECT epk.BAHASA
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) BAHASA
			  , (SELECT IF(epk.EDUKASI_DIAGNOSA IS NULL, 0, epk.EDUKASI_DIAGNOSA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_DIAGNOSA
			  , (SELECT epk.EDUKASI_PENYAKIT
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENYAKIT
			  , (SELECT IF(epk.EDUKASI_REHAB_MEDIK IS NULL, 0, epk.EDUKASI_REHAB_MEDIK)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_REHAB_MEDIK
			  , (SELECT IF(epk.EDUKASI_HKP IS NULL, 0, epk.EDUKASI_HKP)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_HKP
			  , (SELECT IF(epk.EDUKASI_OBAT IS NULL, 0, epk.EDUKASI_OBAT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_OBAT
			  , (SELECT IF(epk.EDUKASI_NYERI IS NULL, 0, epk.EDUKASI_NYERI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_NYERI
			  , (SELECT IF(epk.EDUKASI_NUTRISI IS NULL, 0, epk.EDUKASI_NUTRISI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_NUTRISI
			  , (SELECT IF(epk.EDUKASI_PENGGUNAAN_ALAT IS NULL, 0, epk.EDUKASI_PENGGUNAAN_ALAT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENGGUNAAN_ALAT
			  , (SELECT IF(epk.EDUKASI_HAK_BERPARTISIPASI IS NULL, 0, epk.EDUKASI_HAK_BERPARTISIPASI)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_HAK_BERPARTISIPASI
			  , (SELECT IF(epk.EDUKASI_PROSEDURE_PENUNJANG IS NULL, 0, epk.EDUKASI_PROSEDURE_PENUNJANG)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PROSEDURE_PENUNJANG
			  , (SELECT IF(epk.EDUKASI_PEMBERIAN_INFORMED_CONSENT IS NULL, 0, epk.EDUKASI_PEMBERIAN_INFORMED_CONSENT)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PEMBERIAN_INFORMED_CONSENT
			  , (SELECT IF(epk.EDUKASI_PENUNDAAN_PELAYANAN IS NULL, 0, epk.EDUKASI_PENUNDAAN_PELAYANAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PENUNDAAN_PELAYANAN
			  , (SELECT IF(epk.EDUKASI_KELAMBATAN_PELAYANAN IS NULL, 0, epk.EDUKASI_KELAMBATAN_PELAYANAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_KELAMBATAN_PELAYANAN
			  , (SELECT IF(epk.EDUKASI_CUCI_TANGAN IS NULL, 0, epk.EDUKASI_CUCI_TANGAN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_CUCI_TANGAN
			  , (SELECT IF(epk.EDUKASI_BAHAYA_MEROKO IS NULL, 0, epk.EDUKASI_BAHAYA_MEROKO)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_BAHAYA_MEROKO
			  , (SELECT IF(epk.EDUKASI_RUJUKAN_PASIEN IS NULL, 0, epk.EDUKASI_RUJUKAN_PASIEN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_RUJUKAN_PASIEN
			  , (SELECT IF(epk.EDUKASI_PERENCANAAN_PULANG IS NULL, 0, epk.EDUKASI_PERENCANAAN_PULANG)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) EDUKASI_PERENCANAAN_PULANG
			  , (SELECT IF(epk.STATUS_LAIN IS NULL, 0, epk.STATUS_LAIN)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) STATUS_LAIN
			  , (SELECT IF(epk.DESKRIPSI_LAINYA IS NULL, 0, epk.DESKRIPSI_LAINYA)
			  				FROM medicalrecord.edukasi_pasien_keluarga epk
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=epk.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND epk.`STATUS` !=0
							ORDER BY epk.TANGGAL ASC LIMIT 1) DESKRIPSI_LAINYA
			  , IF((SELECT rcnt.DESKRIPSI
			  				FROM medicalrecord.status_pediatric spe
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
							ORDER BY spe.TANGGAL ASC LIMIT 1)=1,'GIZI KURANG',
								IF((SELECT rcnt.DESKRIPSI
				  				FROM medicalrecord.status_pediatric spe
								LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
								WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
								ORDER BY spe.TANGGAL ASC LIMIT 1)=2,'GIZI CUKUP',
									IF((SELECT rcnt.DESKRIPSI
					  				FROM medicalrecord.status_pediatric spe
									LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=spe.KUNJUNGAN 
									WHERE pkrp.NOPEN=pp.NOMOR AND spe.`STATUS` !=0
									ORDER BY spe.TANGGAL ASC LIMIT 1)=3,'LENGKAP',''))) STATUS_PEDIATRIC  		  
			  , (SELECT rcnt.DESKRIPSI
			  				FROM medicalrecord.rencana_terapi rcnt
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rcnt.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND rcnt.`STATUS` !=0
							ORDER BY rcnt.TANGGAL ASC LIMIT 1) RNCTERAPI
			  , (SELECT ekg.KESIMPULAN
			  				FROM medicalrecord.pemeriksaan_ekg ekg
							LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ekg.KUNJUNGAN 
							WHERE pkrp.NOPEN=pp.NOMOR AND ekg.`STATUS` !=0
							ORDER BY ekg.DIBUAT_TANGGAL ASC LIMIT 1) EKG			  
			  , medicalrecord.getHasilPenunjang(pp.NOMOR) HASILPENUNJANG
			  , master.getJawabanKonsul(pp.NOMOR) KONSUL
			  , IF(master.getNamaLengkapPegawai(dpjp.NIP) IS NULL,master.getNamaLengkapPegawai(drreg.NIP),master.getNamaLengkapPegawai(dpjp.NIP)) DOKTER
			  , IF(dpjp.NIP IS NULL,drreg.NIP,dpjp.NIP) NIP
			  , IFNULL(DATE_FORMAT(rps.TANGGAL,'%d-%m-%Y %H:%i:%s'),(SELECT DATE_FORMAT(rp.TANGGAL,'%d-%m-%Y %H:%i:%s')
					FROM medicalrecord.rps rp
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=rp.KUNJUNGAN
					WHERE pkrp.NOMOR=pk.NOMOR AND rp.`STATUS` !=0 ORDER BY rp.TANGGAL ASC LIMIT 1)) TGLPERIKSA			  
			  , CONCAT(IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL(ib.NAMA,''))),',','; ')
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
							AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101'),''),'\r',
							IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL(rpo.OBAT,''))),',','; ')
							FROM medicalrecord.riwayat_pemberian_obat rpo
								, pendaftaran.kunjungan k
							WHERE rpo.KUNJUNGAN = k.NOMOR AND k.`STATUS` IN (1,2) AND rpo.`STATUS`!=0
									AND k.NOPEN=pp.NOMOR),'')) RIWAYATOBAT					
					, (SELECT GROUP_CONCAT(ra.DESKRIPSI)
									FROM medicalrecord.riwayat_alergi ra
										, pendaftaran.kunjungan pk1
										, pendaftaran.pendaftaran pp2
									WHERE ra.KUNJUNGAN=pk1.NOMOR AND ra.STATUS!=0 AND pk1.STATUS!=0
									  AND pk1.NOPEN=pp2.NOMOR AND pp2.`STATUS`!=0 AND ra.DESKRIPSI!=''
									  AND pp2.NORM=pp.NORM
									  AND ra.`STATUS` !=0 ORDER BY ra.TANGGAL ASC LIMIT 1) RIWAYATALERGI
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
							AND hrad.`STATUS`!=0 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0) RAD		
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
				  LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
		        LEFT JOIN pembayaran.tagihan_pendaftaran tpdf ON pp.NOMOR=tpdf.PENDAFTARAN AND tpdf.UTAMA=1 AND tpdf.`STATUS`!=0
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
				  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
				  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
				, pendaftaran.kunjungan pk
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN `master`.referensi rtv ON tv.TINGKAT_KESADARAN=rtv.ID AND rtv.JENIS=179
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN medicalrecord.rps rps ON pk.NOMOR=rps.KUNJUNGAN AND rps.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_fisik pf ON pk.NOMOR=pf.KUNJUNGAN AND pf.`STATUS`!=0
				  LEFT JOIN medicalrecord.kondisi_sosial ks ON pk.NOMOR=ks.KUNJUNGAN AND ks.`STATUS`!=0
				  LEFT JOIN medicalrecord.permasalahan_gizi pgz ON pk.NOMOR=pgz.KUNJUNGAN AND pgz.`STATUS`!=0
				  LEFT JOIN medicalrecord.edukasi_pasien_keluarga epk ON pk.NOMOR=epk.KUNJUNGAN AND epk.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_pediatric spe ON pk.NOMOR=spe.KUNJUNGAN AND spe.`STATUS`!=0
				  LEFT JOIN medicalrecord.anamnesis an ON pk.NOMOR=an.KUNJUNGAN AND an.`STATUS`!=0
				  LEFT JOIN aplikasi.pengguna pga ON an.OLEH=pga.ID
				  LEFT JOIN medicalrecord.pemeriksaan_fisik pfs ON pk.NOMOR=pfs.KUNJUNGAN AND pfs.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN medicalrecord.anamnesis_diperoleh anm ON pk.NOMOR = anm.KUNJUNGAN AND anm.`STATUS` != 0
				  LEFT JOIN medicalrecord.faktor_risiko fr ON pk.NOMOR = fr.KUNJUNGAN AND fr.`STATUS` != 0
				  LEFT JOIN medicalrecord.riwayat_pemberian_obat rpo ON pk.NOMOR = rpo.KUNJUNGAN AND rpo.`STATUS` !=0
				  LEFT JOIN medicalrecord.riwayat_penyakit_keluarga rpk ON pk.NOMOR = rpk.KUNJUNGAN AND rpk.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_mata pmt ON pk.NOMOR=pmt.KUNJUNGAN AND pmt.`STATUS` !=0
				  LEFT JOIN `master`.referensi rmt ON pmt.ADA_KELAINAN=rmt.ID AND rmt.JENIS=178
				  LEFT JOIN medicalrecord.pemeriksaan_tonsil pts ON pk.NOMOR=pts.KUNJUNGAN AND pts.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_faring pfr ON pk.NOMOR=pfr.KUNJUNGAN AND pfr.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_lidah pld ON pk.NOMOR=pld.KUNJUNGAN AND pld.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_bibir pbr ON pk.NOMOR=pbr.KUNJUNGAN AND pbr.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_leher plh ON pk.NOMOR=plh.KUNJUNGAN AND plh.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_dada pdd ON pk.NOMOR=pdd.KUNJUNGAN AND pdd.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_perut prt ON pk.NOMOR=prt.KUNJUNGAN AND prt.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_dekubitus pdk ON pk.NOMOR=pdk.KUNJUNGAN AND pdk.`STATUS` !=0
				  LEFT JOIN medicalrecord.kondisi_sosial kss ON pk.NOMOR=kss.KUNJUNGAN AND kss.`STATUS` !=0
				  LEFT JOIN medicalrecord.discharge_planning_skrining dps ON pk.NOMOR=dps.KUNJUNGAN AND dps.`STATUS` !=0
				  LEFT JOIN medicalrecord.discharge_planning_faktor_risiko dpf ON pk.NOMOR=dpf.KUNJUNGAN AND dpf.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_skala_morse psm ON pk.NOMOR=psm.KUNJUNGAN AND psm.`STATUS` !=0
				  LEFT JOIN medicalrecord.penilaian_skala_humpty_dumpty pshd ON pk.NOMOR=pshd.KUNJUNGAN AND pshd.`STATUS` !=0
				  LEFT JOIN medicalrecord.pemeriksaan_ekg ekg ON pk.NOMOR=ekg.KUNJUNGAN AND ekg.`STATUS` !=0
				  LEFT JOIN aplikasi.pengguna us ON tv.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
				  LEFT JOIN master.dokter dpjp ON dpjp.ID=pk.DPJP
			     LEFT JOIN master.dokter_smf ds ON ds.DOKTER=dpjp.ID
			     LEFT JOIN aplikasi.pengguna ugz ON pgz.USER_VALIDASI=ugz.ID
				, master.ruangan r
				, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
						FROM aplikasi.instansi ai
							, master.ppk mp
							, master.wilayah w
						WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
			WHERE pp.NOMOR=pk.NOPEN AND pp.`STATUS`!=0 AND pk.`STATUS`!=0
			  AND pp.NORM=p.NORM AND pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN IN (2,3)
			  AND pk.NOPEN=PNOPEN
			GROUP BY pk.NOPEN//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
