USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (150, 'Jenis Info Teks', '', 1);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (150, 1, 'Informasi Pengunjung', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (150, 2, 'Footer Main Aplikasi', '', 1);
