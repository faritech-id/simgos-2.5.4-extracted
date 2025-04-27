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

-- membuang struktur untuk procedure medicalrecord.CetakMR2
DROP PROCEDURE IF EXISTS `CetakMR2`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakMR2`(
	IN `PNOPEN` CHAR(10)
)
BEGIN 	
	SELECT inst.PPK IDPPK,UPPER(inst.NAMA) NAMAINSTANSI, inst.KOTA KOTA, INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR, p.ALAMAT
		, DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y') TANGGAL_LAHIR
		, master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) TGL_LAHIR
		, CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),', ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) TTL
		, rjk.DESKRIPSI JENISKELAMIN
		, rpd.DESKRIPSI PENDIDIKAN
		, rpk.DESKRIPSI PEKERJAAN
		, rag.DESKRIPSI AGAMA
		, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLREG, DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y %H:%i:%s') TGLKLR
		, pl.TANGGAL TGLKELUAR, cr.DESKRIPSI CARAKELUAR, kd.DESKRIPSI KEADAANKELUAR
		, ref.DESKRIPSI CARABAYAR, pj.NOMOR SEP, u.DESKRIPSI UNITPELAYANAN
		, (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=3) KODEMR1
		, UPPER((master.getDiagnosa(PNOPEN,1))) DIAGNOSAUTAMA, (master.getKodeDiagnosa(PNOPEN,1)) KODEDIAGNOSAUTAMA
		, (master.getDiagnosa(PNOPEN,2)) DIAGNOSASEKUNDER, (master.getKodeDiagnosa(PNOPEN,2)) KODEDIAGNOSASEKUNDER
		, (master.getICD9CM(PNOPEN)) TINDAKAN, (master.getKodeICD9CM(PNOPEN)) KODETINDAKAN
		, (SELECT master.getNamaLengkapPegawai(mpdok.NIP) DOKTEROPERATOR
				FROM operasi o
				     LEFT JOIN master.dokter dok ON o.DOKTER=dok.ID
					  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					, pendaftaran.kunjungan pk
				WHERE o.`STATUS`=1 AND pk.NOMOR=o.KUNJUNGAN AND pk.`STATUS`!=0
					AND pk.NOPEN=PNOPEN
			    LIMIT 1) DOKTEROPERATOR
		, master.getNamaLengkapPegawai(mpdokdpjp.NIP) DPJP
		, (SELECT pt.TOTAL
				FROM pembayaran.tagihan_pendaftaran tp
					, pembayaran.pembayaran_tagihan pt
				WHERE tp.TAGIHAN=pt.TAGIHAN AND tp.PENDAFTARAN=PNOPEN) TOTALBIAYA
			, an.DESKRIPSI ANAMNESI, rp.DESKRIPSI RPP, pf.DESKRIPSI FISIK 
			, (SELECT GROUP_CONCAT(DISTINCT(ib.NAMA)) 
					FROM layanan.farmasi lf
						  LEFT JOIN master.referensi ref ON ref.ID=lf.ATURAN_PAKAI AND ref.JENIS=41
						, pendaftaran.kunjungan pk
					     LEFT JOIN layanan.order_resep o ON o.NOMOR=pk.REF
					     LEFT JOIN master.dokter md ON o.DOKTER_DPJP=md.ID
						  LEFT JOIN master.pegawai mp ON md.NIP=mp.NIP
						  LEFT JOIN pendaftaran.kunjungan asal ON o.KUNJUNGAN=asal.NOMOR
						  LEFT JOIN master.ruangan r ON asal.RUANGAN=r.ID AND r.JENIS=5
					     LEFT JOIN master.referensi jenisk ON r.JENIS_KUNJUNGAN=jenisk.ID AND jenisk.JENIS=15
					   , pendaftaran.pendaftaran pp
						  LEFT JOIN master.pasien ps ON pp.NORM=ps.NORM
						, inventory.barang ib
						, pembayaran.rincian_tagihan rt
					WHERE  lf.`STATUS`=2 AND lf.KUNJUNGAN=pk.NOMOR AND pk.`STATUS` IN (1,2)
						AND pk.NOPEN=pp.NOMOR AND lf.FARMASI=ib.ID
						AND pk.NOPEN=PNOPEN AND o.RESEP_PASIEN_PULANG!=1
						AND lf.ID=rt.REF_ID AND rt.JENIS=4 AND LEFT(ib.KATEGORI,3)='101') OBATRS
	   , (SELECT GROUP_CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)) 
				FROM layanan.hasil_lab hlab,
					  layanan.tindakan_medis tm,
					  master.parameter_tindakan_lab ptl
					  LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35,
					  master.tindakan mt
					  LEFT JOIN master.group_tindakan_lab gtl ON mt.ID=gtl.TINDAKAN
					  LEFT JOIN master.group_lab kgl ON LEFT(gtl.GROUP_LAB,2)=kgl.ID
					  LEFT JOIN master.group_lab ggl ON gtl.GROUP_LAB=ggl.ID,
					  pendaftaran.pendaftaran pp
					  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
					  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10,
					  pendaftaran.kunjungan pk 
					  LEFT JOIN layanan.order_lab ks ON pk.REF=ks.NOMOR
					  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
					  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
					  
				WHERE hlab.TINDAKAN_MEDIS=tm.ID AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.TINDAKAN=mt.ID
						AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hlab.`STATUS`=1
						AND pk.NOPEN=pd.NOMOR 
						AND (hlab.HASIL!='' AND hlab.HASIL IS NOT NULL)
						AND pp.`STATUS`!=0 AND pk.`STATUS`!=0 AND r.JENIS_KUNJUNGAN=4
				ORDER BY ggl.ID,ptl.INDEKS) LAB
		, (SELECT GROUP_CONCAT(t.NAMA,' = ',hrad.HASIL)
					FROM layanan.hasil_rad hrad
						, layanan.tindakan_medis tm
						  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
						, pendaftaran.pendaftaran pp
						, pendaftaran.kunjungan pk 
				WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
					AND pp.NOMOR=pd.NOMOR AND hrad.`STATUS`=1 AND pp.`STATUS`!=0 AND pk.`STATUS`!=0) RAD
  FROM master.pasien p
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  LEFT JOIN master.referensi rpd ON p.PENDIDIKAN=rpd.ID AND rpd.JENIS=3
		  LEFT JOIN master.referensi rpk ON p.PEKERJAAN=rpk.ID AND rpk.JENIS=4
		  LEFT JOIN master.referensi rsk ON p.STATUS_PERKAWINAN=rsk.ID AND rsk.JENIS=5
		  LEFT JOIN master.referensi rag ON p.AGAMA=rag.ID AND rag.JENIS=1
		  LEFT JOIN master.referensi gol ON p.GOLONGAN_DARAH=gol.ID AND gol.JENIS=6
		, pendaftaran.pendaftaran pd
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pd.NOMOR=pl.NOPEN AND pl.`STATUS`=1
		  LEFT JOIN master.dokter dokdpjp ON pl.DOKTER=dokdpjp.ID
		  LEFT JOIN master.pegawai mpdokdpjp ON dokdpjp.NIP=mpdokdpjp.NIP
	 	  LEFT JOIN master.referensi cr ON pl.CARA=cr.ID AND cr.JENIS=45
		  LEFT JOIN master.referensi kd ON pl.KEADAAN=kd.ID AND kd.JENIS=46
		  LEFT JOIN pendaftaran.kunjungan pk ON pl.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
		  LEFT JOIN master.ruangan u ON pk.RUANGAN=u.ID AND u.JENIS=5
		  LEFT JOIN medicalrecord.anamnesis an ON pd.NOMOR=an.PENDAFTARAN AND an.`STATUS`=1
		  LEFT JOIN medicalrecord.rpp rp ON rp.KUNJUNGAN = an.KUNJUNGAN
		  LEFT JOIN medicalrecord.pemeriksaan_fisik pf ON pd.NOMOR=pf.PENDAFTARAN AND pf.`STATUS`=1
		, pendaftaran.tujuan_pasien tp
		  LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
		, (SELECT mp.NAMA, ai.PPK, w.DESKRIPSI KOTA
					FROM aplikasi.instansi ai
						, master.ppk mp
						, master.wilayah w
					WHERE ai.PPK=mp.ID AND mp.WILAYAH=w.ID) inst
	WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=PNOPEN;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
