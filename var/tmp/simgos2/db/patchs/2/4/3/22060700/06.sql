USE master;
INSERT INTO `master`.`referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`) VALUES ('175', '0', 'Bukan Klaim Terpisah', '');
UPDATE `master`.`referensi` SET `ID`='0' WHERE  `JENIS`=175 AND `ID`=1;