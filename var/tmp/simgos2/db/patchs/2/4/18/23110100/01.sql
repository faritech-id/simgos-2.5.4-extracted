-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakDeposit
DROP PROCEDURE IF EXISTS `CetakDeposit`;
DELIMITER //
CREATE PROCEDURE `CetakDeposit`(
	IN `PID` INT
)
BEGIN

	DECLARE VNOMOR_KUITANSI CHAR(12);
	DECLARE VPEMBAYAR VARCHAR(75);
  	
	SELECT kp.NOMOR, kp.NAMA
	  INTO VNOMOR_KUITANSI, VPEMBAYAR
	  FROM cetakan.kwitansi_pembayaran kp 
	  		, pembayaran.deposit dp
	 WHERE kp.TAGIHAN = dp.TAGIHAN AND dp.ID=PID
	   AND kp.JENIS_LAYANAN_ID = 6
	 ORDER BY kp.TANGGAL DESC
	 LIMIT 1;
	 
	SELECT dp.ID IDDEPOSIT, t.ID IDTAGIHAN, dp.TOTAL,
			 dp.TANGGAL TANGGALDEPOSIT,
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT,
			 CONCAT(pembayaran.getInfoTagihanKunjungan(t.ID),' ',inst.NAMA) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA,
			 IF(dp.KETERANGAN IS NULL,dp.NAMA, CONCAT(dp.NAMA,' (',dp.KETERANGAN,')')) PEMBAYAR, dp.JENIS, IFNULL(VNOMOR_KUITANSI,'') NOMOR_KUITANSI
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF,
	  		 pembayaran.deposit dp
			 LEFT JOIN aplikasi.pengguna us ON us.ID = dp.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP,
			 (SELECT mp.NAMA, mp.ALAMAT, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	 WHERE dp.ID = PID AND t.ID=dp.TAGIHAN
	   AND dp.`STATUS` = 1;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
