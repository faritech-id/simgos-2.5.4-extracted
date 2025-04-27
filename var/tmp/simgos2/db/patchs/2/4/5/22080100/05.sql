USE lis;

REPLACE INTO `vendor_lis` (`ID`, `NAMA`, `STATUS`) VALUES (1, 'Winacom', 1);
REPLACE INTO `vendor_lis` (`ID`, `NAMA`, `STATUS`) VALUES (2, 'Novanet (Bioconnect)', 1);
REPLACE INTO `vendor_lis` (`ID`, `NAMA`, `STATUS`) VALUES (3, 'Vanslab', 1);

REPLACE INTO `status_hasil` (`ID`, `DESKRIPSI`, `STATUS`) VALUES (3, 'Hasil LIS tidak di support (Belum Termapping)', 1);
UPDATE `lis`.`status_hasil` SET `DESKRIPSI`='Gagal membuat hasil LAB / Kunjungan terakhir tidak ditemukan' WHERE  `ID`=8;