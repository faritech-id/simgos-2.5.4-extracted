USE lis;

ALTER TABLE `order_item_log`
	CHANGE COLUMN `STATUS` `STATUS` TINYINT NOT NULL DEFAULT '1' COMMENT 'Status Kirim (1=Belum Terkirim; 2=Terkirim)';
