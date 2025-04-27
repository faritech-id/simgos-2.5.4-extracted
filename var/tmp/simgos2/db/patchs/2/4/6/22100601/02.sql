USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (181, 'Kondisi Fisik Umum (Dekubitus)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (182, 'Kesadaran (Dekubitus)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (183, 'Aktivitas (Dekubitus)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (184, 'Mobilitas (Dekubitus)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (185, 'Inkontinensia (Dekubitus)', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (181, 1, 'Baik', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (181, 2, 'Lumayan', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (181, 3, 'Buruk', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (181, 4, 'Sangat Buruk', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (182, 1, 'Kompos Mentis', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (182, 2, 'Apatis', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (182, 3, 'Konfus/Soporis', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (182, 4, 'Stupor/Koma', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (183, 1, 'Dapat Berpindah', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (183, 2, 'Berjalan Dengan Bantuan', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (183, 3, 'Terbatas di Kursi', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (183, 4, 'Terbatas di Tempat Tidur', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (184, 1, 'Bergerak Bebas', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (184, 2, 'Sedikit Terbatas', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (184, 3, 'Sangat Terbatas', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (184, 4, 'Tak Bisa Bergerak', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (185, 1, 'Tidak Ngompol', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (185, 2, 'Kadang-kadang', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (185, 3, 'Sering Inkontinensia Urin', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (185, 4, 'Sering Inkontinensia Alvi dan Urin', '', '', NULL, 1, 1);