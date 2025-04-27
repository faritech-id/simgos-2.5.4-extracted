USE `master`;

-- Dumping structure for function master.getTglAsesmenAwal
DROP FUNCTION IF EXISTS `getTglAsesmenAwal`;
DELIMITER //
CREATE FUNCTION `getTglAsesmenAwal`(
	`PKUNJUNGAN` CHAR(50)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	   SELECT IF(an.TANGGAL > ku.TANGGAL, ku.TANGGAL, an.TANGGAL) tanggal INTO VTANGGAL
			FROM pendaftaran.kunjungan pk
			     LEFT JOIN medicalrecord.anamnesis an ON pk.NOMOR=an.KUNJUNGAN AND an.`STATUS`!=0
			     LEFT JOIN medicalrecord.keluhan_utama ku ON pk.NOMOR=ku.KUNJUNGAN AND ku.`STATUS`!=0
			WHERE pk.NOMOR=PKUNJUNGAN AND pk.`STATUS`!=0 
			LIMIT 1;

	RETURN VTANGGAL;
END//
DELIMITER ;