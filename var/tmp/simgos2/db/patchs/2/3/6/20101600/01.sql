USE `master`;

REPLACE INTO master.`jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (155, 'Status Pediatric', '', 0);
REPLACE INTO master.`referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (155, 1, 'Gizi Kurang', '', 1);
REPLACE INTO master.`referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (155, 2, 'Gizi Cukup', '', 1);
REPLACE INTO master.`referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (155, 3, 'Gizi Lebih', '', 1);
