USE inacbg;

REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (11, 'Status Covid 19');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (12, 'Episodes');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (13, 'Jenis Kartu Identitas');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (14, 'Komorbid / Komplikasi');

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (11, '1', 'ODP', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (11, '2', 'PDP', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (11, '3', 'Terkonfirmasi', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '1', 'ICU dengan ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '2', 'ICU tanpa ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '3', 'Isolasi tekanan negatif dengan ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '4', 'Isolasi tekanan negatif tanpa ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '5', 'Isolasi non tekanan negatif dengan ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (12, '6', 'Isolasi non tekanan negatif tanpa ventilator', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (13, 'kartu_jkn', 'Kartu JKN', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (13, 'kitas', 'KITAS', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (13, 'lainnya', 'Lainnya', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (13, 'nik', 'NIK', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (13, 'paspor', 'Paspor', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (14, '0', 'Tidak Ada', '');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`) VALUES (14, '1', 'Ada', '');