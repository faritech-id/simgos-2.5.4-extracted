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

-- Dumping database structure for layanan
USE `layanan`;

-- Dumping structure for procedure layanan.CetakHasilLab
DROP PROCEDURE IF EXISTS `CetakHasilLab`;
DELIMITER //
CREATE PROCEDURE `CetakHasilLab`(
	IN `PNOMOR` CHAR(21),
	IN `PTINDAKAN` VARCHAR(1000)
)
BEGIN
	SET @sqlText = CONCAT('
	SELECT  COUNT(*) INTO @ROWS 
		FROM layanan.hasil_lab hlab,
			  layanan.tindakan_medis tm
			  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
			  LEFT JOIN master.dokter dok ON chl.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP,
			  master.parameter_tindakan_lab ptl,
			  master.tindakan mt
			  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN AND gtl.STATUS = 1
			  LEFT JOIN master.group_pemeriksaan kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.KODE AND kgl.JENIS=8 AND kgl.STATUS=1
			  LEFT JOIN master.group_pemeriksaan ggl ON gtl.GROUP_LAB=ggl.KODE AND ggl.JENIS=8 AND ggl.STATUS=1,
			  pendaftaran.pendaftaran pp
			  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10,
			  pendaftaran.kunjungan pk 
			  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
			  LEFT JOIN master.dokter dokasal ON ks.DOKTER_ASAL=dokasal.ID
			  LEFT JOIN master.pegawai mpasal ON dokasal.NIP=mpasal.NIP,
			  master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
				AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
				AND pk.NOMOR=''',PNOMOR,'''  AND hlab.TINDAKAN_MEDIS IN (',PTINDAKAN,')
				AND (hlab.HASIL!='''' AND hlab.HASIL IS NOT NULL)
		ORDER BY ggl.ID,ptl.INDEKS');
	
		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		
	SET @sqlText = CONCAT('
				SELECT inst.*, DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s'') TGLSKRG, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP,
						 CONCAT(rjk.DESKRIPSI,'' / '',DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'')) JKTGLALHIR,
						 master.getNamaLengkapPegawai(mp.NIP) DOKTER, mp.NIP NIPDPJP, master.getNamaLengkapPegawai(mpasal.NIP) DOKTERASAL,
						 master.getNamaLengkapPegawai(mpper.NIP) ANALIS,
						 pk.NOPEN, pk.MASUK TGLREG, hlab.TANGGAL TANGGALHASIL, chl.CATATAN,
						 r.DESKRIPSI UNITPENGANTAR, ks.ALASAN DIAGNOSA, tm.KUNJUNGAN, gtl.GROUP_LAB,
						 kgl.DESKRIPSI KLPLAB, ggl.DESKRIPSI GROUPLAB,
						 mt.NAMA NAMATINDAKAN, ptl.PARAMETER, IFNULL(hlab.NILAI_NORMAL, ptl.NILAI_RUJUKAN) NILAI_RUJUKAN, hlab.HASIL, 
						 IFNULL(hlab.SATUAN, sl.DESKRIPSI) SATUAN, hlab.KETERANGAN,
						 ggl.ID, ptl.INDEKS, @ROWS `ROWS`
				FROM layanan.hasil_lab hlab,
					  layanan.tindakan_medis tm
					  LEFT JOIN layanan.catatan_hasil_lab chl ON tm.KUNJUNGAN=chl.KUNJUNGAN
					  LEFT JOIN master.dokter dok ON chl.DOKTER=dok.ID
					  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					  LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS=tm.ID AND ptm.JENIS=6 AND ptm.KE=1 AND ptm.STATUS!=0
					  #LEFT JOIN master.perawat per ON ptm.MEDIS=per.ID
					  LEFT JOIN master.pegawai mpper ON ptm.MEDIS=mpper.ID,
					  master.parameter_tindakan_lab ptl
					  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
					  master.tindakan mt
					  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN AND gtl.STATUS = 1
					  LEFT JOIN master.group_pemeriksaan kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.KODE AND kgl.JENIS=8 AND kgl.STATUS=1
			  		  LEFT JOIN master.group_pemeriksaan ggl ON gtl.GROUP_LAB=ggl.KODE AND ggl.JENIS=8 AND ggl.STATUS=1,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10,
					  pendaftaran.kunjungan pk 
					  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
					  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
					  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
					  LEFT JOIN master.dokter dokasal ON ks.DOKTER_ASAL=dokasal.ID
					  LEFT JOIN master.pegawai mpasal ON dokasal.NIP=mpasal.NIP,
					  master.pasien p
					  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
					, (SELECT mp.NAMA NAMAINST, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT ALAMATINST , mp.TELEPON, mp.FAX, ai.EMAIL
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
				WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
						AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
						AND pk.NOMOR=''',PNOMOR,''' AND hlab.TINDAKAN_MEDIS IN (',PTINDAKAN,')
						AND (hlab.HASIL!='''' AND hlab.HASIL IS NOT NULL)
				ORDER BY ggl.ID,ptl.INDEKS');

		PREPARE stmt FROM @sqlText;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure layanan.CetakHasilRad
DROP PROCEDURE IF EXISTS `CetakHasilRad`;
DELIMITER //
CREATE PROCEDURE `CetakHasilRad`(
	IN `PTINDAKAN` CHAR(11)
)
BEGIN
	SELECT INST.*
			, DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i:%s') TGLSKRG, LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, CONCAT(rjk.DESKRIPSI,' / ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) JKTGLALHIR
			, hrad.TANGGAL, hrad.KLINIS, hrad.KESAN, hrad.USUL, hrad.HASIL, hrad.BTK
			, master.getNamaLengkapPegawai(mp.NIP) DOKTER, mp.NIP NIPDOKTER
			, pk.NOPEN, pk.MASUK TGLREG, t.NAMA NAMATINDAKAN, r.DESKRIPSI UNITPENGANTAR, orad.ALASAN DIAGNOSA
			, p.ALAMAT
			, master.getNamaLengkapPegawai(dokasal.NIP) DOKTERASAL, master.getNamaLengkapPegawai(prad.NIP) RADIOGRAFER
		FROM layanan.hasil_rad hrad
			  LEFT JOIN master.dokter dok ON hrad.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			, layanan.tindakan_medis tm
			  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			  LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR = tm.KUNJUNGAN
			  LEFT JOIN layanan.order_rad orad ON orad.NOMOR = pku.REF AND orad.`STATUS` IN (1,2)
			  LEFT JOIN master.dokter dokasal ON orad.DOKTER_ASAL=dokasal.ID
			  LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS=tm.ID AND ptm.JENIS=3 AND ptm.KE=1 AND ptm.STATUS!=0
			  LEFT JOIN master.perawat prad ON ptm.MEDIS=prad.ID
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN layanan.order_rad ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATPPK,  CONCAT('Telp. ',TELEPON, ' Fax. ',FAX) TLP, ai.PPK IDPPK
							, w.DESKRIPSI KOTA, ai.WEBSITE WEB
					FROM aplikasi.instansi ai
						, master.ppk p
						, master.wilayah w
					WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
		AND hrad.TINDAKAN_MEDIS=PTINDAKAN AND hrad.`STATUS` !=0
	;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
