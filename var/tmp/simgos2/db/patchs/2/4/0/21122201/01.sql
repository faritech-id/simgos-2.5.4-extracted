USE bpjs;

ALTER TABLE `pengajuan`
	CHANGE COLUMN `jnsPelayanan` `jnsPelayanan` TINYINT NOT NULL COMMENT '1 = R.Inap; 2 = R. Jalan' AFTER `tglSep`,
	ADD COLUMN `jnsPengajuan` TINYINT NOT NULL COMMENT '1 = Backdate; 2 = Finger Print' AFTER `jnsPelayanan`;
