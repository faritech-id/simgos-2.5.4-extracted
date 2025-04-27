USE `master`;

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (216, 'Telaah Akhir Resep', '', 0);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Pasien', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Obat', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Dosis', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Rute', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Waktu Pemberian', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Informasi', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Benar Dokumentasi', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (216, 'Cek Kadaluarsa Obat', '', '', NULL, 1);

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (217, 'Rute Pemberian Obat', '', 0);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (217, 1, 'Oral', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (217, 2, 'Parenteral', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (217, 3, 'Topikal', '', '', NULL, 0, 1);
REPLACE INTO `referensi` (`JENIS`, `ID`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `SCORING`, `STATUS`) VALUES (217, 4, 'Supositoria (rektal)', '', '', NULL, 0, 1);

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (218, 'Status Order Layanan / Pemberian Obat', '', 0);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (218, 'Baru', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (218, 'Lanjut', '', '', NULL, 1);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (218, 'Stop', '', '', NULL, 1);

REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES (219, 'Alasan Jika Obat Tidak Terlayani', '', 0);
REPLACE INTO `referensi` (`JENIS`, `DESKRIPSI`, `REF_ID`, `TEKS`, `CONFIG`, `STATUS`) VALUES (219, 'Kosong', '', '', NULL, 1);