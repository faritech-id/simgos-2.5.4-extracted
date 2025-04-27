USE `master`;

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (9, 1, 'Kartu Tanda Penduduk (KTP)', '', '', '{"regExp": "[^0-9]", "maxLength": 16, "minLength": 16}', 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (9, 7, 'KTP WNA', '', '', '{"regExp": "[^0-9]", "maxLength": 16, "minLength": 16}', 0, 1);

REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (10, 2, 'BPJS / JKN', '2', '', '{"sep": {"regExp": "[^a-zA-Z0-9]", "maxLength": 19, "minLength": 19}, "regExp": "[^0-9]", "maxLength": 13, "minLength": 13}', 0, 1);
