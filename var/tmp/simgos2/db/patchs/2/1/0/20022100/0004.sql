-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.24 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk laporan
USE `laporan`;

-- membuang struktur untuk procedure laporan.LaporanTarifTindakanPerpasienTglMasuk
DROP PROCEDURE IF EXISTS `LaporanTarifTindakanPerpasienTglMasuk`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanTarifTindakanPerpasienTglMasuk`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN, IFNULL(kls.DESKRIPSI,''Non Kelas'') KELAS
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN
		, INST.NAMAINST, INST.ALAMATINST
		, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
		, CONCAT(op.WAKTU_MULAI,'' s.d '',op.WAKTU_SELESAI) WAKTUOPERASI
		, rt.TARIF
		, IF(ptm.JENIS=1 AND ptm.KE=1,tt.DOKTER_OPERATOR
			, IF(ptm.JENIS=1 AND ptm.KE=2,tt.DOKTER_LAINNYA
			  , IF(ptm.JENIS=2 ,tt.DOKTER_ANASTESI
			    , IF(ptm.JENIS=3 ,tt.PARAMEDIS
			      , IF(ptm.JENIS=5 ,tt.PARAMEDIS
			        , IF(ptm.JENIS=6 ,IF(tt.ANALIS=0,tt.PARAMEDIS,tt.ANALIS)
			          , IF(ptm.JENIS=7 ,tt.PENATA_ANASTESI
			            , IF(ptm.JENIS=8 ,tt.RADIOGRAFER
			              , IF(ptm.JENIS=9 ,tt.DRIVER
			                , IF(ptm.JENIS=10 ,tt.EVAKUATOR,0)))))))))) TARIF_JASA
		, IF(ptm.JENIS IN (1,2),master.getNamaLengkapPegawai(mp.NIP),IF(ptm.JENIS IN (3,5),master.getNamaLengkapPegawai(prwt.NIP),master.getNamaLengkapPegawai(mpp.NIP))) PEGAWAI
	/*	, (SELECT REPLACE(GROUP_CONCAT(IF(ptg.JENIS IN (1,2),CONCAT(''- '',master.getNamaLengkapPegawai(mp.NIP)),CONCAT(''- '',master.getNamaLengkapPegawai(mpp.NIP)))),'',-'',''\r-'') 
				FROM layanan.petugas_tindakan_medis ptg
					  LEFT JOIN master.dokter dok ON ptg.MEDIS=dok.ID AND ptg.JENIS IN (1,2)
					  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
					  LEFT JOIN master.pegawai mpp ON mpp.ID=ptg.MEDIS AND ptg.JENIS NOT IN (1,2)
				WHERE ptg.TINDAKAN_MEDIS=tm.ID
				GROUP BY ptg.TINDAKAN_MEDIS
				LIMIT 1) PEGAWAI */
		, DATE_FORMAT(pp.TANGGAL,''%d-%m-%Y'') TGLMASUK 
		, DATE_FORMAT(pp.TANGGAL,''%H:%i:%s'') WAKTUMASUK
		, DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y'') TGLKELUAR
		, DATE_FORMAT(pl.TANGGAL,''%H:%i:%s'') WAKTUKELUAR   
		, master.getNamaLengkapPegawai(dok.NIP) DOKTER_REG
	FROM  pembayaran.rincian_tagihan rt
	     LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
		  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
		  LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.STATUS!=0 # AND ptm.JENIS=1 AND KE=1
		  LEFT JOIN master.dokter dok1 ON ptm.MEDIS=dok1.ID AND ptm.JENIS IN (1,2)
		  LEFT JOIN master.pegawai mp ON dok1.NIP=mp.NIP
		  LEFT JOIN master.pegawai mpp ON mpp.ID=ptm.MEDIS AND ptm.JENIS NOT IN (1,2)
		  LEFT JOIN master.perawat prwt ON ptm.MEDIS=prwt.ID
		  LEFT JOIN medicalrecord.operasi_di_tindakan mot ON tm.ID=mot.TINDAKAN_MEDIS AND mot.`STATUS`!=0
		  LEFT JOIN medicalrecord.operasi op ON mot.ID=op.ID AND op.`STATUS`!=0
		  LEFT JOIN master.tarif_tindakan tt ON rt.TARIF_ID=tt.ID
		  LEFT JOIN pendaftaran.kunjungan pk ON pk.NOMOR = tm.KUNJUNGAN
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = pk.RUANG_KAMAR_TIDUR
	  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  LEFT JOIN pendaftaran.pendaftaran pp ON pp.NOMOR = pk.NOPEN
		  LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		  LEFT JOIN layanan.pasien_pulang pl ON pp.NOMOR=pl.NOPEN AND pl.STATUS=1
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
		  LEFT JOIN master.pasien p ON pp.NORM=p.NORM
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,''' AND pp.STATUS!=0
	  AND rt.JENIS = 3 AND rt.`STATUS` NOT IN (0) AND r.JENIS_KUNJUNGAN=',LAPORAN,'
	  ',IF(RUANGAN=0,'',CONCAT(' AND pk.RUANGAN LIKE ''',vRUANGAN,'''')),' 
	  ',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'	  				
	ORDER BY pp.TANGGAL, tm.TANGGAL, ptm.JENIS, ptm.MEDIS');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
