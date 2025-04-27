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

-- membuang struktur untuk procedure layanan.CetakHasilRad1
DROP PROCEDURE IF EXISTS `CetakHasilRad1`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakHasilRad1`(IN `PTINDAKAN` CHAR(11))
BEGIN
	
	SELECT *,LPAD(p.NORM,8,'0') NORM, master.getNamaLengkap(p.NORM) NAMALENGKAP
			, rfk.DESKRIPSI JK,DATE_FORMAT(pas.TANGGAL_LAHIR,'%d-%m-%Y') TGL_LAHIR
			, hrad.TANGGAL, hrad.KLINIS, hrad.KESAN, hrad.USUL, hrad.HASIL
			, pk.NOPEN, pk.MASUK TGLREG, mt.NAMA NAMATINDAKAN, r.DESKRIPSI UNITPENGANTAR, orad.ALASAN DIAGNOSA
			, master.getNamaLengkapPegawai(peg.NIP) NAMADOKTER_ASAL, ref.DESKRIPSI KELAS
			, r.JENIS_KUNJUNGAN jk, orad.kunjungan
			, (SELECT pkj.RUANG_KAMAR_TIDUR FROM pendaftaran.kunjungan pkj WHERE pkj.NOPEN=pk.nopen 
			   AND pkj.RUANG_KAMAR_TIDUR!=0 AND pkj.`STATUS`!=0 limit 1) CEKELAS
			, pk.NOPEN TAGIHAN
			, substr(pk.REF,3,9) asal
			, dok1.ID DOK1
			, master.getNamaLengkapPegawai(mp1.NIP) DOKTER_SATU
		
		
		FROM pendaftaran.kunjungan pk 
				LEFT JOIN layanan.tindakan_medis tmi ON tmi.KUNJUNGAN=pk.NOMOR
				LEFT JOIN hasil_rad hrad ON tmi.ID=hrad.TINDAKAN_MEDIS
		  
		  LEFT JOIN master.dokter dok1 ON hrad.DOKTER=dok1.ID
			   LEFT JOIN master.pegawai mp1 ON dok1.NIP=mp1.NIP
			 
			 
				LEFT JOIN `master`.tindakan mt ON mt.ID=tmi.TINDAKAN
				LEFT JOIN order_detil_rad odr ON odr.REF=tmi.ID
				LEFT JOIN order_rad orad ON orad.NOMOR=odr.ORDER_ID
				LEFT JOIN master.ruangan r ON substr(pk.REF,3,9)=r.ID AND r.JENIS=5 AND pk.REF=orad.nomor
		      LEFT JOIN master.dokter d ON orad.DOKTER_ASAL = d.ID
				LEFT JOIN master.pegawai peg ON d.NIP = peg.NIP  
				LEFT JOIN pendaftaran.pendaftaran p ON pk.NOPEN = p.NOMOR
				LEFT JOIN master.pasien pas ON p.NORM = pas.NORM
			  	LEFT JOIN master.referensi rfk ON rfk.ID = pas.JENIS_KELAMIN AND rfk.JENIS=2
				LEFT JOIN pendaftaran.penjamin pj ON pj.NOPEN=pk.NOPEN 
				LEFT JOIN master.referensi ref ON pj.JENIS=ref.ID AND ref.JENIS=19
				LEFT JOIN master.kartu_asuransi_pasien kap ON p.NORM=kap.NORM AND ref.ID=kap.JENIS AND ref.JENIS=10
				LEFT JOIN master.kontak_pasien kontak ON kontak.NORM = pas.NORM 
			, (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
							FROM aplikasi.instansi ai
								, master.ppk p
							WHERE ai.PPK=p.ID) INST
	WHERE tmi.`STATUS` IN (1,2) AND pk.NOPEN=p.NOMOR AND p.NORM=pas.NORM AND tmi.KUNJUNGAN=pk.NOMOR AND hrad.TINDAKAN_MEDIS=tmi.ID 
		AND hrad.TINDAKAN_MEDIS=PTINDAKAN AND hrad.`STATUS`=1 LIMIT 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
