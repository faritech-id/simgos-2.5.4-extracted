USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakAsuhanKeperawatan
DELIMITER //
CREATE PROCEDURE `CetakAsuhanKeperawatan`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT pd.NORM, k.NOPEN, k.NOMOR KUNJUNGAN 
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, sbj.SUBJECKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.SUBJECKTIF,
				         "$[*]"
				         COLUMNS(
				           SUBJECKTIF VARCHAR(250) PATH "$"
				         )
				       ) sbj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON sbj.SUBJECKTIF=ik.ID AND ik.JENIS=1
				WHERE kp.KUNJUNGAN=k.NOMOR),'') SUBJEKTIF
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obj.OBJEKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBJEKTIF,
				         "$[*]"
				         COLUMNS(
				           OBJEKTIF VARCHAR(250) PATH "$"
				         )
				       ) obj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obj.OBJEKTIF=ik.ID AND ik.JENIS=2
				WHERE kp.KUNJUNGAN=k.NOMOR),'') OBJEKTIF
			#, IFNULL(dk.DESKRIPSI,'') DIAGNOSA_KEPERAWATAN
			,IFNULL(REPLACE(GROUP_CONCAT(DISTINCT(dk.DESKRIPSI) SEPARATOR ';'),';','\r'),'') DIAGNOSA_KEPERAWATAN
			#, IFNULL(tj.DESKRIPSI,'') TUJUAN
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL( ik.DESKRIPSI, kp.DESK_TUJUAN)) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kp.TUJUAN=ik.ID AND ik.JENIS=4
				WHERE kp.KUNJUNGAN=k.NOMOR
				),'') TUJUAN
			, IFNULL(iv.DESKRIPSI,'') INTERVENSI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, pyb.PENYEBAB) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.PENYEBAP,
				         "$[*]"
				         COLUMNS(
				           PENYEBAB VARCHAR(250) PATH "$"
				         )
				       ) pyb
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON pyb.PENYEBAB=ik.ID AND ik.JENIS=3
				WHERE kp.KUNJUNGAN=k.NOMOR),'') PENYEBAB	
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR),'') OBSERVASI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR),'') THEURAPEUTIC
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR),'') EDUKASI
			, IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR),'') KOLABORASI
			 , CONCAT('INTERVENSI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(DISTINCT(IFNULL( ik.DESKRIPSI, kp.DESK_INTERVENSI)) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kp.INTERVENSI=ik.ID AND ik.JENIS=5
				WHERE kp.KUNJUNGAN=k.NOMOR  
				),''),'\r',
			 	'OBSERVASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',				
				'THEURAPEUTIC : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',				
				'EDUKASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR),''),'\r',
			 	'KOLABORASI : ',IFNULL((SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR),'')) RENCANA
		FROM pendaftaran.kunjungan k
		     , medicalrecord.asuhan_keperawatan ak 
		     LEFT JOIN medicalrecord.diagnosa_keperawatan dk ON ak.DIAGNOSA=dk.ID
		     LEFT JOIN medicalrecord.indikator_keperawatan tj ON ak.TUJUAN=tj.ID AND tj.JENIS=4
		     LEFT JOIN medicalrecord.indikator_keperawatan iv ON ak.INTERVENSI=iv.ID AND iv.JENIS=5
			, pendaftaran.pendaftaran pd
		WHERE pd.NOMOR=PNOPEN AND k.NOPEN=pd.NOMOR AND k.`STATUS`!=0 AND pd.`STATUS`!=0
			AND k.NOMOR=ak.KUNJUNGAN AND ak.`STATUS`=2
		ORDER BY ak.TANGGAL ASC
		LIMIT 1
		;
END//
DELIMITER ;