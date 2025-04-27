-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Server version:               8.0.11 - MySQL Community Server - GPL
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


-- Dumping database structure for laporan
USE `laporan`;

-- Dumping structure for procedure laporan.LaporanBelumKlikBayar
DROP PROCEDURE IF EXISTS `LaporanBelumKlikBayar`;
DELIMITER //
CREATE PROCEDURE `LaporanBelumKlikBayar`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT(
		'SELECT inst.PPK, inst.NAMAINST NAMAINST, inst.ALAMATINST ALAMATINST, tp.TAGIHAN, IF(pt.`STATUS` IS NULL,0,pt.`STATUS`) STATUS, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG
				, pp.NOMOR, LPAD(p.NORM,8,''0'') NORM, master.getNamaLengkap(pp.NORM) NAMAPASIEN, p.ALAMAT ALAMATPASIEN
			   , (SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM) NOHP, cb.DESKRIPSI CARABAYAR
				, pj.NAMA PENANGGUNGJAWAB, pj.ALAMAT ALAMATPENANGGUNGJAWAB, kpj.NOMOR HPPENANGGUNGJAWAB
			   , kode.kode KODECBG, kode.DESKRIPSI NAMACBG, IF(cbg.TARIFCBG IS NULL,''Belum Grouping'',IF(cbg.`STATUS`=1,''Final Grouping'',''Belum Final Grouping'')) STATUSGROUPING
				, cbg.TARIFCBG
				, cbg.TARIFKLS1, cbg.TARIFKLS2, cbg.TARIFKLS3, cbg.TOTALTARIF TOTALTARIFCBG, t.TOTAL TARIFRS
			   , UPPER(jnslyn.DESKRIPSI) JENISLAYANAN, jnslyn.ID IDJENISLAYANAN
			   , r.DESKRIPSI RUANGANAWAL
				, IF(jnslyn.ID=3,
						(SELECT r.DESKRIPSI FROM pendaftaran.kunjungan kj, master.ruangan r 
						WHERE kj.NOPEN=pp.NOMOR AND kj.RUANG_KAMAR_TIDUR!=0 AND kj.RUANGAN=r.ID
						  AND kj.`STATUS`!=0 ORDER BY kj.MASUK DESC LIMIT 1), r.DESKRIPSI) RUANGTERAKHIR
				, IF(jnslyn.ID=1,'''',IF(lpp.TANGGAL IS NULL,''Belum Registrasi Keluar'',DATE_FORMAT(lpp.TANGGAL,''%d-%m-%Y %H:%i:%s''))) TGLKELUAR, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLDAFTAR
				, IF(lpp.TANGGAL IS NULL,'''',DATEDIFF(lpp.TANGGAL, pp.TANGGAL)) LOS
				, IF(jnslyn.ID=3,IF(lpp.TANGGAL IS NULL,master.getDPJP(pp.NOMOR,2),master.getNamaLengkapPegawai(mdp.NIP)),master.getNamaLengkapPegawai(dok.NIP)) DPJP
			FROM pendaftaran.pendaftaran pp 
				  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN pendaftaran.penanggung_jawab_pasien pj ON pp.NOMOR=pj.NOPEN 
			     LEFT JOIN pendaftaran.kontak_penanggung_jawab kpj ON pj.ID=kpj.ID  AND kpj.JENIS=3
			     LEFT JOIN pendaftaran.penjamin pjm ON pp.NOMOR=pjm.NOPEN 
			     LEFT JOIN master.referensi cb ON pjm.JENIS=cb.ID AND cb.JENIS=10
			     LEFT JOIN `master`.kartu_asuransi_pasien kap ON p.NORM = kap.NORM AND kap.JENIS=pjm.JENIS
			     LEFT JOIN inacbg.hasil_grouping cbg ON pp.NOMOR=cbg.NOPEN
		  		  LEFT JOIN inacbg.inacbg kode ON cbg.CODECBG=kode.kode AND kode.JENIS=1 AND kode.VERSION=5
		  		  LEFT JOIN layanan.pasien_pulang lpp ON pp.NOMOR=lpp.NOPEN AND lpp.STATUS=1
		  		  LEFT JOIN master.dokter mdp ON lpp.DOKTER=mdp.id
			   , pembayaran.tagihan_pendaftaran tp 
			     LEFT JOIN pendaftaran.tujuan_pasien tps ON tp.PENDAFTARAN=tps.NOPEN AND tps.`STATUS`!=0
			     LEFT JOIN master.ruangan r ON tps.RUANGAN=r.ID
			     LEFT JOIN master.referensi jnslyn ON r.JENIS_KUNJUNGAN=jnslyn.ID AND jnslyn.JENIS=15
			     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN=tp.TAGIHAN AND pt.`STATUS`!=0
			     LEFT JOIN pembayaran.tagihan t on tp.TAGIHAN=t.ID
			     LEFT JOIN master.dokter dok ON tps.DOKTER=dok.ID
			   , (SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) inst
			WHERE pp.`STATUS`!=0 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				AND tps.RUANGAN LIKE ''',vRUANGAN,''' 
			  ',IF(CARABAYAR=0,'',CONCAT(' AND pjm.JENIS=',CARABAYAR)),'
			  AND pp.NOMOR =tp.PENDAFTARAN AND tp.`STATUS`!=0 AND tp.UTAMA=1 AND pt.TAGIHAN IS NULL
			GROUP BY tp.TAGIHAN
			ORDER BY TGLDAFTAR, JENISLAYANAN, RUANGANAWAL, DPJP
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