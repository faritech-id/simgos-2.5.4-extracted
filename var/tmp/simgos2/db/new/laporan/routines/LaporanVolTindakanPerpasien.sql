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

-- membuang struktur untuk procedure laporan.LaporanVolTindakanPerpasien
DROP PROCEDURE IF EXISTS `LaporanVolTindakanPerpasien`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanVolTindakanPerpasien`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `TINDAKAN` INT,
	IN `CARABAYAR` INT,
	IN `DOKTER` INT
)
BEGIN
	DECLARE vRUANGAN VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
	
	SET @sqlText = CONCAT('
	SELECT p.NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
		, CONCAT(DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y''),'' ('',master.getCariUmur(pp.TANGGAL,p.TANGGAL_LAHIR),'')'') TGL_LAHIR
		, IF(p.JENIS_KELAMIN=1,''L'',''P'') JENISKELAMIN
		, r.DESKRIPSI UNITPELAYANAN
		, master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
		, DATE_FORMAT(pk.MASUK,''%d-%m-%Y'') TGLKUNJUNGAN
		, DATE_FORMAT(tm.TANGGAL,''%d-%m-%Y'') TANGGALTINDAKAN, tm.TINDAKAN
		, pk.NOPEN, pj.NOMOR NOMORSEP, ref.DESKRIPSI CARABAYAR, t.NAMA NAMATINDAKAN
		, INST.NAMAINST, INST.ALAMATINST
		, IF(',CARABAYAR,'=0,''Semua'',ref.DESKRIPSI) CARABAYARHEADER
		, IF(',DOKTER,'=0,''Semua'',master.getNamaLengkapPegawai(mp.NIP)) DOKTERHEADER
		, IF(',TINDAKAN,'=0,''Semua'',t.NAMA) TINDAKANHEADER
		, CONCAT(op.WAKTU_MULAI,'' s.d '',op.WAKTU_SELESAI) WAKTUOPERASI
	FROM layanan.tindakan_medis tm
			LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
			LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
			LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			LEFT JOIN medicalrecord.operasi_di_tindakan mot ON tm.ID=mot.TINDAKAN_MEDIS AND mot.`STATUS`!=0
			LEFT JOIN medicalrecord.operasi op ON mot.ID=op.ID AND op.`STATUS`!=0
		, pendaftaran.pendaftaran pp
			LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
			LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
		, pendaftaran.kunjungan pk 
		  LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID AND r.JENIS=5
		, master.pasien p
		, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
						FROM aplikasi.instansi ai
							, master.ppk p
						WHERE ai.PPK=p.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR
		AND tm.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
		AND pk.RUANGAN LIKE ''',vRUANGAN,'''
		',IF(CARABAYAR=0,'',CONCAT(' AND pj.JENIS=',CARABAYAR)),'
		',IF(DOKTER=0,'',CONCAT(' AND ptm.MEDIS=',DOKTER)),'
		',IF(TINDAKAN = 0,'' , CONCAT(' AND tm.TINDAKAN =',TINDAKAN )),' 
	ORDER BY tm.TINDAKAN');
	

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
