USE `medicalrecord`;

ALTER TABLE `rekonsiliasi_transfer_detil`
	ADD COLUMN `REKONSILIASI_TRANSFER_DETIL` INT(10) NOT NULL COMMENT 'ID Rekonsiliasi Transfer Detil Inputan ke-2 dan seterusnya dengan NOPEN yang sama dan NOKUNJUNGAN berbeda.' AFTER `LAYANAN_FARMASI`,
	ADD INDEX `REKONSILIASI_TRANSFER_DETIL` (`REKONSILIASI_TRANSFER_DETIL`);