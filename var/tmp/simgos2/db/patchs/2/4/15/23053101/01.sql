UPDATE `master`.group_pemeriksaan gp
   SET gp.DESKRIPSI = 'Visite'
 WHERE gp.JENIS = 3
   AND gp.KODE = '10'
   AND gp.`STATUS` = 1;

REPLACE INTO `master`.`group_pemeriksaan` (`JENIS`, `KODE`, `LEVEL`, `DESKRIPSI`, `REF_ID`, `STATUS`) VALUES (3, '11', 1, 'Visite Dokter & Perawat', NULL, 1);