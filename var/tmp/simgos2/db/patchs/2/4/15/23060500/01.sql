USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (222, 'Triage - Kategori Pemeriksaan', '', 0);
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (223, 'Triage - Plan', '', 0);

REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3370, 222, 1, 'Umum', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3371, 222, 2, 'Neonatus', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3373, 222, 3, 'Obgyn', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3374, 223, 1, 'Zone Merah', '', '', '{"color": "white", "backgroundColor": "red"}', 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3375, 223, 2, 'Zona Kuning', '', '', '{"color": "black", "backgroundColor": "yellow"}', 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3376, 223, 3, 'Zona Hijau', '', '', '{"color": "white", "backgroundColor": "green"}', 0, 1);
REPLACE INTO `referensi` (`TABEL_ID`, `JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (3377, 223, 4, 'Zona Hitam', '', '', '{"color": "white", "backgroundColor": "black"}', 0, 1);
