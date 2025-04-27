USE bpjs;
CREATE TABLE `dpjp` (
	`kode` CHAR(10) NOT NULL,
	`nama` VARCHAR(150) NOT NULL DEFAULT '',
	PRIMARY KEY (`kode`) USING BTREE
)
COMMENT='menampung data dpjp dari bpjs'
ENGINE=InnoDB
;
