USE inacbg;

ALTER TABLE `inacbg`
	ADD COLUMN `TANGGAL_BERLAKU` DATE NULL AFTER `VERSION`;
	
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'dinkes', 'Surat Dinas Kesehatan', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'dinsos', 'Surat Dinas Sosial', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'kartu_jkn', 'Kartu JKN', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'kelurahan', 'Surat Kelurahan', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'kitas', 'KITAS/KITAP', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'kk', 'Kartu Keluarga', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'lainnya', 'Lainnya', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'nik', 'NIK', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'paspor', 'Paspor', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'sjp', 'Surat Jaminan Pelayanan', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (13, 'unhcr', 'Surat UNHCR', '', NULL);

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (11, '1', 'ODP', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (11, '2', 'PDP', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (11, '3', 'Terkonfirmasi', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (11, '4', 'Suspek', '', '2020-08-15');
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (11, '5', 'Probabel', '', '2020-08-15');

REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (15, 'RS Darurat / Lapangan');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (16, 'Co-Insidens');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (17, 'Penunjang Pengurang');

REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (15, '0', 'Tidak', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (15, '1', 'Ya', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (16, '0', 'Tidak', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (16, '1', 'Ya', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (17, '0', 'Dilakukan', '', NULL);
REPLACE INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (17, '1', 'Tidak dilakukan', '', NULL);

ALTER TABLE `inacbg`
	ADD COLUMN `ID` MEDIUMINT NOT NULL AUTO_INCREMENT FIRST,
	CHANGE COLUMN `JENIS` `JENIS` TINYINT(4) NOT NULL COMMENT 'Tabel Jenis_inacbg' AFTER `ID`,
	DROP PRIMARY KEY,
	ADD UNIQUE INDEX `JENIS_KODE_VERSION` (`JENIS`, `KODE`, `VERSION`),
	ADD PRIMARY KEY (`ID`);