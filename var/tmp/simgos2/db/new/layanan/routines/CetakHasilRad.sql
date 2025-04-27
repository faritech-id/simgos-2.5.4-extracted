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

-- membuang struktur untuk procedure layanan.CetakHasilRad
DROP PROCEDURE IF EXISTS `CetakHasilRad`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakHasilRad`(
	IN `PTINDAKAN` CHAR(11)
)
BEGIN
	
	SELECT INST.KOTA, DATE_FORMAT(SYSDATE(),'%d-%m-%Y %H:%i:%s') TGLSKRG, LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, CONCAT(rjk.DESKRIPSI,' / ',DATE_FORMAT(p.TANGGAL_LAHIR,'%d-%m-%Y')) JKTGLALHIR
			, hrad.TANGGAL, hrad.KLINIS, hrad.KESAN, hrad.USUL, hrad.HASIL, hrad.BTK, master.getNamaLengkapPegawai(mp.NIP) DOKTER
			, pk.NOPEN, pk.MASUK TGLREG, t.NAMA NAMATINDAKAN, r.DESKRIPSI UNITPENGANTAR, orad.ALASAN DIAGNOSA
		FROM layanan.hasil_rad hrad
			  LEFT JOIN master.dokter dok ON hrad.DOKTER=dok.ID
			  LEFT JOIN master.pegawai mp ON dok.NIP=mp.NIP
			, layanan.tindakan_medis tm
			  LEFT JOIN master.tindakan t ON tm.TINDAKAN=t.ID
			  LEFT JOIN pendaftaran.kunjungan pku ON pku.NOMOR = tm.KUNJUNGAN
			  LEFT JOIN layanan.order_rad orad ON orad.NOMOR = pku.REF AND orad.`STATUS` IN (1,2)
			, pendaftaran.pendaftaran pp
				LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=10
			, pendaftaran.kunjungan pk 
			  LEFT JOIN layanan.order_rad ks ON pk.REF=ks.NOMOR
			  LEFT JOIN pendaftaran.kunjungan kj ON ks.KUNJUNGAN=kj.NOMOR
			  LEFT JOIN master.ruangan r ON kj.RUANGAN=r.ID AND r.JENIS=5
			, master.pasien p
			  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
			, (SELECT w.DESKRIPSI KOTA
						FROM aplikasi.instansi ai
							, master.ppk p
							, master.wilayah w
						WHERE ai.PPK=p.ID AND p.WILAYAH=w.ID) INST
	WHERE tm.`STATUS` IN (1,2) AND pk.NOPEN=pp.NOMOR AND pp.NORM=p.NORM AND tm.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tm.ID 
		AND hrad.TINDAKAN_MEDIS=PTINDAKAN AND hrad.`STATUS`=1
	;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
