USE `master`;

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (87, 3, 'ODC', '', '', NULL, 0, 1);

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (213, 'Jenis Transfusi', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (213, 1, 'Package Red Cell', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (213, 2, 'Whole Blood', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (213, 3, 'Fresh Frozen Plasma', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (213, 4, 'Trombosit Concentrate', '', '', NULL, 0, 1);

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (214, 'Jenis Pelaksana Operasi', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 1, 'DPJP', '4', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 2, 'Asisten Dokter', '4', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 3, 'Dokter Perfusi', '4', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 4, 'Dokter Anastesi', '4', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 5, 'Asisten Dokter Anestesi', '4', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 6, 'Penata Anestesi', '10', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 7, 'Scrub Nurse (Perawat)', '6', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 8, 'Sirkuler Nurse (Perawat)', '6', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 9, 'Perawat Perfusi', '6', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (214, 10, 'Dokter Tamu', '', '', NULL, 0, 1);
