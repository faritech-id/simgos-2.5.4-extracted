-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanKlaimBPJS
DROP PROCEDURE IF EXISTS `LaporanKlaimBPJS`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanKlaimBPJS`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `LAPORAN` TINYINT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT,
	IN `RUANGAN` INT,
	IN `STATUS` INT
)
BEGIN	
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	
	SELECT r.JENIS_KUNJUNGAN INTO VJENIS_KUNJUNGAN
	  FROM `master`.ruangan r 
	 WHERE r.ID = RUANGAN;
	 
	IF FOUND_ROWS() = 0 THEN
		SET VJENIS_KUNJUNGAN = 0;
	ELSE
		SET VJENIS_KUNJUNGAN = IF(VJENIS_KUNJUNGAN = 3, 1, 2);
	END IF;
	SET LAPORAN = VJENIS_KUNJUNGAN;
	
	SET @sqlText = CONCAT(
	  'SELECT INST.NAMAINST, INST.ALAMATINST, NOPEN, NORM, NAMAPASIEN, NOKARTU, NOSEP, NOFPK
	        , TGLSEP, TGLPULANG, KELAS, JENISPELAYANAN, KODEJENISPELAYANAN, KODEINACBG, INACBG
	        , PENGAJUAN, DISETUJUI
	        , IF(',LAPORAN,'=0,''SEMUA'',IF(',LAPORAN,'=1,''RAWAT INAP'',IF(',LAPORAN,'=2,''RAWAT JALAN'',''''))) JENISP
			 FROM (
                SELECT pj.NOPEN, LPAD(k.peserta_noMR,8,''0'') NORM, k.peserta_nama NAMAPASIEN, k.peserta_noKartu NOKARTU, k.noSEP NOSEP, k.noFPK NOFPK
                , k.tglSep TGLSEP, k.tglPulang TGLPULANG
                , k.kelasRawat KELAS
                , IF(k.jenisPelayanan=1,''Rawat Inap'',''Rawat Jalan'') JENISPELAYANAN
                , k.jenisPelayanan KODEJENISPELAYANAN
                , k.inacbg_kode KODEINACBG, k.inacbg_nama INACBG
                , k.biaya_byPengajuan PENGAJUAN, k.biaya_bySetujui DISETUJUI
            FROM bpjs.klaim k
                 LEFT JOIN pendaftaran.penjamin pj ON k.noSEP=pj.NOMOR AND pj.JENIS=2
            WHERE ',
				IF(STATUS = 3, CONCAT('CONCAT(STR_TO_DATE(SUBSTRING(k.noFPK, 3, 6), ''%d%m%y''), '' 00:00:00'') BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''''), CONCAT('CONCAT(k.tglPulang, '' 00:00:00'') BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''')), '
              AND k.`status_id`= ', STATUS, 
              IF(VJENIS_KUNJUNGAN = 0, '', CONCAT(' AND k.jenisPelayanan = ', VJENIS_KUNJUNGAN)),
					 '
            GROUP BY k.noSEP
        ) ab
        , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
                    FROM aplikasi.instansi ai
                        , master.ppk p
                    WHERE ai.PPK=p.ID) INST
        ');
	
#	SELECT @sqlText;  
   PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
