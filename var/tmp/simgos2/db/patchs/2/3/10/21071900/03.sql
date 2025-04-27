USE kemkes;
DROP PROCEDURE IF EXISTS `executeTempatTidurRSOnline`;
DELIMITER //
CREATE PROCEDURE `executeTempatTidurRSOnline`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
   DECLARE VTGL_AKHIR DATETIME;
  
   SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
   SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
  
	BEGIN
		DROP TEMPORARY TABLE IF EXISTS TEMP_TT_ONLINE_HASIL;  
     
     	CREATE TEMPORARY TABLE TEMP_TT_ONLINE_HASIL ENGINE=MEMORY
      	SELECT id_tt
	       		 , ruang
			       , COUNT(DISTINCT(idruang)) jumlah_ruang
			       , SUM(jumlah) jumlah
			       , SUM(terpakai) terpakai
			       , covid
			       , antrian
			  FROM (
				SELECT kso.tempat_tidur id_tt
				       , IF(kso.covid = 1, '', ttk.SUBUNIT) ruang
				       , ttk.IDSUBUNIT idruang
				       , (ttk.TTLAKI + ttk.TTPEREMPUAN) jumlah
				       , (ttk.JMLLAKI + ttk.JMLPEREMPUAN) terpakai
				       , kso.covid
				       , IF(kso.covid = 1, kso.tempat_tidur, CONCAT(ttk.IDSUBUNIT, kso.tempat_tidur)) data_group
				       , pendaftaran.getJumlahAntrianTempatTidur(ttk.IDSUBUNIT) antrian
				  FROM informasi.tempat_tidur_kemkes ttk,
				  		 kemkes.kamar_simrs_rs_online kso
				 WHERE kso.ruang_kamar = ttk.IDKAMAR
				   AND kso.tempat_tidur != 0
					AND kso.`status` = 1
					AND ttk.LASTUPDATED BETWEEN VTGL_AWAL AND VTGL_AKHIR
			) tt
			GROUP BY data_group;      
   END;
  
  	BEGIN    
	    DECLARE VIDTT TINYINT;
	    DECLARE VRUANG VARCHAR(1000);
	    DECLARE VJUMLAH_RUANGAN SMALLINT;
	    DECLARE VJUMLAH SMALLINT;
	    DECLARE VTERPAKAI SMALLINT;
	    DECLARE VANTRIAN SMALLINT;
	    
	    DECLARE VCOVID TINYINT;
	    
	    DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;    
	    DECLARE CR_EXEC_DATA CURSOR FOR 
	      SELECT id_tt
				  , ruang
	           , jumlah_ruang
	           , jumlah
	           , terpakai
	           , covid
	           , antrian
	        FROM TEMP_TT_ONLINE_HASIL;      
	    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	            
	    OPEN CR_EXEC_DATA;
	            
	    EXIT_EXEC: LOOP
	      FETCH CR_EXEC_DATA INTO 
				VIDTT
				, VRUANG
				, VJUMLAH_RUANGAN
				, VJUMLAH
				, VTERPAKAI
				, VCOVID
				, VANTRIAN;
	      
	      IF DATA_NOT_FOUND THEN
	      	UPDATE temp.temp SET ID = 0 WHERE ID = 0;
	        LEAVE EXIT_EXEC;
	      END IF;                  
	            
	      IF EXISTS(SELECT 1 FROM kemkes.data_tempat_tidur WHERE id_tt = VIDTT AND ruang = VRUANG) THEN
	        UPDATE kemkes.data_tempat_tidur 
	           SET jumlah_ruang = VJUMLAH_RUANGAN
				  		, jumlah = VJUMLAH
						, terpakai = VTERPAKAI
						, covid = VCOVID
						, antrian = VANTRIAN
						, kirim = 1
	          WHERE id_tt = VIDTT AND ruang = VRUANG;
	      ELSE
	        REPLACE INTO kemkes.data_tempat_tidur(
			  		id_tt, ruang, jumlah_ruang, jumlah, terpakai, covid, antrian
				)VALUES (
					VIDTT, VRUANG, VJUMLAH_RUANGAN, VJUMLAH, VTERPAKAI, VCOVID, VANTRIAN
				);
	      END IF;
	    END LOOP;    
	    CLOSE CR_EXEC_DATA;
	END;    
END//
DELIMITER ;