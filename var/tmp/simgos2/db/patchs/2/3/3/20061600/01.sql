USE aplikasi;

ALTER TABLE `modules`
	ADD COLUMN `MENU_HOME` TINYINT(4) NOT NULL DEFAULT '0' AFTER `HAVE_CHILD`;