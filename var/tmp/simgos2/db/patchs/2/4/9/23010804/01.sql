-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
CREATE DATABASE IF NOT EXISTS `medicalrecord` /*!40100 DEFAULT CHARACTER SET latin1 */;
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
		     , ku.DESKRIPSI KELUHAN
		     , tv.KEADAAN_UMUM, CONCAT(tv.SISTOLIK,'/', tv.DISTOLIK) DARAH, tv.FREKUENSI_NADI, tv.FREKUENSI_NAFAS, tv.SUHU
		     , nu.BERAT_BADAN, nu.TINGGI_BADAN, nu.INDEX_MASSA_TUBUH, nu.LINGKAR_KEPALA
		     , sfu.ALAT_BANTU, sfu.TANPA_ALAT_BANTU, sfu.TONGKAT, sfu.KURSI_RODA, sfu.BRANKARD, sfu.WALKER, sfu.CACAT_TUBUH_TIDAK, sfu.CACAT_TUBUH_YA, sfu.KET_CACAT_TUBUH,fu.PROTHESA
			  , DATE_FORMAT(ku.TANGGAL,'%H:%i:%s') JAM
		     , master.getNamaLengkapPegawai(pg.NIP) PERAWAT
		     , IF(pn.NYERI=1,'Ya','Tidak') NYERI
			  , IF(pn.ONSET=1,'Akut',IF(pn.ONSET=2,'Kronis','')) ONSET, pn.SKALA, mt.DESKRIPSI METODE, pn.PENCETUS, pn.GAMBARAN, pn.DURASI, pn.LOKASI
			  , rcnt.DESKRIPSI RNCTERAPI
			  , dg.DIAGNOSIS, CONCAT(DATE_FORMAT(jk.TANGGAL,'%d-%m-%Y'),' ',jk.JAM) JADWAL, rpp.DESKRIPSI RIWAYATPENYAKIT
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
				, (SELECT sub.SUBYEKTIF
					FROM medicalrecord.cppt sub
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=sub.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY sub.TANGGAL DESC LIMIT 1) SUBYEKTIF
				, (SELECT oby.OBYEKTIF
					FROM medicalrecord.cppt oby
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=oby.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY oby.TANGGAL DESC LIMIT 1) OBYEKTIF
				, (SELECT ass.ASSESMENT
					FROM medicalrecord.cppt ass
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ass.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY ass.TANGGAL DESC LIMIT 1) ASSESMENT
				, (SELECT pln.PLANNING
					FROM medicalrecord.cppt pln
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=pln.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY pln.TANGGAL DESC LIMIT 1) PLANNING
				, (SELECT ins.INSTRUKSI
					FROM medicalrecord.cppt ins
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY ins.TANGGAL DESC LIMIT 1) INSTRUKSI
				, (SELECT ins.INSTRUKSI
					FROM medicalrecord.cppt ins
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=ins.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY ins.TANGGAL DESC LIMIT 1) INSTRUKSI
  			  , (SELECT DATE_FORMAT(tgl.TANGGAL,'%d-%m-%Y') TGLPERIKSA
					FROM medicalrecord.cppt tgl
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=tgl.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY tgl.TANGGAL DESC LIMIT 1) TGLPERIKSA 
				, (SELECT DATE_FORMAT(jam.TANGGAL,'%H:%i:%s') JAMPERIKSA
					FROM medicalrecord.cppt jam
					LEFT JOIN pendaftaran.kunjungan pkrp ON pkrp.NOMOR=jam.KUNJUNGAN
					WHERE pkrp.NOPEN=pp.NOMOR
					ORDER BY jam.TANGGAL DESC LIMIT 1) JAMPERIKSA
				, master.getNamaLengkapPegawai(drreg.NIP) DOKTER
				, master.getRuangKonsul(pp.NORM) KONSUL
		   FROM pendaftaran.pendaftaran pp
		        LEFT JOIN pendaftaran.tujuan_pasien ptp ON pp.NOMOR=ptp.NOPEN AND ptp.`STATUS`!=0
		        LEFT JOIN master.dokter drreg ON ptp.DOKTER=drreg.ID
			   , master.pasien p
				  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
				  LEFT JOIN master.wilayah wl ON p.TEMPAT_LAHIR=wl.ID
				, pendaftaran.kunjungan pk
				  LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
				  LEFT JOIN medicalrecord.tanda_vital tv ON pk.NOMOR=tv.KUNJUNGAN AND tv.`STATUS`!=0
				  LEFT JOIN medicalrecord.nutrisi nu ON pk.NOMOR=nu.KUNJUNGAN AND nu.`STATUS`!=0
				  LEFT JOIN medicalrecord.fungsional fu ON pk.NOMOR=fu.KUNJUNGAN AND fu.`STATUS`!=0
				  LEFT JOIN medicalrecord.status_fungsional sfu ON pk.NOMOR=sfu.KUNJUNGAN AND sfu.`STATUS`!=0
				  LEFT JOIN medicalrecord.penilaian_nyeri pn ON pk.NOMOR=pn.KUNJUNGAN AND pn.`STATUS`!=0
				  LEFT JOIN master.referensi mt ON pn.METODE=mt.ID AND mt.JENIS=71
				  LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
				  LEFT JOIN medicalrecord.rencana_terapi rcnt ON pk.NOMOR = rcnt.KUNJUNGAN AND rcnt.`STATUS` != 0
				  LEFT JOIN medicalrecord.jadwal_kontrol jk ON pk.NOMOR=jk.KUNJUNGAN AND jk.`STATUS`!=0
				  LEFT JOIN medicalrecord.rpp rpp ON pk.NOMOR=rpp.KUNJUNGAN AND rpp.`STATUS`!=0
				  LEFT JOIN aplikasi.pengguna us ON ku.OLEH=us.ID
				  LEFT JOIN master.pegawai pg ON us.NIP=pg.NIP
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
