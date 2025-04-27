USE medicalrecord;
ALTER TABLE `cppt`
	ADD COLUMN `INSTRUKSI` TEXT NOT NULL COMMENT 'Menyimpan data instruksi' AFTER `PLANNING`;