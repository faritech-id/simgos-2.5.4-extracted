USE inventory;
ALTER TABLE `penerimaan_barang_detil`
	ADD COLUMN `REF_PO_DETIL` INT NOT NULL AFTER `STATUS`;
