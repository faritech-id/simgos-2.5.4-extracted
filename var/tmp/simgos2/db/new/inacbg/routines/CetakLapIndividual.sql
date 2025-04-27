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

-- membuang struktur untuk procedure inacbg.CetakLapIndividual
DROP PROCEDURE IF EXISTS `CetakLapIndividual`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakLapIndividual`(IN `PNOPEN` CHAR(10), IN `PKELAS` INT
)
BEGIN 
SET @sqlText = CONCAT('	
	SELECT inst.KODERS, inst.KELASRS, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, p.TANGGAL_LAHIR TANGGAL_LAHIR
		, IF((UNIX_TIMESTAMP(pd.TANGGAL)-UNIX_TIMESTAMP(p.TANGGAL_LAHIR))<691200,0,FLOOR((DATEDIFF(pd.TANGGAL,p.TANGGAL_LAHIR))/365)) as UMURTAHUN
		, DATEDIFF(pd.TANGGAL,p.TANGGAL_LAHIR) as UMURHARI
		, IF(p.JENIS_KELAMIN = 1,''1 - Laki-laki'',''2 - Perempuan'') JENISKELAMIN
		, pd.NOMOR NOPEN, pd.TANGGAL TGLREG
		, IF(r.JENIS_KUNJUNGAN=3, aplikasi.getValuePropertyJSON(gr.DATA,''tgl_keluar'') , pd.TANGGAL) TGLKELUAR
		, CONCAT(DATEDIFF(IF(r.JENIS_KUNJUNGAN=3,aplikasi.getValuePropertyJSON(gr.DATA,''tgl_keluar''),pd.TANGGAL),pd.TANGGAL)+1,'' hari'') LOS
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP
		, IF(r.JENIS_KUNJUNGAN=3,''1 - Rawat Inap'',''2 - Rawat Jalan'') JENISPASIEN
		, IF(r.JENIS_KUNJUNGAN=1,''1 - Sembuh'',(SELECT CONCAT(cb.KODE,'' - '',cb.DESKRIPSI) FROM inacbg.inacbg cb WHERE cb.KODE=aplikasi.getValuePropertyJSON(gr.DATA,''cara_keluar'') AND cb.JENIS=9 AND cb.VERSION=4)) CARAPULANG
		, IF(aplikasi.getValuePropertyJSON(gr.DATA,''berat_lahir'')='''',''-'',aplikasi.getValuePropertyJSON(gr.DATA,''berat_lahir'')) BERATLAHIR
		, IF(r.JENIS_KUNJUNGAN=3,CONCAT(kls.KODE,'' - '',kls.DESKRIPSI), ''3 - Kelas 3'') KELASHAK
		, (SELECT CONCAT(REPLACE(mr.CODE,''.'',''''),'' ('',mr.STR,'')'') 
					FROM master.mrconso mr,
						  medicalrecord.diagnosa md 
					WHERE mr.CODE=md.KODE AND md.UTAMA=1 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
					  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'')
					GROUP BY md.KODE ) DIAGNOSAUTAMA
			, IF((SELECT REPLACE(GROUP_CONCAT(mrcode),'','',''\r'')  
						FROM (SELECT CONCAT(REPLACE(mr.CODE,''.'',''''),'' ('',mr.STR,'')'') mrcode 
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md 
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'')
						GROUP BY mr.CODE) a
					) IS NULL,'''',(SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''\r'')
						FROM (SELECT CONCAT(REPLACE(mr.CODE,''.'',''''),'' ('',mr.STR,'')'') mrcode 
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md 
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'')
						GROUP BY mr.CODE) a
					)) DIAGNOSASEKUNDER
			, (SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''\r'')
						FROM (SELECT CONCAT(REPLACE(mr.CODE,''.'',''''),'' ('',mr.STR,'')'') mrcode  
						FROM master.mrconso mr,
								medicalrecord.prosedur pr 
					WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=''',PNOPEN,'''
					  AND mr.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'')
					GROUP BY pr.KODE) a
					) TINDAKAN
		, IF(aplikasi.getValuePropertyJSON(gr.DATA,''adl'')='''',''0'',aplikasi.getValuePropertyJSON(gr.DATA,''adl'')) ADL
		, hl.CODECBG INACBG
		, kd.DESKRIPSI DESKRIPSIINACBG
		, ''-'' ALOS
		, IF(''',PKELAS,'''=''1'',hl.TARIFKLS1,IF(''',PKELAS,'''=''2'',hl.TARIFKLS2, hl.TARIFCBG)) TARIFINACBG
		, REPLACE(CONCAT(hl.UNUSR,hl.UNUSI,hl.UNUSP, hl.UNUSD, hl.UNUSA),''None'','''') SPECIALPROSEDUR
		, (hl.TARIFSP + hl.TARIFSR + hl.TARIFSI + hl.TARIFSD + hl.TARIFSA) TARIFTOPUP
		, hl.TARIFRS BIAYARS
		, IF(''',PKELAS,'''=''1'',(hl.TARIFKLS1+hl.TARIFSP + hl.TARIFSR + hl.TARIFSI + hl.TARIFSD + hl.TARIFSA)
			,IF(''',PKELAS,'''=''2'',(hl.TARIFKLS2+hl.TARIFSP + hl.TARIFSR + hl.TARIFSI + hl.TARIFSD + hl.TARIFSA), hl.TOTALTARIF))  TOTALTARIFINACBG
		, IF(''',PKELAS,'''=''1'', ''TOTAL TARIF INACBG Kelas 1''
			, IF(''',PKELAS,'''=''2'', ''TOTAL TARIF INACBG Kelas 2''
			, IF(r.JENIS_KUNJUNGAN=3,CONCAT(''TOTAL TARIF INACBG '',kls.DESKRIPSI), ''TOTAL TARIF INACBG Kelas 3''))) CATATAN
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.kunjungan pk ON pd.NOMOR=pk.NOPEN AND pk.`STATUS` IN (1,2)
		  LEFT JOIN layanan.pasien_pulang pp ON pd.NOMOR=pp.NOPEN AND pp.`STATUS` IN (1,2)
		  LEFT JOIN inacbg.map_inacbg_simrs mp ON pp.CARA=mp.SIMRS AND mp.JENIS=2 AND mp.VERSION=4
		  LEFT JOIN inacbg.inacbg cb ON mp.INACBG=cb.KODE AND cb.JENIS=9
		  LEFT JOIN inacbg.map_inacbg_simrs kl ON pj.KELAS=kl.SIMRS AND kl.JENIS=4 AND kl.VERSION=4
		  LEFT JOIN inacbg.inacbg kls ON kl.INACBG=kls.KODE AND kls.JENIS=8
		  LEFT JOIN hasil_grouping hl ON pd.NOMOR=hl.NOPEN
		  LEFT JOIN inacbg.inacbg kd ON hl.CODECBG=kd.KODE AND kd.JENIS=1 AND kd.VERSION=4
		  LEFT JOIN inacbg.grouping gr ON pd.NOMOR=gr.NOPEN
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		, (SELECT mp.KODE KODERS, mp.NAMA, mp.KELAS KELASRS 
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID ) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=''',PNOPEN,'''	
	GROUP BY pd.NOMOR
	');
	   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
