USE inacbg;

REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (18, 'Akses NAAT');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (19, 'Isolasi Mandiri');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (20, 'Status Bayi Lahir');

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) 
VALUES (18, 'A', 'A', '', NULL), (18, 'B', 'B', '', NULL), (18, 'C', 'C', '', NULL);

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) 
VALUES (19, '0', 'Tidak', '', NULL), (19, '1', 'Ya', '', NULL);

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) 
VALUES (20, '1', 'Tanpa Kelainan', '', NULL), (20, '2', 'Dengan Kelainan', '', NULL);