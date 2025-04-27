-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for bpjs
USE `bpjs`;

-- Dumping structure for procedure bpjs.RencanaKontrol
DROP PROCEDURE IF EXISTS `RencanaKontrol`;
DELIMITER //
CREATE PROCEDURE `RencanaKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT
		 , jk.NOMOR , pj.JENIS IDPENJAMIN
		 , CONCAT(pst.noKartu, '  ( MR. ',pst.norm,' )') NOMORKARTU, pst.norm NORMBPJS
		 , pst.nmJenisPeserta PESERTA, CONCAT(pst.nama,'  (',IF(pst.sex='L','Laki-laki','Perempuan'),')') NAMALENGKAP1
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , DATE(jk.DIBUAT_TANGGAL) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , master.getNamaLengkapPegawai(dr.NIP) DOKTER
	    , drskdp.nama DRSEP
	    , drtjn.nama DRKONTROL
	    , pbpjs.nama SPESIALISTIK
	    , smf.DESKRIPSI SMF
	    , d.DIAGNOSIS
	    , CONCAT(dms.CODE,' (',dms.STR,')') DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , IF(rkbpjs.noSurat IS NULL, DATE_FORMAT(rkbpjs1.tglRencanaKontrol, '%d %M %Y'), DATE_FORMAT(rkbpjs.tglRencanaKontrol, '%d %M %Y')) JADWALBPJS
	    , rt.DESKRIPSI RENCANA_TERAPI
	    , IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat) NOSBPJS
	    , IF(jk.NOMOR IS NULL, pri.NOMOR, jk.NOMOR) NOSURAT
	    , IF(rkbpjs.noSurat IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(rkbpjs.noSurat IS NULL, rkbpjs1.jnsKontrol , rkbpjs.jnsKontrol) JENISKONTROL
	    FROM pendaftaran.kunjungan k
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN bpjs.poli pbpjs ON pss.SUB_SPESIALIS_PENJAMIN=pbpjs.kode
       LEFT JOIN bpjs.dpjp drtjn ON drtj.DPJP_PENJAMIN=drtjn.kode
  		 LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs ON jk.NOMOR_REFERENSI=rkbpjs.noSurat AND rkbpjs.`status` !=0
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs1 ON pri.NOMOR_REFERENSI=rkbpjs1.noSurat AND rkbpjs1.`status` !=0
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB='ICD10_1998' AND dms.TTY !='HT' AND dms.TTY !='PS'
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER
       LEFT JOIN penjamin_rs.dpjp drpj ON dr.ID=drpj.DPJP_RS AND drpj.PENJAMIN=2
       LEFT JOIN bpjs.dpjp drskdp ON drpj.DPJP_PENJAMIN=drskdp.kode
       , `master`.pasien ps
       , `master`.ruangan r
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND r.ID = k.RUANGAN
	AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2;
 END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
