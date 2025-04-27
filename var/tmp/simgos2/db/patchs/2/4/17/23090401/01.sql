-- Dumping database structure for bpjs
USE `bpjs`;

-- Dumping structure for procedure bpjs.RencanaKontrol
DROP PROCEDURE IF EXISTS `RencanaKontrol`;
DELIMITER //
CREATE PROCEDURE `RencanaKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SET lc_time_names = 'id_ID';
	SELECT *
	FROM (
SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT, inst.BPJS KODEBPJS
		 , jk.NOMOR , pj.JENIS IDPENJAMIN
		 , CONCAT(pst.noKartu, '  ( MR. ',p.NORM,' )') NOMORKARTU, pst.norm NORMBPJS, pst.noKartu NOBPJS
		 , pst.nmJenisPeserta PESERTA, CONCAT(pst.nama,'  (',IF(pst.sex='L','Laki-laki','Perempuan'),')') NAMALENGKAP1
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE_FORMAT(jk.DIBUAT_TANGGAL,'%d %M %Y'),DATE_FORMAT(pri.DIBUAT_TANGGAL,'%d %M %Y')) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drk.NIP),master.getNamaLengkapPegawai(drso.NIP)) DOKTER
	    , IFNULL(drk.NIP,drso.NIP) NIP
	    , bpjs.getDPJP(drpj.DPJP_PENJAMIN) DRSEP
	    , bpjs.getDPJP(drtj.DPJP_PENJAMIN) DRKONTROL
	    , pbpjs.nama SPESIALISTIK
	    , IFNULL(smf.DESKRIPSI,smfso.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING
	    , IF(dg.ID IS NULL, CONCAT(dms.CODE,'- ',dms.STR), `master`.getICD10(dg.KODE)) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL1
		 , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'),' & Estimasi Jam Pelayanan ',
		    IFNULL((SELECT
		                CONCAT(
		                    IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '11:00',
		                        '12:00 - 15:00',
		                        IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '09:00',
		                            '10:00 - 12:00',
		                            IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '07:00',
		                                '08:00 - 10:00',
		                                '08:00 - 10:00'))))
		            FROM regonline.reservasi r
		            WHERE r.TANGGALKUNJUNGAN = jk.TANGGAL
		                AND r.ID = jk.NOMOR_BOOKING
		           --     AND r.STATUS != 0
		            LIMIT 1),'Belum ada, Silahkan ambil antrian')) AS JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, CONCAT(pri.INDIKASI,'\n',pri.DESKRIPSI) KETSO, jk.DESKRIPSI KET
	    , IF(rkbpjs.noSurat IS NULL, DATE_FORMAT(rkbpjs1.tglRencanaKontrol, '%d %M %Y'), DATE_FORMAT(rkbpjs.tglRencanaKontrol, '%d %M %Y')) JADWALBPJS
	    , DATE_FORMAT(jk.DIBUAT_TANGGAL, '%m') BLN, DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y') THN
	    , rt.DESKRIPSI RENCANA_TERAPI, rk.JENIS_KUNJUNGAN
		 , IF(jk.RUANGAN IS NULL, 
			  IFNULL(pri.NOMOR_REFERENSI, 'Nomor Surat BPJS Wajib diterbitkan'),
			   IF(IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat) IS NULL,
			      IF(rk.JENIS_KUNJUNGAN = 3, 'Pasca Ranap wajib terbit nomor surat kontrol BPJS',
			         IF(bpn.kode = pss.SUB_SPESIALIS_PENJAMIN, 'Nomor Surat BPJS Wajib diterbitkan',
			            IF(`master`.getJenisKunjunganSebelumnya(p.NORM, p.TANGGAL)=3, 'NOMOR SURAT BPJS TIDAK TERBIT,\nKunjungan 1 Kali Pasca Rawat Inap sudah digunakan,\nSilahkan buat surat kontrol dari Kunjungan Rawat jalan terakhir sebelum Rawat Inap (Jika Rujukan Masih Aktif),\natau Pasien dikembalikan ke Faskes Awal untuk mengambil rujukan baru'
								, jk.NOMOR_REFERENSI
							--	, CONCAT('K', inst.BPJS, DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)
							  )
			         )
			      ),
			      IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat)
			   )
			) NOSBPJS	 
	    , IF(jk.RUANGAN IS NULL, CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR), CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)) NOSURAT
	    , IF(jk.RUANGAN IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(jk.RUANGAN IS NULL, 1 , 2) JENISKONTROL
	    , IF(rk.JENIS_KUNJUNGAN=3,pj.NOMOR,IFNULL(bk.noRujukan,'')) NORJK
		 , IF(rk.JENIS_KUNJUNGAN=3,DATE_FORMAT(p.TANGGAL,'%d-%m-%Y'),IFNULL(DATE_FORMAT(bk.tglRujukan, '%d-%m-%Y'),'')) TGLRJK
		 , IF(rk.JENIS_KUNJUNGAN!=3,DATE_FORMAT(DATE_ADD(IFNULL(bk.tglRujukan,srp.TANGGAL), INTERVAL 90 DAY), '%d-%m-%Y'),'1 Kali pada kunjungan pertama Setelah Rawat Inap') MASABERLAKU
		 , IF(rk.JENIS_KUNJUNGAN!=3,srp.BAGIAN_DOKTER,smf.DESKRIPSI) TUJUANRUJUK, bpn.nama, bpn.kode
		 , jrp.DESKRIPSI JENIS_RUANG_PERAWATAN, jp.DESKRIPSI JENIS_PERAWATAN
		 , (SELECT CONCAT(IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '11:00',
					'12:00 - 15:00'
						, IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '09:00',
							'10:00 - 12:00'
								, IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '07:00',
									'08:00 - 10:00'
										, '08:00 - 10:00'
										)
									)
								)
							)  
			FROM regonline.reservasi r 
			WHERE r.TANGGALKUNJUNGAN=jk.TANGGAL AND r.NORM=p.NORM AND r.`STATUS`=1
			LIMIT 1) JAM_PELAYANAN
	    FROM pendaftaran.kunjungan k
	    LEFT JOIN master.dokter drso ON drso.ID=k.DPJP
	    LEFT JOIN master.dokter_smf ds ON ds.DOKTER=drso.ID
	    LEFT JOIN master.referensi smfso ON smfso.ID=ds.SMF AND smfso.JENIS=26
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
  		 LEFT JOIN `master`.ruangan r ON jk.RUANGAN = r.ID
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.dokter drk ON drk.ID=drtj.DPJP_RS
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN bpjs.poli pbpjs ON pss.SUB_SPESIALIS_PENJAMIN=pbpjs.kode      
  		 LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0
  		 LEFT JOIN master.referensi jrp ON pri.JENIS_RUANG_PERAWATAN=jrp.ID AND jrp.JENIS=242
  		 LEFT JOIN master.referensi jp ON pri.JENIS_PERAWATAN=jp.ID AND jp.JENIS=243  		 
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs ON jk.NOMOR_REFERENSI=rkbpjs.noSurat AND rkbpjs.`status` !=0
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs1 ON pri.NOMOR_REFERENSI=rkbpjs1.noSurat AND rkbpjs1.`status` !=0
  		 LEFT JOIN `master`.ruangan rk ON k.RUANGAN = rk.ID
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON bk.noRujukan=srp.NOMOR AND srp.NORM=p.NORM
       LEFT JOIN bpjs.poli bpn ON srp.BAGIAN_DOKTER=bpn.nama
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_2020','ICD10_1998') AND dms.TTY !='HT' AND dms.TTY !='PS'
       LEFT JOIN medicalrecord.diagnosa dg ON p.NOMOR=dg.NOPEN AND dg.UTAMA=1 AND dg.INA_GROUPER=0 AND dg.`STATUS`!=0
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER
       LEFT JOIN penjamin_rs.dpjp drpj ON dr.ID=drpj.DPJP_RS AND drpj.PENJAMIN=2
    
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT, mp.BPJS
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2
	GROUP BY k.NOMOR
	UNION ALL
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT, inst.BPJS KODEBPJS
		 , jk.NOMOR , pj.JENIS IDPENJAMIN
		 , CONCAT(pst.noKartu, '  ( MR. ',p.NORM,' )') NOMORKARTU, pst.norm NORMBPJS, pst.noKartu NOBPJS
		 , pst.nmJenisPeserta PESERTA, CONCAT(pst.nama,'  (',IF(pst.sex='L','Laki-laki','Perempuan'),')') NAMALENGKAP1
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE_FORMAT(pri.DIBUAT_TANGGAL,'%d %M %Y'),DATE_FORMAT(jk.DIBUAT_TANGGAL,'%d %M %Y')) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drso.NIP),master.getNamaLengkapPegawai(drk.NIP)) DOKTER
	    , IFNULL(drso.NIP,drk.NIP) NIP
	    , bpjs.getDPJP(drpj.DPJP_PENJAMIN) DRSEP
	    , bpjs.getDPJP(drtj.DPJP_PENJAMIN) DRKONTROL
	    , pbpjs.nama SPESIALISTIK
	    , IFNULL(smfso.DESKRIPSI,smf.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING	   
	    , IF(dg.ID IS NULL, CONCAT(dms.CODE,'- ',dms.STR), `master`.getICD10(dg.KODE)) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL1
		 , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'),' & Estimasi Jam Pelayanan ',
		    IFNULL((SELECT
		                CONCAT(
		                    IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '11:00',
		                        '12:00 - 15:00',
		                        IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '09:00',
		                            '10:00 - 12:00',
		                            IF(DATE_FORMAT(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN, ':00'), '%H:%i:%s'), '%H:00') > '07:00',
		                                '08:00 - 10:00',
		                                '08:00 - 10:00'))))
		            FROM regonline.reservasi r
		            WHERE r.TANGGALKUNJUNGAN = jk.TANGGAL
		                AND r.ID = jk.NOMOR_BOOKING
		           --     AND r.STATUS != 0
		            LIMIT 1),'Belum ada, Silahkan ambil antrian')) AS JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, CONCAT(pri.INDIKASI,'\n',pri.DESKRIPSI) KETSO, jk.DESKRIPSI KET
	    , IF(rkbpjs.noSurat IS NULL, DATE_FORMAT(rkbpjs1.tglRencanaKontrol, '%d %M %Y'), DATE_FORMAT(rkbpjs.tglRencanaKontrol, '%d %M %Y')) JADWALBPJS
	    , DATE_FORMAT(jk.DIBUAT_TANGGAL, '%m') BLN, DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y') THN
	    , rt.DESKRIPSI RENCANA_TERAPI, rk.JENIS_KUNJUNGAN
		 , IF(pri.KUNJUNGAN IS NULL, 
		 	  IF(IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat) IS NULL,
			      IF(rk.JENIS_KUNJUNGAN = 3, 'Pasca Ranap wajib terbit nomor surat kontrol BPJS',
			         IF(bpn.kode = pss.SUB_SPESIALIS_PENJAMIN, 'Nomor Surat BPJS Wajib diterbitkan',
			            IF(`master`.getJenisKunjunganSebelumnya(p.NORM, p.TANGGAL)=3, 'NOMOR SURAT BPJS TIDAK TERBIT,\nKunjungan 1 Kali Pasca Rawat Inap sudah digunakan,\nSilahkan buat surat kontrol dari Kunjungan Rawat jalan terakhir sebelum Rawat Inap (Jika Rujukan Masih Aktif),\natau Pasien dikembalikan ke Faskes Awal untuk mengambil rujukan baru'
								, CONCAT('K', inst.BPJS, DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR))
			         )
			      ),
			      IF(rkbpjs.noSurat IS NULL, rkbpjs1.noSurat, rkbpjs.noSurat)
			   ),
			  IFNULL(pri.NOMOR_REFERENSI, 'Nomor Surat BPJS Wajib diterbitkan')
			   
			) NOSBPJS	 
	    , IF(pri.KUNJUNGAN IS NULL,  CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR),CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR)) NOSURAT
	    , IF(pri.KUNJUNGAN IS NULL, 'SURAT RENCANA KONTROL', 'SURAT RENCANA INAP' ) HEADERBPJS
	    , IF(pri.KUNJUNGAN IS NULL, 2 , 1) JENISKONTROL
	    , IF(rk.JENIS_KUNJUNGAN=3,pj.NOMOR,IFNULL(bk.noRujukan,'')) NORJK
		 , IF(rk.JENIS_KUNJUNGAN=3,DATE_FORMAT(p.TANGGAL,'%d-%m-%Y'),IFNULL(DATE_FORMAT(bk.tglRujukan, '%d-%m-%Y'),'')) TGLRJK
		 , IF(rk.JENIS_KUNJUNGAN!=3,DATE_FORMAT(DATE_ADD(IFNULL(bk.tglRujukan,srp.TANGGAL), INTERVAL 90 DAY), '%d-%m-%Y'),'1 Kali pada kunjungan pertama Setelah Rawat Inap') MASABERLAKU
		 , IF(rk.JENIS_KUNJUNGAN!=3,srp.BAGIAN_DOKTER,smf.DESKRIPSI) TUJUANRUJUK, bpn.nama, bpn.kode
		 , jrp.DESKRIPSI JENIS_RUANG_PERAWATAN, jp.DESKRIPSI JENIS_PERAWATAN
		 , (SELECT CONCAT(IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '11:00',
					'12:00 - 15:00'
						, IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '09:00',
							'10:00 - 12:00'
								, IF(date_format(STR_TO_DATE(CONCAT(r.JAM_PELAYANAN,':00'),'%H:%i:%s'),'%H:00') > '07:00',
									'08:00 - 10:00'
										, '08:00 - 10:00'
										)
									)
								)
							)  
			FROM regonline.reservasi r 
			WHERE r.TANGGALKUNJUNGAN=jk.TANGGAL AND r.NORM=p.NORM AND r.`STATUS`=1
			LIMIT 1) JAM_PELAYANAN
	    FROM pendaftaran.kunjungan k
	    LEFT JOIN master.dokter drso ON drso.ID=k.DPJP
	    LEFT JOIN master.dokter_smf ds ON ds.DOKTER=drso.ID
	    LEFT JOIN master.referensi smfso ON smfso.ID=ds.SMF AND smfso.JENIS=26
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
  		 LEFT JOIN `master`.ruangan r ON jk.RUANGAN = r.ID
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.dokter drk ON drk.ID=drtj.DPJP_RS
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN bpjs.poli pbpjs ON pss.SUB_SPESIALIS_PENJAMIN=pbpjs.kode      
  		 LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0
  		 LEFT JOIN master.referensi jrp ON pri.JENIS_RUANG_PERAWATAN=jrp.ID AND jrp.JENIS=242
  		 LEFT JOIN master.referensi jp ON pri.JENIS_PERAWATAN=jp.ID AND jp.JENIS=243  		 
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs ON jk.NOMOR_REFERENSI=rkbpjs.noSurat AND rkbpjs.`status` !=0
  		 LEFT JOIN bpjs.rencana_kontrol rkbpjs1 ON pri.NOMOR_REFERENSI=rkbpjs1.noSurat AND rkbpjs1.`status` !=0
  		 LEFT JOIN `master`.ruangan rk ON k.RUANGAN = rk.ID
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN pendaftaran.surat_rujukan_pasien srp ON bk.noRujukan=srp.NOMOR AND srp.NORM=p.NORM
       LEFT JOIN bpjs.poli bpn ON srp.BAGIAN_DOKTER=bpn.nama
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_2020','ICD10_1998') AND dms.TTY !='HT' AND dms.TTY !='PS'
       LEFT JOIN medicalrecord.diagnosa dg ON p.NOMOR=dg.NOPEN AND dg.UTAMA=1 AND dg.INA_GROUPER=0 AND dg.`STATUS`!=0
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER
       LEFT JOIN penjamin_rs.dpjp drpj ON dr.ID=drpj.DPJP_RS AND drpj.PENJAMIN=2
    
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT, mp.BPJS
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2
	GROUP BY k.NOMOR
	) ab
GROUP BY JENISKONTROL
	;
 END//
DELIMITER ;


-- Dumping database structure for master
CREATE DATABASE IF NOT EXISTS `master`;
USE `master`;

-- Dumping structure for function master.getJenisKunjunganSebelumnya
DROP FUNCTION IF EXISTS `getJenisKunjunganSebelumnya`;
DELIMITER //
CREATE FUNCTION `getJenisKunjunganSebelumnya`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TINYINT;
   
   SELECT r.JENIS_KUNJUNGAN INTO HASIL 
    FROM pendaftaran.pendaftaran pd
      , pendaftaran.tujuan_pasien tp
      , master.ruangan r
      , pendaftaran.kunjungan k
    WHERE pd.NORM=PNORM AND pd.TANGGAL < PTANGGAL
	 AND pd.STATUS!=0 AND pd.NOMOR=tp.NOPEN
      AND tp.RUANGAN=r.ID 
      AND pd.NOMOR=k.NOPEN AND k.REF IS NULL AND k.STATUS!=0
   ORDER BY pd.TANGGAL DESC
   LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;


-- Dumping database structure for medicalrecord
CREATE DATABASE IF NOT EXISTS `medicalrecord`;
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.cetakSuratKontrol
DROP PROCEDURE IF EXISTS `cetakSuratKontrol`;
DELIMITER //
CREATE PROCEDURE `cetakSuratKontrol`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	SELECT inst.PPK ID_PPK, UPPER(inst.NAMA) NAMA_INSTANSI, inst.KOTA, inst.ALAMAT
		 , pj.JENIS IDPENJAMIN
		 , CONCAT(IF(ps.GELAR_DEPAN='' OR ps.GELAR_DEPAN IS NULL,'',CONCAT(ps.GELAR_DEPAN,'. ')),UPPER(ps.NAMA),IF(ps.GELAR_BELAKANG='' OR ps.GELAR_BELAKANG IS NULL,'',CONCAT(', ',ps.GELAR_BELAKANG))) NAMA_LENGKAP
	    , DATE_FORMAT(ps.TANGGAL_LAHIR,'%d %M %Y') TANGGAL_LAHIR
	    , LPAD(ps.NORM, 8, '0') NORM
	    , IFNULL(DATE(jk.DIBUAT_TANGGAL),DATE(pri.DIBUAT_TANGGAL)) DIBUAT_TANGGAL
	    , r.DESKRIPSI RUANGAN
	    , IFNULL(master.getNamaLengkapPegawai(drk.NIP),master.getNamaLengkapPegawai(drso.NIP)) DOKTER
	    , IFNULL(drk.NIP,drso.NIP) NIP
	    , IFNULL(smf.DESKRIPSI,smfso.DESKRIPSI) SMF
	    , d.DIAGNOSIS, jk.NOMOR_ANTRIAN, jk.NOMOR_BOOKING
	    , IF(master.getDiagnosa(p.NOMOR, 1) IS NULL,CONCAT(dms.CODE,' (',dms.STR,')'),CONCAT(master.getKodeDiagnosa(p.NOMOR,1),master.getDiagnosa(p.NOMOR, 1))) DIAGMASUK
	    , CONCAT(DATE_FORMAT(jk.TANGGAL, '%d-%m-%Y'), ' & ', jk.JAM) JADWAL_KONTROL
	    , CONCAT(DATE_FORMAT(pri.TANGGAL, '%d-%m-%Y')) TGLSO, CONCAT(pri.INDIKASI,'\n',pri.DESKRIPSI) KETSO, jk.DESKRIPSI KET
	    , rt.DESKRIPSI rencana_terapi, pri.INDIKASI
	    , IF(jk.RUANGAN IS NULL, CONCAT(DATE_FORMAT(pri.DIBUAT_TANGGAL, '%Y'),pri.NOMOR), CONCAT(DATE_FORMAT(jk.DIBUAT_TANGGAL, '%Y'), jk.NOMOR)) NOSURAT
	    , IF(jk.RUANGAN IS NULL, 'SURAT RENCANA INAP' , 'SURAT RENCANA KONTROL') HEADERBPJS
	    , IF(jk.RUANGAN IS NULL, 1 , 2) JENISKONTROL
	    , jrp.DESKRIPSI JENIS_RUANG_PERAWATAN, jp.DESKRIPSI JENIS_PERAWATAN
	    FROM pendaftaran.kunjungan k
	    LEFT JOIN master.dokter drso ON drso.ID=k.DPJP
	    LEFT JOIN master.dokter_smf ds ON ds.DOKTER=drso.ID
	    LEFT JOIN master.referensi smfso ON smfso.ID=ds.SMF AND smfso.JENIS=26
  		 LEFT JOIN medicalrecord.jadwal_kontrol jk ON k.NOMOR = jk.KUNJUNGAN AND jk.`STATUS` !=0
  		 LEFT JOIN `master`.ruangan r ON jk.RUANGAN = r.ID
       LEFT JOIN penjamin_rs.dpjp drtj ON jk.DOKTER=drtj.DPJP_RS AND drtj.PENJAMIN=2
       LEFT JOIN master.dokter drk ON drk.ID=drtj.DPJP_RS
       LEFT JOIN master.referensi smf ON jk.TUJUAN=smf.ID AND smf.JENIS=26
       LEFT JOIN master.penjamin_sub_spesialistik pss ON pss.SUB_SPESIALIS_RS=smf.ID AND pss.PENJAMIN=2
       LEFT JOIN medicalrecord.diagnosis d ON d.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.rencana_terapi rt ON rt.KUNJUNGAN = k.NOMOR
  		 LEFT JOIN medicalrecord.perencanaan_rawat_inap pri ON k.NOMOR=pri.KUNJUNGAN AND pri.`STATUS` !=0  
		 LEFT JOIN master.referensi jrp ON pri.JENIS_RUANG_PERAWATAN=jrp.ID AND jrp.JENIS=242
  		 LEFT JOIN master.referensi jp ON pri.JENIS_PERAWATAN=jp.ID AND jp.JENIS=243 		
       , pendaftaran.pendaftaran p
       LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND kap.JENIS=2
       LEFT JOIN bpjs.peserta pst ON kap.NOMOR=pst.noKartu
       LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
       LEFT JOIN bpjs.kunjungan bk ON pj.NOMOR=bk.noSEP
       LEFT JOIN master.diagnosa_masuk dm ON p.DIAGNOSA_MASUK=dm.ID
       LEFT JOIN master.mrconso dms ON dm.ICD = dms.CODE AND dms.SAB IN ('ICD10_1998','ICD10_2020') AND dms.TTY !='HT' AND dms.TTY !='PS'
       , pendaftaran.tujuan_pasien tp
       LEFT JOIN master.dokter dr ON dr.ID=tp.DOKTER       
       , `master`.pasien ps
       , (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
 WHERE k.NOMOR = PKUNJUNGAN
   AND p.NOMOR = k.NOPEN
   AND ps.NORM = p.NORM
   AND tp.NOPEN = p.NOMOR
	AND tp.`STATUS`= 2
	GROUP BY k.NOMOR;
 END//
DELIMITER ;