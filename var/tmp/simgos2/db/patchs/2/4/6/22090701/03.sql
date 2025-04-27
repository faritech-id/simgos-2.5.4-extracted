USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (128, 'Antibiotik', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (129, 'Bakteri', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (131, 'Hasil Kultur', '', 0);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (128, 1, 'Cefoxitin Screen', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (128, 2, 'Amoxicilin', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (128, 3, 'Ciprofloxacin', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (128, 4, 'Tetrasiklin', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (128, 5, 'Streptococcus pyogenes', '', 0);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (129, 1, 'Staphyiococcus aureus', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (129, 2, 'Streptococcus pyogenes', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (131, 1, 'Sensitive', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (131, 2, 'Resisten', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (131, 3, 'Intermediet', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (131, 4, 'Positif', '', 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (131, 5, 'Negatif', '', 1);
