USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (180, 'Jenis Alergi', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (180, 1, 'Obat', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (180, 2, 'Makanan', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (180, 3, 'Udara', '', '', NULL, 0, 1);
