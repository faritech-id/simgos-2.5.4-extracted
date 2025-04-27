-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.1.0.6557
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

-- Dumping structure for procedure medicalrecord.cetakSuratKontrol
DROP PROCEDURE IF EXISTS `cetakSuratKontrol`;
DELIMITER //
CREATE PROCEDURE `cetakSuratKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT
		 , pj.JENIS IDPENJAMIN
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE(jk.DIBUAT_TANGGAL),DATE(pri.DIBUAT_TANGGAL)) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drk.NIP),master.getNamaLengkapPegawai(drso.NIP)) DOKTER
	    , IFNULL(smf.DESKRIPSI,smfso.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING
	    , IF(master.getDiagnosa(p.NOMOR, 1) IS NULL,CONCAT(dms.CODE,' (',dms.STR,')'),CONCAT(master.getKodeDiagnosa(p.NOMOR,1),master.getDiagnosa(p.NOMOR, 1))) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, pri.DESKRIPSI KETSO, jk.DESKRIPSI KET
	    , rt.DESKRIPSI RENCANA_TERAPI
	    , IF(jk.RUANGAN IS NULL, CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR), CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)) NOSURAT
	    , IF(jk.RUANGAN IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(jk.RUANGAN IS NULL, 1 , 2) JENISKONTROL
	    FROM pendaftaran.kunjungan k
	    LEFT JOIN master.dokter drso ON drso.ID=k.DPJP
	    LEFT JOIN master.dokter_smf ds ON ds.DOKTER=drso.ID
	    LEFT JOIN master.referensi smfso ON smfso.ID=ds.SMF AND smfso.JENIS=26
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
  		 LEFT JOIN `master`.ruangan r ON jk.RUANGAN = r.ID
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.dokter drk ON drk.ID=drtj.DPJP_RS
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0  		
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB='ICD10_1998' AND dms.TTY !='HT' AND dms.TTY !='PS'
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER       
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2
	GROUP BY k.NOMOR;
 END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
