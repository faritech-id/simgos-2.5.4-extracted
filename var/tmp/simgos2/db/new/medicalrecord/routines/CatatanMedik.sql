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

-- membuang struktur untuk procedure medicalrecord.CatatanMedik
DROP PROCEDURE IF EXISTS `CatatanMedik`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CatatanMedik`(
	IN `PNOPEN` CHAR(10),
	IN `PKUNJUNGAN` VARCHAR(19)












)
BEGIN
SET @sqlText = CONCAT(
	'SELECT inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM
	, master.getNamaLengkap(p.NORM) NAMALENGKAP
    , master.getTempatLahir(p.TEMPAT_LAHIR) TEMPAT_LAHIR
    , DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'') TANGGAL_LAHIR
    , master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR) UMUR
    , CONCAT(master.getTempatLahir(p.TEMPAT_LAHIR),'', '',DATE_FORMAT(p.TANGGAL_LAHIR,''%d-%m-%Y'')) TTL
    , IF((SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
          FROM master.kontak_pasien kp 
          WHERE kp.NORM=p.NORM)='''',p.ALAMAT,CONCAT(p.ALAMAT,'' - ('',(SELECT GROUP_CONCAT(kp.NOMOR) KONTAK 
          FROM master.kontak_pasien kp 
          WHERE kp.NORM=p.NORM),'')'')) ALAMAT
    , DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALKUNJUNGAN
    , DATE_FORMAT(pd.TANGGAL,''%H:%i:%s'') JAM
    , if(rjk.DESKRIPSI=''Perempuan'',''P'',''L'') JK
    , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y'') TGLREG
    , (SELECT jbr.KODE FROM master.jenis_berkas_rm jbr WHERE jbr.JENIS=r.JENIS_KUNJUNGAN AND jbr.ID=1) KODEMR1
    , master.getNamaLengkapPegawai(dok.NIP) DPJP
    , CONCAT(rr.DESKRIPSI,'' / '',rk.KAMAR,'' / '',kelas.DESKRIPSI) KAMAR
    , CONCAT(IF(dm.DIAGNOSA is NULL,'''',dm.DIAGNOSA), IF(dm.ICD is NULL,'''',CONCAT(''('',dm.ICD,'')''))) DIAGNOSAMASUK
    , CONCAT(DATEDIFF(plg.TANGGAL,pk.MASUK),'' hari'') LOS
    , CONCAT( UPPER((master.getDiagnosaMR1(pd.NOMOR,1)))) DIAGNOSAUTAMA
	 , CONCAT((master.getDiagnosaMR1(pd.NOMOR,2))) DIAGNOSASEKUNDER
  FROM master.pasien p
      LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
    , pendaftaran.pendaftaran pd
      LEFT JOIN aplikasi.pengguna us ON pd.OLEH=us.ID
      LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
      LEFT JOIN master.diagnosa_masuk dm on pd.DIAGNOSA_MASUK=dm.ID
      LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN=pd.NOMOR
      LEFT JOIN master.dokter dok ON tp.DOKTER=dok.ID
      LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
      LEFT JOIN master.referensi sm ON sm.ID=tp.SMF AND sm.JENIS=26
      LEFT JOIN layanan.pasien_pulang plg on pd.NOMOR=plg.NOPEN
    , pendaftaran.kunjungan pk
      LEFT JOIN master.ruangan rr ON pk.RUANGAN=rr.ID AND rr.JENIS=5
      LEFT JOIN master.ruang_kamar_tidur rkt ON pk.RUANG_KAMAR_TIDUR=rkt.ID
      LEFT JOIN master.ruang_kamar rk ON rkt.RUANG_KAMAR = rk.ID
      LEFT JOIN master.referensi kelas ON rk.KELAS = kelas.ID AND kelas.JENIS=19
    , (SELECT mp.NAMA, ai.PPK 
          FROM aplikasi.instansi ai
            , master.ppk mp
          WHERE ai.PPK=mp.ID) inst
  WHERE p.NORM=pd.NORM AND pd.NOMOR=tp.NOPEN AND pd.NOMOR=''',PNOPEN,''' AND pd.NOMOR=pk.NOPEN AND pd.STATUS!=0 AND pk.STATUS!=0 
   	',IF(PKUNJUNGAN = 0,CONCAT(' AND pk.REF IS NULL' ) ,'' ),'
		',IF(PKUNJUNGAN = 0,'' , CONCAT(' AND pk.NOMOR =''',PKUNJUNGAN,'''' )),' 
  ');
	
 
  PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
