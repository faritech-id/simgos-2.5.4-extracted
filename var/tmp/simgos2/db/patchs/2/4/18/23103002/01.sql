
use `medicalrecord`;

ALTER TABLE `perencanaan_rawat_inap`
	ADD COLUMN `DOKTER` SMALLINT(5) NOT NULL AFTER `DESKRIPSI`;
