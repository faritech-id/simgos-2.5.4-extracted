USE inventory;

ALTER TABLE `no_seri_barang_ruangan`
	CHANGE COLUMN `STATUS` `STATUS` SMALLINT NULL DEFAULT NULL COMMENT '1=default; 2=penerimaan dan distribusi (laundry); 3=distribusi (inventory)' AFTER `NO_SERI`;