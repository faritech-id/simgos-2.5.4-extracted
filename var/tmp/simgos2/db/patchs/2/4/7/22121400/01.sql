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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk procedure layanan.CetakHasilLab
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
				SELECT INST.KOTA, DATE_FORMAT(SYSDATE(),''%d-%m-%Y %H:%i:%s'') TGLSKRG, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP,
						 CONCAT(rjk.DESKRIPSI,'' / '',DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'')) JKTGLALHIR,
						 master.getNamaLengkapPegawai(mp.NIP) DOKTER, master.getNamaLengkapPegawai(mpasal.NIP) DOKTERASAL,
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
					, (SELECT w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
