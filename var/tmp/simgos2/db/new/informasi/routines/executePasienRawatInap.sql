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

-- membuang struktur untuk procedure informasi.executePasienRawatInap
DROP PROCEDURE IF EXISTS `executePasienRawatInap`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executePasienRawatInap`(IN `PTGL_AWAL` DATE, IN `PTGL_AKHIR` DATE)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
	DECLARE VTGL_AKHIR DATETIME;
		
	SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
	SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
	
	BEGIN		
		DECLARE VTANGGAL DATE;
		DECLARE VID VARCHAR(50);
		DECLARE VDESKRIPSI VARCHAR(200);
		DECLARE VCARABAYAR VARCHAR(200);
		DECLARE VIDCARABAYAR VARCHAR(1);
		DECLARE VVALUE BIGINT;
		DECLARE VLASTUPDATED DATETIME;
		
		DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
		DECLARE CR_EXEC CURSOR FOR SELECT * FROM (
			SELECT DATE(tk.MASUK) TANGGAL
					, 1 ID
					, 'Pasien Masuk' DESKRIPSI
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)','PBI APBD' 
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)','PBI APBN'
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU','NON PBI(MANDIRI)'
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),'NON PBI (NON MANDIRI)','NON JKN')))) CARABAYAR
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)',1
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)',2
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU',3
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),4,5)))) IDCARABAYAR
					, COUNT(tk.NOMOR) VALUE
					, MAX(tk.MASUK) LASTUPDATED
				FROM pendaftaran.pendaftaran pd
					  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND pj.JENIS=kap.JENIS AND pj.JENIS=2
					  LEFT JOIN bpjs.peserta bp ON pd.NORM=bp.norm AND pj.JENIS=2 AND kap.NOMOR=bp.noKartu
					, pendaftaran.kunjungan tk
					, master.ruangan jkr
					  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
							 
				WHERE pd.NOMOR=tk.NOPEN AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2) AND tk.REF IS NULL
						AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=3
						AND tk.MASUK BETWEEN VTGL_AWAL AND VTGL_AKHIR
				GROUP BY DATE(tk.MASUK),IDCARABAYAR
			UNION
			SELECT DATE(bts.tgl) TANGGAL
					, 2 ID
					, 'Pasien Rawat' DESKRIPSI
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)','PBI APBD' 
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)','PBI APBN'
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU','NON PBI(MANDIRI)'
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),'NON PBI (NON MANDIRI)','NON JKN')))) CARABAYAR
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)',1
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)',2
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU',3
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),4,5)))) IDCARABAYAR
					, COUNT(tk.NOMOR) VALUE
					, MAX(tk.MASUK) LASTUPDATED
				FROM pendaftaran.pendaftaran pd
					  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND pj.JENIS=kap.JENIS AND pj.JENIS=2
					  LEFT JOIN bpjs.peserta bp ON pd.NORM=bp.norm AND pj.JENIS=2 AND kap.NOMOR=bp.noKartu
					, pendaftaran.kunjungan tk
					, master.ruangan jkr
					  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
					, (SELECT TANGGAL TGL
									  FROM master.tanggal 
									 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR) bts		 
				WHERE pd.NOMOR=tk.NOPEN AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2) 
						AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=3
						AND DATE(tk.MASUK) < DATE_ADD(bts.TGL,INTERVAL 1 DAY)
						AND (DATE(tk.KELUAR) > bts.TGL OR tk.KELUAR IS NULL)
				GROUP BY DATE(bts.tgl), IDCARABAYAR
			UNION
			SELECT DATE(tk.KELUAR) TANGGAL
					, 3 ID
					, 'Pasien Keluar' DESKRIPSI
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)','PBI APBD' 
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)','PBI APBN'
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU','NON PBI(MANDIRI)'
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),'NON PBI (NON MANDIRI)','NON JKN')))) CARABAYAR
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBD)',1
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PBI (APBN)',2
					, IF(pj.JENIS=2 AND bp.nmJenisPeserta='PEKERJA SEKTOR INFORMAL INDIVIDU',3
					, IF(pj.JENIS=2 AND (bp.nmJenisPeserta IS NULL OR bp.nmJenisPeserta NOT IN ('PBI (APBD)' ,'PBI (APBN)','PEKERJA SEKTOR INFORMAL INDIVIDU')),4,5)))) IDCARABAYAR
					, COUNT(tk.NOMOR) VALUE
					, MAX(tk.MASUK) LASTUPDATED
				FROM pendaftaran.pendaftaran pd
					  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
					  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND pj.JENIS=kap.JENIS AND pj.JENIS=2
					  LEFT JOIN bpjs.peserta bp ON pd.NORM=bp.norm AND pj.JENIS=2 AND kap.NOMOR=bp.noKartu
					, pendaftaran.kunjungan tk
					, master.ruangan jkr
					  LEFT JOIN master.ruangan su ON su.ID=jkr.ID AND su.JENIS=5
					, layanan.pasien_pulang pp		 
				WHERE pd.NOMOR=tk.NOPEN AND pd.STATUS IN (1,2) AND tk.STATUS IN (1,2) 
						AND tk.RUANGAN=jkr.ID AND jkr.JENIS=5 AND jkr.JENIS_KUNJUNGAN=3 AND pp.TANGGAL=tk.KELUAR AND pp.`STATUS`!=0
						AND pp.KUNJUNGAN=tk.NOMOR AND tk.KELUAR BETWEEN VTGL_AWAL AND VTGL_AKHIR
				GROUP BY DATE(tk.KELUAR), IDCARABAYAR	
		) A;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
		OPEN CR_EXEC;
						
		EXIT_EXEC: LOOP
			FETCH CR_EXEC INTO VTANGGAL, VID, VDESKRIPSI, VCARABAYAR, VIDCARABAYAR, VVALUE, VLASTUPDATED;								
							
			IF EXEC_NOT_FOUND THEN
				LEAVE EXIT_EXEC;
			END IF;
			
			IF EXISTS(SELECT 1 FROM informasi.pasien_rawat_inap WHERE TANGGAL = VTANGGAL AND ID = VID AND IDCARABAYAR = VIDCARABAYAR) THEN
				UPDATE informasi.pasien_rawat_inap
				   SET VALUE = VVALUE, LASTUPDATED = VLASTUPDATED
				  WHERE TANGGAL = VTANGGAL AND ID = VID AND IDCARABAYAR = VIDCARABAYAR;
			ELSE
				INSERT INTO informasi.pasien_rawat_inap(TANGGAL, ID, DESKRIPSI, CARABAYAR, IDCARABAYAR, VALUE, LASTUPDATED)
					  VALUES (VTANGGAL, VID, VDESKRIPSI, VCARABAYAR, VIDCARABAYAR, VVALUE, VLASTUPDATED);
			END IF;
		END LOOP;
		
		CLOSE CR_EXEC;
	END;		
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
