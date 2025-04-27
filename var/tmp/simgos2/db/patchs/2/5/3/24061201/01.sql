-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.CetakCPPT
DROP PROCEDURE IF EXISTS `CetakCPPT`;
DELIMITER //
CREATE PROCEDURE `CetakCPPT`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` VARCHAR(19)
)
BEGIN
  SET @sqlText = CONCAT(
    'SELECT 
        CONCAT(DATE_FORMAT(cp.TANGGAL, ''%d-%m-%Y''), '' \r'', TIME(cp.TANGGAL)) TANGGAL,        
        IF((SELECT r.CONFIG->>''$.dietisen'' 
            FROM master.referensi r 
            WHERE r.JENIS = 32 AND r.ID = cp.JENIS) = ''true'',
            CONCAT(''A/: '', master.remove_html_tags(master.getReplaceFont(cp.SUBYEKTIF)), '' \r'',
                   ''D/: '', master.remove_html_tags(master.getReplaceFont(cp.OBYEKTIF)), '' \r'',
                   ''I/: '', master.remove_html_tags(master.getReplaceFont(cp.ASSESMENT)), '' \r'',
                   ''ME/: '', master.remove_html_tags(master.getReplaceFont(cp.PLANNING))),
            IF(cp.STATUS_SBAR = 1,
            CONCAT(''S/: '', master.remove_html_tags(master.getReplaceFont(cp.SUBYEKTIF)), '' \r'',
                   ''B/: '', master.remove_html_tags(master.getReplaceFont(cp.OBYEKTIF)), '' \r'',
                   ''A/: '', master.remove_html_tags(master.getReplaceFont(cp.ASSESMENT)), '' \r'',
                   ''R/: '', master.remove_html_tags(master.getReplaceFont(cp.PLANNING)), '' \r'',
                   ''Dokter/: '', IFNULL(master.getNamaLengkapPegawai(dc.NIP), '''')),
                IF(cp.STATUS_TBAK = 1,
                CONCAT(''Tulis/: '', master.remove_html_tags(cp.TULIS), '' \r'',
                       ''Baca/: '', IF(cp.BACA = 0, ''Belum Baca'', ''Sudah Baca''), '' \r'',
                       ''Konfirmasi/: '', IF(cp.KONFIRMASI = 0, ''Belum Konfirmasi'', ''Sudah Konfirmasi''), '' \r'',
                       ''Dokter/: '', IFNULL(master.getNamaLengkapPegawai(dc.NIP), '''')),
                CONCAT(''S/: '', master.remove_html_tags(master.getReplaceFont(cp.SUBYEKTIF)), '' \r'',
                       ''O/: '', master.remove_html_tags(master.getReplaceFont(cp.OBYEKTIF)), '' \r'',
                       ''A/: '', master.remove_html_tags(master.getReplaceFont(cp.ASSESMENT)), '' \r'',
                       ''P/: '', master.remove_html_tags(master.getReplaceFont(cp.PLANNING)))))) CATATAN,
        master.remove_html_tags(master.getReplaceFont(cp.INSTRUKSI)) INSTRUKSI,
        IF(ref.REF_ID = ''4'', master.getNamaLengkapPegawai(d.NIP), '''') DOKTER,
        IF(ref.REF_ID = ''6'', master.getNamaLengkapPegawai(pr.NIP), 
        IF(ref.REF_ID NOT IN (''6'', ''4''), master.getNamaLengkapPegawai(p.NIP), '''')) PERAWAT, ref.DESKRIPSI AS JNSPPA,
        CONCAT(IF(ref.REF_ID = ''4'', master.getNamaLengkapPegawai(d.NIP), IF(ref.REF_ID = ''6'', master.getNamaLengkapPegawai(pr.NIP),
        IF(ref.REF_ID NOT IN (''6'', ''4''), master.getNamaLengkapPegawai(p.NIP), ''''))), '' \r'', IF(cp.STATUS_SBAR = 1, ''( SBAR )'', IF(cp.STATUS_TBAK = 1, ''( TBAK )'', ''''))) PPA,
        CONCAT(DATE_FORMAT(vcp.TANGGAL, ''%d-%m-%Y''), '' \r'', TIME(vcp.TANGGAL)) TGLVERIFIKASI,
        master.getNamaLengkapPegawai(vr.NIP) VERIFIKATOR,
        CONCAT(master.getNamaLengkapPegawai(vr.NIP), '' \r'', DATE_FORMAT(vcp.TANGGAL, ''%d-%m-%Y''), '' \r'', TIME(vcp.TANGGAL)) VERIFIKASI,
        IF(cp.STATUS_SBAR = 1,''SBAR'', IF(cp.STATUS_TBAK = 1, ''TBAK'', '''')) TBAK_SBAR
    FROM medicalrecord.cppt cp 
    LEFT JOIN master.referensi ref ON cp.JENIS = ref.ID AND ref.JENIS = 32 
    LEFT JOIN master.pegawai p ON cp.TENAGA_MEDIS = p.ID 
    LEFT JOIN master.dokter d ON cp.TENAGA_MEDIS = d.ID 
    LEFT JOIN master.dokter dc ON cp.DOKTER_TBAK_OR_SBAR = dc.ID 
    LEFT JOIN master.perawat pr ON cp.TENAGA_MEDIS = pr.ID 
    LEFT JOIN medicalrecord.verifikasi_cppt vcp ON cp.VERIFIKASI = vcp.ID 
    LEFT JOIN aplikasi.pengguna vr ON vcp.OLEH = vr.ID 
    LEFT JOIN pendaftaran.kunjungan pk ON cp.KUNJUNGAN = pk.NOMOR 
    WHERE cp.KUNJUNGAN=pk.NOMOR AND pk.STATUS!=0 AND cp.`STATUS`!=0	AND pk.NOPEN=''',PNOPEN,'''
		 ',IF(PKUNJUNGAN = 0 OR PKUNJUNGAN = '''','' , CONCAT(' AND cp.KUNJUNGAN =''',PKUNJUNGAN,'''' )),' 
		  #GROUP BY cp.ID
		  ORDER BY cp.TANGGAL
		  
		  ');

  PREPARE stmt FROM @sqlText;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END//
DELIMITER ;