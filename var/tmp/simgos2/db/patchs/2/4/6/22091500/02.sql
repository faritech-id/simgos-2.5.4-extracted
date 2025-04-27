USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (134, 'Pemeriksaan Mikroskopik', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (134, 1, 'Pewarnaan Gram', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (134, 2, 'Pewarnaan Jamur', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (134, 3, 'Morfologi Index', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (134, 4, 'Body Index', '', '', NULL, 1);
