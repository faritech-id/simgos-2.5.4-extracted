USE bpjs;

ALTER TABLE `rujukan`
	ADD COLUMN `tglRencanaKunjungan` DATE NOT NULL AFTER `tglRujukan`,
	ADD COLUMN `tglBerlakuKunjungan` DATE NULL AFTER `tglRencanaKunjungan`;