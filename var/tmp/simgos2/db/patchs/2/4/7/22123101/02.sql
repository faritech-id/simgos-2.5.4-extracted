UPDATE medicalrecord.operasi o
   SET o.RUANGAN_PASCA_OPERASI = IF(o.RUANGAN_PASCA_OPERASI = 'Ruangan', 0, 1)
 WHERE o.`STATUS` IN (0,1,2);

ALTER TABLE medicalrecord.`operasi`
	CHANGE COLUMN `RUANGAN_PASCA_OPERASI` `RUANGAN_PASCA_OPERASI` TINYINT NOT NULL DEFAULT 0 COMMENT 'Perawatan Pasca Operasi (0=Ruangan Non Intensif, 1=Ruangan Intensif)' AFTER `PERDARAHAN`;
