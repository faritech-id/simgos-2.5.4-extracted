USE `layanan`;

-- Dumping structure for procedure layanan.CetakTelaahResep
DROP PROCEDURE IF EXISTS `CetakTelaahResep`;
DELIMITER //
CREATE PROCEDURE `CetakTelaahResep`(
	IN `PKUNJUNGAN` CHAR(50)
)
BEGIN
	SELECT
		rec.ID, rec.DESKRIPSI, rec.VAWAL, rec.VAKHIR, IF(rec.VAWAL=0,null,1) SAWAL, IF(rec.VAKHIR=0,null,1) SAKHIR
		, (SELECT layanan.getStatusTelaahResep(k.REF, rec.ID, 1)) VSTATUS_AWAL
		, (SELECT layanan.getStatusTelaahResep(k.NOMOR, rec.ID, 2)) VSTATUS_AKHIR
	FROM pendaftaran.kunjungan k
	LEFT JOIN 
	(
		SELECT 
			r.ID, r.DESKRIPSI, MAX(IF(r.JENIS=215,1,0)) VAWAL, MAX(IF(r.JENIS=216,1,0)) VAKHIR
		FROM master.referensi r
		WHERE r.JENIS IN (215,216)
		GROUP BY r.ID 
		ORDER BY r.ID ASC
	) rec ON 1 = 1
	WHERE k.NOMOR = PKUNJUNGAN;
END//
DELIMITER ;