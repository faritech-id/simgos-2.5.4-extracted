USE master;	
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (127, 'Aturan Perhitungan Akomodasi', '', 1);

ALTER TABLE `referensi`
	CHANGE COLUMN `DESKRIPSI` `DESKRIPSI` VARCHAR(500) NOT NULL AFTER `ID`;	
	
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (127, 1, 'Keluar dikurangi Masuk', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (127, 2, '- Masuk Pertama di kenakan Akomodasi 1 hari\r\n- Lewat jam 00:00:00 maka akan dikenakan 1 hari', '', 1);