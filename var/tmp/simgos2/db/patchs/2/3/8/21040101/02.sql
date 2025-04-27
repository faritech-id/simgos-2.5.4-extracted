USE master;
/* Menambahan jenis referensi status antrian tempat tidur untuk tempat tidur */
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (159, 'Status Antrian Tempat Tidur', '', 0);

/* menambahkan referensi status antrian tempat tidur */
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (159, 0, 'Batal', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (159, 1, 'Menunggu / Belum mendapatkan Reservasi Tempat Tidur', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (159, 2, 'Sudah Mendapatkan Reservasi Tempat Tidur', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (159, 3, 'Sudah menempati tempat tidur', '', 1);
