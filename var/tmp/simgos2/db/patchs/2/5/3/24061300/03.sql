USE `master`;

UPDATE `master`.`referensi` SET `CONFIG`='{"rm":{"riwaya_alergi":{"kode_referensi":"kfa"}}}' WHERE  `JENIS`=180 AND ID = 1;
UPDATE `master`.`referensi` SET `CONFIG`='{"rm": {"riwaya_alergi": {"kode_referensi": "snomedct"}}}' WHERE  `JENIS`=180 AND ID = 2;
UPDATE `master`.`referensi` SET `CONFIG`='{"rm": {"riwaya_alergi": {"kode_referensi": "snomedct"}}}' WHERE  `JENIS`=180 AND ID = 3;
