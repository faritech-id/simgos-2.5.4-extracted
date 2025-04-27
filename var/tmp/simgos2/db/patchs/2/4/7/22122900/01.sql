USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (215, 'Telaah Awal Resep', '', 0);

REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Benar Pasien', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Benar Obat', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Benar Dosis', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Benar Rute', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Benar Waktu Pemberian', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Tidak Ada Duplikasi', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (215, 'Tidak Ada Iteraksi Obat', '', '', NULL, 1);