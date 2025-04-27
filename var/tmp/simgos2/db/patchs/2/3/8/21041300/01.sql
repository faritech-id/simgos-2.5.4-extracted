USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (130, 'Jenis Perhitungan Penjamin Tagihan', '', 1);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (130, 1, 'Tanpa Jaminan', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (130, 2, 'Grouping INACBG', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (130, 3, 'Jaminan sama dengan Tagihan', '', 1);

UPDATE `master`.referensi SET REF_ID = 1 WHERE JENIS = 10 AND ID = 1;
UPDATE `master`.referensi SET REF_ID = 2 WHERE JENIS = 10 AND ID = 2;
UPDATE `master`.referensi SET REF_ID = 3 WHERE JENIS = 10 AND ID > 2;

