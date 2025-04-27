-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for informasi
USE `informasi`;

-- Dumping structure for procedure informasi.monitoringPasienDirawatSikepo
DROP PROCEDURE IF EXISTS `monitoringPasienDirawatSikepo`;
DELIMITER //
CREATE PROCEDURE `monitoringPasienDirawatSikepo`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `CARAKELUAR` TINYINT,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT,
	IN `STATUSLOS` TINYINT,
	IN `STATUSTARIF` TINYINT,
	IN `RENCANAPULANG` TINYINT,
	IN `PCARI` VARCHAR(50)
)
BEGIN
  DECLARE vTGLAWAL DATE;
  DECLARE vTGLAKHIR DATE;
  DECLARE vRUANGAN VARCHAR(11);
  DECLARE vPCARI VARCHAR(50);
  
  SET vRUANGAN = CONCAT(RUANGAN,'%');     
  SET vTGLAWAL = DATE(TGLAWAL);
  SET vTGLAKHIR = DATE(TGLAKHIR);
  SET vPCARI = CONCAT(PCARI,'%');
  
 SET @sqlText = CONCAT('
 SELECT ab.*, u.DESKRIPSI UNIT, ins.DESKRIPSI INSTALASI
 	FROM (
	SELECT LPAD(ps.NORM,8,''0'') NORM, pp.NOMOR NOPEN, master.getNamaLengkap(ps.NORM) NAMALENGKAP, CONCAT(DATE_FORMAT(ps.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,ps.TANGGAL_LAHIR),'')'') TANGGAL_LAHIR, crbyr.DESKRIPSI CARABAYAR,
		    master.getCariUmur(pp.TANGGAL, ps.TANGGAL_LAHIR) UMUR, IF(ps.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN, pk.RUANGAN IDRUANGAN, SUBSTRING(pk.RUANGAN, 1, 7) IDUNIT, SUBSTRING(pk.RUANGAN, 1, 5) IDINSTALASI,
		    pp.TANGGAL TGLMASUK, r.DESKRIPSI SUBUNIT, CONCAT(rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR
		    , @LOS:=IF(lpp.TANGGAL IS NULL,DATEDIFF(SYSDATE(),pp.TANGGAL),DATEDIFF(lpp.TANGGAL, pp.TANGGAL)) LOS
		    , IF(@LOS <= 7,1,IF(@LOS <= 14, 2, 3)) IDLOS
		    , IF(@LOS <= 7,''0-7 hr'',IF(@LOS <= 14, ''8-14 hr'', ''> 14 hr'')) STATUSLOS
		    , drk.ID ID_DR_AKHIR, `master`.getNamaLengkapPegawai(drk.NIP) DR_AKHIR, smfk.DESKRIPSI SMF_AKHIR
		    , IF(hg.NOPEN IS NULL, ''Belum Grouping'',IF(hg.`STATUS`=1,''Sudah Final'',''Belum Final'')) STATUS_GROUPING
		    , IF(hg.NOPEN IS NULL, '''',hg.TANGGAL) TANGGAL_GROUPING, tg.TAGIHAN
			 , hg.CODECBG, hg.TARIFCBG, cbg.DESKRIPSI DESKRIPSICBG
			 , @TARIFCBG:=hg.TOTALTARIF NILAIJAMINAN
			 , @TAGIHANIRD:=IFNULL((SELECT tg.TOTAL
						FROM pembayaran.tagihan_pendaftaran tpd
							, pembayaran.tagihan tg
						WHERE tpd.PENDAFTARAN=`master`.getNopenIRD(pp.NORM, pp.TANGGAL) AND tpd.TAGIHAN=tg.ID AND tg.`STATUS`!=0
							AND tpd.UTAMA=1 AND tpd.`STATUS`!=0),0) TAGIHANIRD
			 , @TAGIHANRI:=IFNULL(tn.TOTAL,0) TAGIHANRI
			 , @TARIFRS:=@TAGIHANIRD + @TAGIHANRI TOTALTARIFRS
			 , IF(@TARIFCBG=0,0,IF((@TARIFRS/@TARIFCBG) * 100 <= 75, 1, IF((@TARIFRS/@TARIFCBG) * 100 <= 90, 2, 3))) IDTARIF
			 
			 , (SELECT rpp.TANGGAL_RENCANA_PULANG
					FROM medicalrecord.cppt rpp
						, pendaftaran.kunjungan j
					WHERE rpp.KUNJUNGAN=j.NOMOR AND rpp.`STATUS`!=0 AND j.`STATUS`!=0
					AND j.NOPEN=pk.NOPEN AND rpp.RENCANA_PULANG=1
					LIMIT 1) TANGGAL_RENCANA_PULANG
			 , IF((SELECT rpp.TANGGAL_RENCANA_PULANG
					FROM medicalrecord.cppt rpp
						, pendaftaran.kunjungan j
					WHERE rpp.KUNJUNGAN=j.NOMOR AND rpp.`STATUS`!=0 AND j.`STATUS`!=0
					AND j.NOPEN=pk.NOPEN AND rpp.RENCANA_PULANG=1
					LIMIT 1) IS NULL,1,2)  STATUS_RENCANA_PULANG
			  , kls.DESKRIPSI KELASHAK
			, (SELECT IF(pk.TITIPAN=1,CONCAT(kl.DESKRIPSI,'' (Titipan)''),kl.DESKRIPSI)
					FROM pendaftaran.kunjungan k 
				        LEFT JOIN master.ruang_kamar_tidur rkt1 ON k.RUANG_KAMAR_TIDUR=rkt1.ID
					     LEFT JOIN master.ruang_kamar rk1 ON rkt1.RUANG_KAMAR = rk1.ID
					     LEFT JOIN `master`.group_referensi_kelas grk ON rk1.KELAS=grk.REFERENSI_KELAS
					     LEFT JOIN `master`.referensi kl ON grk.KELAS=kl.ID AND kl.JENIS=19
					WHERE k.NOPEN=pk.NOPEN 
					  AND k.RUANG_KAMAR_TIDUR!=0
					ORDER BY grk.KELAS DESC 
					LIMIT 1) KELASRAWATMAX
			, (SELECT IF(grk.KELAS=0 OR (grk.KELAS - pj.KELAS) <=0 OR pk.TITIPAN=1, ''Sesuai Hak'',CONCAT(''Naik '', (grk.KELAS - pj.KELAS),'' Tingkat''))
					FROM pendaftaran.kunjungan k 
				        LEFT JOIN master.ruang_kamar_tidur rkt1 ON k.RUANG_KAMAR_TIDUR=rkt1.ID
					     LEFT JOIN master.ruang_kamar rk1 ON rkt1.RUANG_KAMAR = rk1.ID
					     LEFT JOIN `master`.group_referensi_kelas grk ON rk1.KELAS=grk.REFERENSI_KELAS
					     LEFT JOIN `master`.referensi kl ON grk.KELAS=kl.ID AND kl.JENIS=19
					WHERE k.NOPEN=pk.NOPEN
					  AND k.RUANG_KAMAR_TIDUR!=0
					ORDER BY grk.KELAS DESC 
					LIMIT 1) KETKELASRAWATMAX
			/*	, IFNULL((SELECT g.DIAGNOSIS
						FROM pendaftaran.kunjungan j
							, medicalrecord.diagnosis g
						WHERE j.NOPEN=`master`.getNopenIRD(pp.NORM, pp.TANGGAL) AND j.`STATUS`!=0 AND j.NOMOR=g.KUNJUNGAN 
						ORDER BY j.MASUK 
						LIMIT 1),dg.DIAGNOSIS) DIAGNOSA*/
	FROM pendaftaran.kunjungan pk		 
		   LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
		    LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
		    LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
		    LEFT JOIN layanan.pasien_pulang lpp ON pk.NOPEN=lpp.NOPEN	
			 LEFT JOIN master.dokter drk ON pk.DPJP=drk.ID
		    LEFT JOIN master.dokter_smf spk ON drk.ID=spk.DOKTER
		    LEFT JOIN master.referensi smfk ON spk.SMF=smfk.ID AND smfk.JENIS=26
		    LEFT JOIN medicalrecord.diagnosis dg ON pk.NOMOR=dg.KUNJUNGAN AND dg.`STATUS`!=0
		    JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
		  , pendaftaran.pendaftaran pp
		    LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
		    LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		    LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
		    LEFT JOIN master.referensi kls ON pj.KELAS=kls.ID AND kls.JENIS=19
			 LEFT JOIN pembayaran.tagihan_pendaftaran tg ON pp.NOMOR=tg.PENDAFTARAN AND tg.UTAMA=1 AND tg.`STATUS`=1
			 LEFT JOIN pembayaran.pembayaran_tagihan pt ON tg.TAGIHAN=pt.TAGIHAN AND pt.JENIS=1 AND pt.`STATUS`=2
			 LEFT JOIN inacbg.hasil_grouping hg ON pp.NOMOR=hg.NOPEN
			 LEFT JOIN inacbg.inacbg cbg ON hg.CODECBG=cbg.KODE AND cbg.VERSION=''5'' AND cbg.JENIS=1
			 LEFT JOIN pembayaran.tagihan tn ON tg.TAGIHAN=tn.ID AND tn.`STATUS`!=0	
	WHERE pk.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR
	   ',IF(CARAKELUAR=0,'',CONCAT(' AND lpp.CARA=',CARAKELUAR)),'
	   ',IF(RUANGAN=0 OR RUANGAN=1,'',CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,''' ')),'
	  	',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(DOKTER=0,'',CONCAT(' AND pk.DPJP=',DOKTER)),'
		',IF(PCARI='','',CONCAT(' 	AND (ps.NORM=''',PCARI,''' OR ps.NAMA LIKE ''',PCARI,''') ')),'
	   AND DATE(pk.MASUK) < DATE_ADD(''',vTGLAKHIR,''',INTERVAL 1 DAY)
		AND (DATE(pk.KELUAR) > ''',vTGLAKHIR,''' OR pk.KELUAR IS NULL)
		AND pp.`STATUS` !=0
	 ) ab 
	 JOIN master.ruangan u ON ab.IDUNIT=u.ID 
	 JOIN master.ruangan ins ON ab.IDINSTALASI=ins.ID 
	WHERE IDRUANGAN!=0  
	',IF(STATUSLOS=0,'',CONCAT(' AND IDLOS=',STATUSLOS)),'
	',IF(STATUSTARIF=0,'',CONCAT(' AND IDTARIF=',STATUSTARIF)),'
	',IF(RENCANAPULANG=0,'',CONCAT(' AND STATUS_RENCANA_PULANG=',RENCANAPULANG)),'
	ORDER BY IDRUANGAN, TGLMASUK
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
