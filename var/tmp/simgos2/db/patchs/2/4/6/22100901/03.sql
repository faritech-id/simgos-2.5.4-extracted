USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (192, 'Umur (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (193, 'Jenis Kelamin (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (194, 'Diagnosa (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (195, 'Gangguan Kongnitif (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (196, 'Faktor Lingkungan (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (197, 'Respon Terhadap Operasi/Obat Penenang/Efek Anastesi (Skala Humpty Dumpty)', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (198, 'Penggunaan Obat (Skala Humpty Dumpty)', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (192, 1, '< 3 Tahun', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (192, 2, '3 s.d < 7 Tahun', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (192, 3, '7 s.d < 13 Tahun', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (192, 4, '>= 13 Tahun', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (193, 2, 'Perempuan', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (193, 1, 'Laki-laki', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (194, 1, 'Kelainan Neurologi', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (194, 2, 'Perubahan dalam Oksigenasi (Masalah Saluran Nafas, Dehidrasi, Anemia, Anoreksi, Slokop/sakit kepala, dll)', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (194, 3, 'Kelamin Priksi/Perilaku', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (194, 4, 'Diagnosa Lain', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (195, 1, 'Tidak Sadar terhadap Keterbatasan', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (195, 2, 'Lupa keterbatasan', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (195, 3, 'Mengetahui Kemampuan Diri', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (196, 1, 'Riwayat jatuh dari tempat tidur saat bayi anak', '', '', NULL, 4, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (196, 2, 'Pasien menggunakan alat bantu box atau mobel', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (196, 3, 'Pasien berada ditempat tidur', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (196, 4, 'Diluar ruang rawat', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (197, 1, 'Dalam 24 Jam', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (197, 2, 'Dalam 48 jam riwayat jatuh', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (197, 3, '> 48 jam', '', '', NULL, 1, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (198, 1, 'Bermacam-macam obat yang digunakan: obat sedarif (kecuali pasien ICU yang menggunakan sedasi dan paralisis), Hipnotik, Barbiturat, Fenotiazin, Antidepresan, Laksans/Diuretika,Narketik', '', '', NULL, 3, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (198, 2, 'Salah satu pengobatan diatas', '', '', NULL, 2, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (198, 3, 'Pengobatan lain', '', '', NULL, 1, 1);

