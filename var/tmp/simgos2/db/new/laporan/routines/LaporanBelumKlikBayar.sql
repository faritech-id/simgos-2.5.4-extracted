-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure laporan.LaporanBelumKlikBayar
DROP PROCEDURE IF EXISTS `LaporanBelumKlikBayar`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanBelumKlikBayar`(
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
		'SELECT inst.PPK, inst.NAMAINST NAMAINST, inst.ALAMATINST ALAMATINST, tp.TAGIHAN, IF(pt.`STATUS` IS NULL,0,pt.`STATUS`) STATUS,pp.TANGGAL TGLREG
				, pp.NOMOR, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(pp.NORM) NAMAPASIEN, p.ALAMAT ALAMATPASIEN
			   , (SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
					FROM master.kontak_pasien kp 
					WHERE kp.NORM=p.NORM) NOHP
				, pj.NAMA PENANGGUNGJAWAB, pj.ALAMAT ALAMATPENANGGUNGJAWAB, kpj.NOMOR HPPENANGGUNGJAWAB
			FROM pendaftaran.pendaftaran pp 
				  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
			     LEFT JOIN pendaftaran.penanggung_jawab_pasien pj ON pp.NOMOR=pj.NOPEN 
			     LEFT JOIN pendaftaran.kontak_penanggung_jawab kpj ON pj.ID=kpj.ID  AND kpj.JENIS=3
			     LEFT JOIN pendaftaran.penjamin pjm ON pp.NOMOR=pjm.NOPEN 
			   , pembayaran.tagihan_pendaftaran tp 
			     LEFT JOIN pendaftaran.tujuan_pasien tps ON tp.PENDAFTARAN=tps.NOPEN AND tps.`STATUS`!=0
			     LEFT JOIN master.ruangan r ON tps.RUANGAN=r.ID
			     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN=tp.TAGIHAN AND pt.`STATUS`!=0
			      , (SELECT ai.PPK, p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) inst
			WHERE pp.`STATUS`!=0 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
			  ',IF(LAPORAN='' OR LAPORAN=0,'', CONCAT(' AND tps.RUANGAN LIKE ''',vRUANGAN,'''  AND r.JENIS_KUNJUNGAN=''',LAPORAN,'''')),'
			  ',IF(CARABAYAR=0,'',CONCAT(' AND pjm.JENIS=',CARABAYAR)),'
			  AND pp.NOMOR =tp.PENDAFTARAN AND tp.`STATUS`!=0 AND tp.UTAMA=1 AND pt.TAGIHAN IS NULL
			GROUP BY tp.TAGIHAN
		');
	

   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
