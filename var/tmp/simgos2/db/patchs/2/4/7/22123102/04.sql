USE `layanan`;

ALTER TABLE `order_detil_resep`
	ADD COLUMN `REF_RIWAYAT_ORDER` CHAR(21) NULL DEFAULT NULL COMMENT 'ID Order Sebelumnya (Jika Resep Ambil Dari Order Sebelumnya)' AFTER `REF`,
	ADD INDEX `REF_RIWAYAT_ORDER` (`REF_RIWAYAT_ORDER`);