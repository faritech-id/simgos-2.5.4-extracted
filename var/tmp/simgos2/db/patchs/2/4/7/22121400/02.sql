-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanVolTindakanGroupTindakan
DROP PROCEDURE IF EXISTS `LaporanVolTindakanGroupTindakan`;
DELIMITER //
CREATE PROCEDURE `LaporanVolTindakanGroupTindakan`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
    DECLARE vRUANGAN VARCHAR(11);
    SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT('
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, kjgn.NOPEN,
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
					 ) RUANGAN,
					 t.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
					 SUM(rt.JUMLAH) JUMLAH, rt.TARIF, SUM(rt.JUMLAH * rt.TARIF) TOTALTAGIHAN,rt.`STATUS`,
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.ID IS NULL,0,kls.ID), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.ID IS NULL,0,klsol.ID), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.ID IS NULL,0,klsorad.ID),''''))) IDKLS, 
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.DESKRIPSI IS NULL,''Non Kelas'',kls.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.DESKRIPSI IS NULL,''Non Kelas'',klsol.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.DESKRIPSI IS NULL,''Non Kelas'',klsorad.DESKRIPSI),''''))) KELAS,
					 pj.JENIS IDCARABAYAR, cr.DESKRIPSI CARABAYAR,kgl.ID IDKLP, kgl.DESKRIPSI KLPLAB, ggl.DESKRIPSI GROUPLAB,
					 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
					 IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER,
				    IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER,
				    IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER,
				    INST.NAMAINST, INST.ALAMATINST
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
			  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
					 LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1 AND ptm.STATUS!=0
					 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					 LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					 /*group dan kelompok lab */
					 LEFT JOIN master.group_tindakan_lab gtl ON t.ID=gtl.TINDAKAN
					 LEFT JOIN master.group_pemeriksaan kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.KODE AND kgl.JENIS=8 AND kgl.STATUS=1
			  		 LEFT JOIN master.group_pemeriksaan ggl ON gtl.GROUP_LAB=ggl.KODE AND ggl.JENIS=8 AND ggl.STATUS=1
			  		 /*order lab*/
			  		 LEFT JOIN layanan.order_lab ol ON kjgn.REF=ol.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuol ON ol.KUNJUNGAN=kuol.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktol ON rktol.ID = kuol.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkol ON rkol.ID = rktol.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsol ON klsol.JENIS = 19 AND klsol.ID = rkol.KELAS
			  		 /*order rad*/
			  		 LEFT JOIN layanan.order_rad orad ON kjgn.REF=orad.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuorad ON orad.KUNJUNGAN=kuorad.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktorad ON rktorad.ID = kuorad.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkorad ON rk.ID = rktorad.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsorad ON klsorad.JENIS = 19 AND klsorad.ID = rkorad.KELAS
			  		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
							FROM aplikasi.instansi ai
								, master.ppk p
							WHERE ai.PPK=p.ID) INST
			 WHERE rt.`STATUS`!=0 AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''
			   AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			   AND rt.JENIS = 3
			   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
				',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),'
			GROUP BY kjgn.RUANGAN,kgl.ID, tm.TINDAKAN
		');
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

-- membuang struktur untuk procedure laporan.LaporanVolTindakanPerkelas
DROP PROCEDURE IF EXISTS `LaporanVolTindakanPerkelas`;
DELIMITER //
CREATE PROCEDURE `LaporanVolTindakanPerkelas`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
    SET vRUANGAN = CONCAT(RUANGAN,'%');
	SET @sqlText = CONCAT('
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, kjgn.NOPEN,
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
					 ) RUANGAN,
					 t.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
					 SUM(rt.JUMLAH) JUMLAH, rt.TARIF, SUM(rt.JUMLAH * rt.TARIF) TOTALTAGIHAN,rt.`STATUS`,
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.ID IS NULL,0,kls.ID), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.ID IS NULL,0,klsol.ID), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.ID IS NULL,0,klsorad.ID),''''))) IDKLS, 
					 IF(r.JENIS_KUNJUNGAN=3,IF(kls.DESKRIPSI IS NULL,''Non Kelas'',kls.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=4, IF(klsol.DESKRIPSI IS NULL,''Non Kelas'',klsol.DESKRIPSI), IF(r.JENIS_KUNJUNGAN=5, IF(klsorad.DESKRIPSI IS NULL,''Non Kelas'',klsorad.DESKRIPSI),''''))) KELAS,
					 pj.JENIS IDCARABAYAR, cr.DESKRIPSI CARABAYAR, kgl.DESKRIPSI KLPLAB, ggl.DESKRIPSI GROUPLAB,
					 master.getHeaderLaporan(''',RUANGAN,''') INSTALASI,
					 IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER,
				    IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER,
				    IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER,
				    INST.NAMAINST, INST.ALAMATINST
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
			  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
					 LEFT JOIN master.referensi cr ON pj.JENIS=cr.ID AND cr.JENIS=10
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1 AND ptm.STATUS!=0
					 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					 LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					 /*group dan kelompok lab */
					 LEFT JOIN master.group_tindakan_lab gtl ON t.ID=gtl.TINDAKAN
					  LEFT JOIN master.group_pemeriksaan kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.KODE AND kgl.JENIS=8 AND kgl.STATUS=1
			  		 LEFT JOIN master.group_pemeriksaan ggl ON gtl.GROUP_LAB=ggl.KODE AND ggl.JENIS=8 AND ggl.STATUS=1
			  		 /*order lab*/
			  		 LEFT JOIN layanan.order_lab ol ON kjgn.REF=ol.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuol ON ol.KUNJUNGAN=kuol.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktol ON rktol.ID = kuol.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkol ON rkol.ID = rktol.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsol ON klsol.JENIS = 19 AND klsol.ID = rkol.KELAS
			  		 /*order rad*/
			  		 LEFT JOIN layanan.order_rad orad ON kjgn.REF=orad.NOMOR
			  		 LEFT JOIN pendaftaran.kunjungan kuorad ON orad.KUNJUNGAN=kuorad.NOMOR
			  		 LEFT JOIN `master`.ruang_kamar_tidur rktorad ON rktorad.ID = kuorad.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rkorad ON rk.ID = rktorad.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi klsorad ON klsorad.JENIS = 19 AND klsorad.ID = rkorad.KELAS
			  		 , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
							FROM aplikasi.instansi ai
								, master.ppk p
							WHERE ai.PPK=p.ID) INST
			 WHERE rt.`STATUS`!=0 AND kjgn.RUANGAN LIKE ''',vRUANGAN,'''
			   AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			   AND rt.JENIS = 3
			   ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
				',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
				',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),'
			GROUP BY kjgn.RUANGAN, tm.TINDAKAN, IDKLS
		');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
