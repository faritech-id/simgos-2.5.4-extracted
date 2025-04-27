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


-- Membuang struktur basisdata untuk inacbg
USE `inacbg`;

-- membuang struktur untuk procedure inacbg.CetakLapIndividual5
DROP PROCEDURE IF EXISTS `CetakLapIndividual5`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakLapIndividual5`(
	IN `PNOPEN` CHAR(10),
	IN `PKELAS` INT
)
BEGIN 
SET @sqlText = CONCAT('	
	SELECT inst.KODERS, inst.KELASRS, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, p.TANGGAL_LAHIR TANGGAL_LAHIR
		, IF((UNIX_TIMESTAMP(pd.TANGGAL)-UNIX_TIMESTAMP(p.TANGGAL_LAHIR))<691200,0,FLOOR((DATEDIFF(pd.TANGGAL,p.TANGGAL_LAHIR))/365)) as UMURTAHUN
		, DATEDIFF(pd.TANGGAL,p.TANGGAL_LAHIR) as UMURHARI
		, IF(p.JENIS_KELAMIN = 1,''1 - Laki-laki'',''2 - Perempuan'') JENISKELAMIN
		, kap.NOMOR NOKARTU, pd.NOMOR NOPEN, pd.TANGGAL TGLREG
		, IF(r.JENIS_KUNJUNGAN=3, aplikasi.getValuePropertyJSON(gr.DATA,''tgl_keluar'') , pd.TANGGAL) TGLKELUAR
		, CONCAT(DATEDIFF(IF(r.JENIS_KUNJUNGAN=3,aplikasi.getValuePropertyJSON(gr.DATA,''tgl_keluar''),pd.TANGGAL),pd.TANGGAL)+1,'' hari'') LOS
		, ref.DESKRIPSI CARABAYAR
		, pj.NOMOR NOMORSEP
		, IF(r.JENIS_KUNJUNGAN=3,''1 - Rawat Inap'',''2 - Rawat Jalan'') JENISPASIEN
		, IF(r.JENIS_KUNJUNGAN=1,''1 - Atas Persetujuan Dokter'',(SELECT CONCAT(cb.KODE,'' - '',cb.DESKRIPSI) FROM inacbg.inacbg cb WHERE cb.KODE=aplikasi.getValuePropertyJSON(gr.DATA,''cara_keluar'') AND cb.JENIS=9 AND cb.VERSION=5)) CARAPULANG
		, IF(aplikasi.getValuePropertyJSON(gr.DATA,''berat_lahir'')='''',''-'',aplikasi.getValuePropertyJSON(gr.DATA,''berat_lahir'')) BERATLAHIR
		, IF(r.JENIS_KUNJUNGAN=3,CONCAT(kls.KODE,'' - '',kls.DESKRIPSI),IF(r.JENIS_KUNJUNGAN!=3 AND s.INACBG=1,''Eksekutif'',''Reguler'')) KELASHAK
		, (SELECT md.KODE FROM medicalrecord.diagnosa md WHERE md.UTAMA=1 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,''') KODEDIAGNOSAUTAMA
		, (SELECT mr.STR
					FROM master.mrconso mr,
						  medicalrecord.diagnosa md
					WHERE mr.CODE=md.KODE AND md.UTAMA=1 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
					  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND mr.VERSION!=4
					GROUP BY md.KODE ) DIAGNOSAUTAMA
			, IF((SELECT REPLACE(GROUP_CONCAT(mrcode),'','',''
'')
						FROM (SELECT  CONCAT(mr.CODE,'' '',mr.STR)  mrcode
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND mr.VERSION!=4
						GROUP BY mr.CODE) a
					) IS NULL,'''',(SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''
'')
						FROM (SELECT ID, mr.CODE  mrcode
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND mr.VERSION!=4
						GROUP BY mr.CODE
						ORDER BY md.ID) a
						ORDER BY ID
					)) KODEDIAGNOSASEKUNDER
				, IF((SELECT REPLACE(GROUP_CONCAT(mrcode),'','',''
'')
						FROM (SELECT  CONCAT(mr.CODE,'' '',mr.STR)  mrcode
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND mr.VERSION!=4
						GROUP BY mr.CODE) a
					) IS NULL,'''',(SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''
'')
						FROM (SELECT ID, mr.STR  mrcode
							FROM master.mrconso mr,
								   medicalrecord.diagnosa md
							WHERE mr.CODE=md.KODE AND md.UTAMA=2 AND md.`STATUS`=1 AND md.NOPEN=''',PNOPEN,'''
							  AND mr.SAB=''ICD10_1998'' AND TTY IN (''PX'', ''PT'') AND mr.VERSION!=4
						GROUP BY mr.CODE
						ORDER BY md.ID) a
						ORDER BY ID
					)) DIAGNOSASEKUNDER
			, (SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''
'')
						FROM (SELECT  ID, mr.CODE  mrcode
						FROM master.mrconso mr,
								medicalrecord.prosedur pr
					WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=''',PNOPEN,'''
					  AND mr.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'')
					GROUP BY pr.KODE
					ORDER BY pr.ID) a
					ORDER BY ID
					) KODETINDAKAN
			, (SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR '';''),'';'',''
'')
						FROM (SELECT  ID, mr.STR  mrcode
						FROM master.mrconso mr,
								medicalrecord.prosedur pr
					WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=''',PNOPEN,'''
					  AND mr.SAB=''ICD9CM_2005'' AND TTY IN (''PX'', ''PT'')
					GROUP BY pr.KODE
					ORDER BY pr.ID) a
					ORDER BY ID
					) TINDAKAN
		, IF((aplikasi.getValuePropertyJSON(gr.DATA,''adl_sub_acute'')='''' OR aplikasi.getValuePropertyJSON(gr.DATA,''adl_sub_acute'')=''0''),''-'',aplikasi.getValuePropertyJSON(gr.DATA,''adl_sub_acute'')) ADLAKUT
		, IF((aplikasi.getValuePropertyJSON(gr.DATA,''adl_chronic'')='''' OR aplikasi.getValuePropertyJSON(gr.DATA,''adl_chronic'')=''0''),''-'',aplikasi.getValuePropertyJSON(gr.DATA,''adl_chronic'')) ADLKRONIK
		, hl.CODECBG INACBG
		, kd.DESKRIPSI DESKRIPSIINACBG
		, ''-'' ALOS
		, IF(''',PKELAS,'''=''1'',hl.TARIFKLS1,IF(''',PKELAS,'''=''2'',hl.TARIFKLS2, hl.TARIFCBG)) TARIFINACBG
		, REPLACE(CONCAT(hl.UNUSR,hl.UNUSI,hl.UNUSP, hl.UNUSD, hl.UNUSA),''None'','''') SPECIALPROSEDUR
		, IF(hl.UNUSA=''None'',''-'',hl.UNUSA) UNUSA, IF(hl.UNUSC=''None'',''-'',hl.UNUSC) UNUSC
		, IF(hl.UNUSA=''None'',''-'',sa.DESKRIPSI) DESUNUSA, IF(hl.UNUSC=''None'',''-'',sc.DESKRIPSI) DESUNUSC
		, IF(hl.UNUSA=''None'',0,hl.UNUSA) TARIFUNUSA, IF(hl.UNUSC=''None'',0,hl.UNUSC) TARIFUNUSC
		, IF(REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT('': '',hl.UNUSR,'';'')),IF(hl.UNUSI=''None'','''',CONCAT('': '',hl.UNUSI,'';'')),IF(hl.UNUSP=''None'','''',CONCAT('': '',hl.UNUSP,'';'')), IF(hl.UNUSD=''None'','''',CONCAT('': '',hl.UNUSD,'';''))),'';'',''\r'')='''','': -'',
			  REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT('': '',hl.UNUSR,'';'')),IF(hl.UNUSI=''None'','''',CONCAT('': '',hl.UNUSI,'';'')),IF(hl.UNUSP=''None'','''',CONCAT('': '',hl.UNUSP,'';'')), IF(hl.UNUSD=''None'','''',CONCAT('': '',hl.UNUSD,'';''))),'';'',''\r'')) KODESPESIAL
		, IF(REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT(sr.DESKRIPSI,'';'')),IF(hl.UNUSI=''None'','''',CONCAT(si.DESKRIPSI,'';'')),IF(hl.UNUSP=''None'','''',CONCAT(sp.DESKRIPSI,'';'')), IF(hl.UNUSD=''None'','''',CONCAT(sd.DESKRIPSI,'';''))),'';'',''\r'')='''',''-'',
			  REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT(sr.DESKRIPSI,'';'')),IF(hl.UNUSI=''None'','''',CONCAT(si.DESKRIPSI,'';'')),IF(hl.UNUSP=''None'','''',CONCAT(sp.DESKRIPSI,'';'')), IF(hl.UNUSD=''None'','''',CONCAT(sd.DESKRIPSI,'';''))),'';'',''\r'')) DESKKODE
		, IF(REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT(FORMAT(hl.TARIFSR,2,''de_DE''),'';'')),IF(hl.UNUSI=''None'','''',CONCAT(FORMAT(hl.TARIFSI,2,''de_DE''),'';'')),IF(hl.UNUSP=''None'','''',CONCAT(FORMAT(hl.TARIFSP,2,''de_DE''),'';'')), IF(hl.UNUSD=''None'','''',CONCAT(FORMAT(hl.TARIFSD,2,''de_DE''),'';''))),'';'',''\r'')='''',''0,00'',
		    REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',CONCAT(FORMAT(hl.TARIFSR,2,''de_DE''),'';'')),IF(hl.UNUSI=''None'','''',CONCAT(FORMAT(hl.TARIFSI,2,''de_DE''),'';'')),IF(hl.UNUSP=''None'','''',CONCAT(FORMAT(hl.TARIFSP,2,''de_DE''),'';'')), IF(hl.UNUSD=''None'','''',CONCAT(FORMAT(hl.TARIFSD,2,''de_DE''),'';''))),'';'',''\r'')) TARIFKODE
		, IF(REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',''Rp''),IF(hl.UNUSI=''None'','''',''Rp''),IF(hl.UNUSP=''None'','''',''Rp''), IF(hl.UNUSD=''None'','''',''Rp'')),'';'',''\r'')='''',''Rp'',
			  REPLACE(CONCAT(IF(hl.UNUSR=''None'','''',''Rp''),IF(hl.UNUSI=''None'','''',''Rp''),IF(hl.UNUSP=''None'','''',''Rp''), IF(hl.UNUSD=''None'','''',''Rp'')),'';'',''\r'')) RPKODE
		, hl.TARIFRS BIAYARS
		, IF(''',PKELAS,'''=''1'',(hl.TARIFKLS1+hl.TARIFSP + hl.TARIFSR + hl.TARIFSI + hl.TARIFSD + hl.TARIFSA + hl.TARIFSC)
			,IF(''',PKELAS,'''=''2'',(hl.TARIFKLS2+hl.TARIFSP + hl.TARIFSR + hl.TARIFSI + hl.TARIFSD + hl.TARIFSA + hl.TARIFSC), hl.TOTALTARIF))  TOTALTARIFINACBG
		, IF(''',PKELAS,'''=''1'', ''TOTAL TARIF INACBG Kelas 1''
			, IF(''',PKELAS,'''=''2'', ''TOTAL TARIF INACBG Kelas 2''
			, IF(r.JENIS_KUNJUNGAN=3,CONCAT(''TOTAL TARIF INACBG '',kls.DESKRIPSI), ''TOTAL TARIF INACBG Kelas 3''))) CATATAN
		, IF(hl.TIPE=3,
			(SELECT i.DESKRIPSI
					FROM inacbg.map_tarif mt
						, inacbg.inacbg i
					WHERE mt.JENISTARIF=i.KODE AND i.JENIS=10
						AND mt.KELASRS=inst.KELASRS AND mt.KEPEMILIKAN=IF(inst.KEPEMILIKAN=14,''S'',''P'')),
				(SELECT i.DESKRIPSI
						FROM inacbg.inacbg i
						WHERE i.JENIS=10
							AND IF(i.KODE=''RSAB'',''3174260'', IF(i.KODE=''RSCM'',''3173014'', IF(i.KODE=''RSD'',''3174063'',
									IF(i.KODE=''RSJP'',''3174282'',''''))))=(SELECT mp.KODE FROM aplikasi.instansi ai, master.ppk mp WHERE ai.PPK=mp.ID))) JENISTARIF
	FROM master.pasien p
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN pendaftaran.kunjungan pk ON pd.NOMOR=pk.NOPEN AND pk.`STATUS` IN (1,2)
		  LEFT JOIN layanan.pasien_pulang pp ON pd.NOMOR=pp.NOPEN AND pp.`STATUS` IN (1,2)
		  LEFT JOIN inacbg.map_inacbg_simrs mp ON pp.CARA=mp.SIMRS AND mp.JENIS=2
		  LEFT JOIN inacbg.inacbg cb ON mp.INACBG=cb.KODE AND cb.JENIS=9 AND cb.VERSION=5
		  LEFT JOIN inacbg.map_inacbg_simrs kl ON pj.KELAS=kl.SIMRS AND kl.JENIS=4
		  LEFT JOIN inacbg.inacbg kls ON kl.INACBG=kls.KODE AND kls.JENIS=8
		  LEFT JOIN inacbg.hasil_grouping hl ON pd.NOMOR=hl.NOPEN
		  LEFT JOIN inacbg.inacbg sp ON REPLACE(LEFT(hl.UNUSP,5),''-'','''')=sp.KODE AND sp.JENIS=6 AND sp.VERSION=5
		  LEFT JOIN inacbg.inacbg sa ON REPLACE(LEFT(hl.UNUSA,5),''-'','''')=sa.KODE AND sa.JENIS=1 AND sa.VERSION=5
		  LEFT JOIN inacbg.inacbg sr ON REPLACE(LEFT(hl.UNUSR,5),''-'','''')=sr.KODE AND sr.JENIS=4 AND sr.VERSION=5
		  LEFT JOIN inacbg.inacbg si ON REPLACE(LEFT(hl.UNUSI,5),''-'','''')=si.KODE AND si.JENIS=5 AND si.VERSION=5
		  LEFT JOIN inacbg.inacbg sd ON REPLACE(LEFT(hl.UNUSD,5),''-'','''')=sd.KODE AND sd.JENIS=3 AND sd.VERSION=5
		  LEFT JOIN inacbg.inacbg sc ON REPLACE(LEFT(hl.UNUSC,5),''-'','''')=sc.KODE AND sc.JENIS=1 AND sc.VERSION=5
		  LEFT JOIN inacbg.inacbg kd ON hl.CODECBG=kd.KODE AND kd.JENIS=1 AND kd.VERSION=5
		  LEFT JOIN inacbg.grouping gr ON pd.NOMOR=gr.NOPEN
		  , pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN inacbg.map_inacbg_simrs s ON tp.RUANGAN=s.SIMRS AND s.JENIS=5 AND s.INACBG=1 AND s.VERSION=5
		, (SELECT mp.KODE KODERS, mp.NAMA, mp.KELAS KELASRS, mp.KEPEMILIKAN
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
