USE `master`;

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 8, 'IM / Alamat Media Sosial', '', '', '{"regExp": "[^a-zA-Z0-9.-\\\\/]", "emptyText": "twitter.com/simrsgosv2", "maxLength": 35}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 7, 'Situs Web', '', '', '{"regExp": "[^a-zA-Z0-9.-]", "emptyText": "domain.com", "maxLength": 35}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 6, 'Email', '', '', '{"regExp": "[^a-zA-Z0-9.@-]", "emptyText": "Contoh: nama@domain.com", "maxLength": 35}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 3, 'Telepon Seluler', '', '', '{"regExp": "[^0-9]", "emptyText": "Contoh: 081234567890", "maxLength": 12, "minLength": 12}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 1, 'Telepon Rumah', '', '', '{"regExp": "[^0-9]", "emptyText": "Contoh: 0411123456", "maxLength": 12, "minLength": 10}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 2, 'Telepon Kantor', '', '', '{"regExp": "[^0-9]", "emptyText": "Contoh: 0411123456", "maxLength": 12, "minLength": 10}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 4, 'Faks Rumah', '', '', '{"regExp": "[^0-9]", "emptyText": "Contoh: 0411123456", "maxLength": 12, "minLength": 10}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (8, 5, 'Faks Kantor', '', '', '{"regExp": "[^0-9]", "emptyText": "Contoh: 0411123456", "maxLength": 12, "minLength": 10}', 0, 1);
