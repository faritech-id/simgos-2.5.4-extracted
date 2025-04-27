USE master;
/* Menambahan jenis referensi Prioritas untuk tempat tidur */
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (158, 'Prioritas', '', 0);

/* menambahkan referensi prioritas */
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (158, 1, 'NORMAL', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (158, 2, 'MEDIUM', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (158, 3, 'HIGH', '', 1);
