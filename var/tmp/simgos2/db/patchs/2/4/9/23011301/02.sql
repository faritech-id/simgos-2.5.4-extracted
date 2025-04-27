-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk procedure medicalrecord.CetakMR2Diagnosa
DROP PROCEDURE IF EXISTS `CetakMR2Diagnosa`;
DELIMITER //
CREATE PROCEDURE `CetakMR2Diagnosa`(
	IN `PNOPEN` CHAR(10),
	IN `PUTAMA` TINYINT
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_PROSEDUR;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_FARMASI;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_ALL;
	
	SET @id=0;
	SET @idd=0;
	SET @idf=0;
	SET @iddf=0;
	
	SET @id1=0;
	SET @idd1=0;
	SET @idf1=0;
	SET @iddf1=0;
	
	SET @idg=0;
	
	
	CREATE TEMPORARY TABLE TEMP_DATA ENGINE=MEMORY
	SELECT NOPEN, BARIS, IDDIAGNOSA
		FROM (
		SELECT r.NOPEN, IF(@idd1!=jt.ID,@id1:=1, @id1:=@id1+1) BARIS, @idd1:=jt.ID  IDDIAGNOSA, jt.UTAMA
			  FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
			         '$[*]' COLUMNS(
			                ID INT PATH '$.ID',
			                UTAMA INT PATH '$.UTAMA',
			                NESTED PATH '$.PROSEDUR[*]' 
								 COLUMNS (
			                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
			                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
								  )
			            )   
			       ) AS jt
			WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		UNION ALL
		SELECT r.NOPEN, IF(@iddf1!=jt.ID,@idf1:=1, @idf1:=@idf1+1) BARIS, @iddf1:=jt.ID  IDDIAGNOSA, jt.UTAMA
				     FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_FARMASI,
					         '$[*]' COLUMNS(
					                ID INT PATH '$.ID',
					                UTAMA INT PATH '$.UTAMA',
					                NESTED PATH '$.FARMASI[*]' 
										 COLUMNS (
					                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
					                )
					            )   
					       ) AS jt
		   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		) cd
		GROUP BY IDDIAGNOSA, BARIS;
		
	CREATE TEMPORARY TABLE TEMP_DATA_ALL ENGINE=MEMORY
	SELECT NOPEN, IDDIAGNOSA
		FROM (
		SELECT r.NOPEN, jt.ID  IDDIAGNOSA, jt.UTAMA
			  FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
			         '$[*]' COLUMNS(
			                ID INT PATH '$.ID',
			                UTAMA INT PATH '$.UTAMA',
			                NESTED PATH '$.PROSEDUR[*]' 
								 COLUMNS (
			                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
			                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
								  )
			            )   
			       ) AS jt
			WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		UNION ALL
		SELECT r.NOPEN,  jt.ID  IDDIAGNOSA, jt.UTAMA
				     FROM medicalrecord.`resume` r, 
					        JSON_TABLE(r.DIAGNOSA_FARMASI,
					         '$[*]' COLUMNS(
					                ID INT PATH '$.ID',
					                UTAMA INT PATH '$.UTAMA',
					                NESTED PATH '$.FARMASI[*]' 
										 COLUMNS (
					                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
					                )
					            )   
					       ) AS jt
		   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA
		) cd
		GROUP BY IDDIAGNOSA;
		
	CREATE TEMPORARY TABLE TEMP_DATA_PROSEDUR ENGINE=MEMORY
   SELECT r.NOPEN, IF(@idd!=jt.ID,@id:=1, @id:=@id+1) BARIS, @idd:=jt.ID  IDDIAGNOSA, jt.UTAMA UTAMA, jt.TINDAKANMEDIS, jt.IDPROSEDUR
	  FROM medicalrecord.`resume` r, 
	        JSON_TABLE(r.DIAGNOSA_PROSEDUR,
	         '$[*]' COLUMNS(
	                ID INT PATH '$.ID',
	                UTAMA INT PATH '$.UTAMA',
	                NESTED PATH '$.PROSEDUR[*]' 
						 COLUMNS (
	                	IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR',
	                	TINDAKANMEDIS CHAR(11) PATH '$.TINDAKANMEDIS'
						  )
	            )   
	       ) AS jt
	WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA;
	
   CREATE TEMPORARY TABLE TEMP_DATA_FARMASI ENGINE=MEMORY
   SELECT r.NOPEN, IF(@iddf!=jt.ID,@idf:=1, @idf:=@idf+1) BARIS, @iddf:=jt.ID  IDDIAGNOSA, jt.UTAMA UTAMA, '' TINDAKANMEDIS, jt.IDFARMASI
		     FROM medicalrecord.`resume` r, 
			        JSON_TABLE(r.DIAGNOSA_FARMASI,
			         '$[*]' COLUMNS(
			                ID INT PATH '$.ID',
			                UTAMA INT PATH '$.UTAMA',
			                NESTED PATH '$.FARMASI[*]' 
								 COLUMNS (
			                	IDFARMASI CHAR(11) PATH '$.IDFARMASI'
			                )
			            )   
			       ) AS jt
   WHERE r.NOPEN=PNOPEN AND UTAMA=PUTAMA;
	
			SELECT *
				FROM (
			  	SELECT NOPEN, BARIS, TINDAKANMEDIS, IDPROSEDUR, IDFARMASI
							, IF(@idg!=IDDIAGNOSA,KODE_DIAGNOSA, '') KODE_DIAGNOSA
							, IF(@idg!=IDDIAGNOSA,DESKRIPSI_DIAGNOSA,'') DESKRIPSI_DIAGNOSA, @idg:=IDDIAGNOSA IDDIAGNOSA, DIAGNOSA
							, NAMATINDAKAN, KODE_PROSEDUR, DESKRIPSI_PROSEDUR,  NAMABARANG
							
						FROM (
									SELECT d.NOPEN,  d.BARIS, p.TINDAKANMEDIS, p.IDPROSEDUR, fr.IDFARMASI
											, dg.KODE KODE_DIAGNOSA
											, `master`.getDeskripsiICD(dg.KODE)  DESKRIPSI_DIAGNOSA
											, d.IDDIAGNOSA IDDIAGNOSA
											, dg.DIAGNOSA
											, t.NAMA NAMATINDAKAN, pr.KODE KODE_PROSEDUR, `master`.getDeskripsiICD(pr.KODE) DESKRIPSI_PROSEDUR
											, ib.NAMA NAMABARANG
									  FROM TEMP_DATA d
											 LEFT JOIN TEMP_DATA_PROSEDUR p ON d.IDDIAGNOSA=p.IDDIAGNOSA AND d.BARIS=p.BARIS
											 LEFT JOIN TEMP_DATA_FARMASI fr ON d.IDDIAGNOSA=fr.IDDIAGNOSA AND d.BARIS=fr.BARIS
											 LEFT JOIN layanan.tindakan_medis tm ON p.TINDAKANMEDIS=tm.ID AND tm.`STATUS`!=0
										    LEFT JOIN `master`.tindakan t ON tm.TINDAKAN=t.ID
										    LEFT JOIN medicalrecord.prosedur pr ON p.IDPROSEDUR=pr.ID AND pr.`STATUS`!=0 AND pr.INA_GROUPER=0
										    LEFT JOIN layanan.farmasi f ON fr.IDFARMASI=f.ID AND f.`STATUS`!=0
									   	 LEFT JOIN inventory.barang ib ON f.FARMASI=ib.ID
										    , medicalrecord.diagnosa dg
									WHERE d.IDDIAGNOSA=dg.ID AND dg.`STATUS`!=0 AND dg.INA_GROUPER=0 AND dg.NOPEN=PNOPEN AND dg.UTAMA=PUTAMA AND dg.INACBG=1
									ORDER BY IDDIAGNOSA, BARIS
								) ab 
				UNION ALL
				SELECT ds.NOPEN, 1 BARIS, null TINDAKAMEDIS, null IDPROSEDUR, null IDFARMASI, ds.KODE KODE_DIAGNOSA
					, `master`.getDeskripsiICD(ds.KODE)  DESKRIPSI_DIAGNOSA, ds.ID IDDIAGNOSA, ds.DIAGNOSA
					, null NAMATINDAKAN, null KODE_PROSEDUR, null DESKRIPSI_PROSEDUR, null NAMABARANG
					FROM medicalrecord.diagnosa ds
					WHERE ds.NOPEN=PNOPEN AND ds.UTAMA=PUTAMA AND ds.`STATUS`!=0 AND ds.INA_GROUPER=0 AND ds.INACBG=1
					AND ds.ID NOT IN (SELECT IDDIAGNOSA FROM TEMP_DATA_ALL WHERE IDDIAGNOSA=ds.ID)	
				) cd
	
		
	;	 	 	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
