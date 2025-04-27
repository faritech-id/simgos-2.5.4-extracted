USE inacbg;

REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (30, 'Shk Lokasi');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (31, 'Shk Alasan');

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (30, 'tumit', 'Tumit', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (30, 'vena', 'Vena', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (31, 'tidak-dapat', 'Tidak dapat dilakukan', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (31, 'akses-sulit', 'Akses sulit', '', NULL);
