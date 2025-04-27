USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakAsuhanKeperawatanDetail
DROP PROCEDURE IF EXISTS `CetakAsuhanKeperawatanDetail`;
DELIMITER //
CREATE PROCEDURE `CetakAsuhanKeperawatanDetail`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	SELECT LPAD(pd.NORM,8,'0') NORM, `master`.getNamaLengkap(ps.NORM) NAMALENGKAP
	, DATE_FORMAT(ps.TANGGAL_LAHIR,'%d-%m-%Y') TGLLAHIR, IF(ps.JENIS_KELAMIN=1,'Laki-laki','Perempuan') JK
	, k.NOPEN, `master`.getNamaLengkapPegawai(pr.NIP) PERAWAT, k.NOMOR KUNJUNGAN, ru.DESKRIPSI RUANGAN, DATE_FORMAT(ak.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGAL 
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, sbj.SUBJECKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.SUBJECKTIF,
				         "$[*]"
				         COLUMNS(
				           SUBJECKTIF VARCHAR(250) PATH "$"
				         )
				       ) sbj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON sbj.SUBJECKTIF=ik.ID AND ik.JENIS=1
				WHERE kp.KUNJUNGAN=k.NOMOR) SUBJEKTIF
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obj.OBJEKTIF) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBJEKTIF,
				         "$[*]"
				         COLUMNS(
				           OBJEKTIF VARCHAR(250) PATH "$"
				         )
				       ) obj
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obj.OBJEKTIF=ik.ID AND ik.JENIS=2
				WHERE kp.KUNJUNGAN=k.NOMOR) OBJEKTIF
			, IFNULL(dk.DESKRIPSI, ak.DESK_DIAGNOSA) DIAGNOSA_KEPERAWATAN
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, pyb.PENYEBAB) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.PENYEBAP,
				         "$[*]"
				         COLUMNS(
				           PENYEBAB VARCHAR(250) PATH "$"
				         )
				       ) pyb
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON pyb.PENYEBAB=ik.ID AND ik.JENIS=3
				WHERE kp.KUNJUNGAN=k.NOMOR) PENYEBAB
			, tj.DESKRIPSI TUJUAN
			, iv.DESKRIPSI INTERVENSI
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR) OBSERVASI
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR) THEURAPEUTIC
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR) EDUKASI
			, (SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR) KOLABORASI
			 , CONCAT('INTERVENSI : ',iv.DESKRIPSI,'\r',
			 	'OBSERVASI : ',(SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, obs.OBSERVASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.OBSERVASI,
				         "$[*]"
				         COLUMNS(
				           OBSERVASI VARCHAR(250) PATH "$"
				         )
				       ) obs
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON obs.OBSERVASI=ik.ID AND ik.JENIS=6
				WHERE kp.KUNJUNGAN=k.NOMOR),'\r',				
				'THEURAPEUTIC : ',(SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, tr.THEURAPEUTIC) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.THEURAPEUTIC,
				         "$[*]"
				         COLUMNS(
				           THEURAPEUTIC VARCHAR(250) PATH "$"
				         )
				       ) tr
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON tr.THEURAPEUTIC=ik.ID AND ik.JENIS=7
				WHERE kp.KUNJUNGAN=k.NOMOR),'\r',				
				'EDUKASI : ',(SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, ed.EDUKASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.EDUKASI,
				         "$[*]"
				         COLUMNS(
				           EDUKASI VARCHAR(250) PATH "$"
				         )
				       ) ed
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON ed.EDUKASI=ik.ID AND ik.JENIS=8
				WHERE kp.KUNJUNGAN=k.NOMOR),'\r',
			 	'KOLABORASI : ',(SELECT REPLACE(GROUP_CONCAT(IFNULL(ik.DESKRIPSI, kl.KOLABORASI) SEPARATOR ';'),';','\r') 
				     FROM medicalrecord.asuhan_keperawatan kp,
				       JSON_TABLE(kp.KOLABORASI,
				         "$[*]"
				         COLUMNS(
				           KOLABORASI VARCHAR(250) PATH "$"
				         )
				       ) kl
				       LEFT JOIN medicalrecord.indikator_keperawatan ik ON kl.KOLABORASI=ik.ID AND ik.JENIS=9
				WHERE kp.KUNJUNGAN=k.NOMOR)) RENCANA
		FROM pendaftaran.kunjungan k
				LEFT JOIN `master`.ruangan ru ON k.RUANGAN=ru.ID
		     , medicalrecord.asuhan_keperawatan ak 
		     LEFT JOIN medicalrecord.diagnosa_keperawatan dk ON ak.DIAGNOSA=dk.ID
		     LEFT JOIN medicalrecord.indikator_keperawatan tj ON ak.TUJUAN=tj.ID AND tj.JENIS=4
		     LEFT JOIN medicalrecord.indikator_keperawatan iv ON ak.INTERVENSI=iv.ID AND iv.JENIS=5
		     LEFT JOIN aplikasi.pengguna pg ON ak.OLEH=pg.ID
		     LEFT JOIN `master`.perawat pr ON pg.NIP=pr.NIP
			, pendaftaran.pendaftaran pd
			LEFT JOIN `master`.pasien ps ON pd.NORM=ps.NORM
		WHERE pd.NOMOR=PNOPEN AND k.NOPEN=pd.NOMOR AND k.`STATUS`!=0 AND pd.`STATUS`!=0
			AND k.NOMOR=ak.KUNJUNGAN AND ak.`STATUS`!=0
		ORDER BY ak.TANGGAL ASC
		 LIMIT 1
		;
END//
DELIMITER ;