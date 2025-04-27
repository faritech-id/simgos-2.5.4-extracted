USE inacbg;

REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (21, 'Cara Masuk');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (22, 'Use Ind');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (23, 'Upgrade Class Payor');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (24, 'Dializer Single Use');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (25, 'Onset Kontraksi');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (26, 'Delivery Method');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (27, 'Letak Janin');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (28, 'Kondisi');
REPLACE INTO `jenis_inacbg` (`ID`, `DESKRIPSI`) VALUES (29, 'Ya / Tidak');

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'born', 'Lahir di RS', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'emd', 'Dari Rawat Darurat', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'gp', 'Rujukan FKTP', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'hosp-trans', 'Rujukan FKRTL', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'inp', 'Dari Rawat Inap', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'mp', 'Rujukan Spesialis', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'nursing', 'Rujukan Panti Jompo', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'other', 'Lain-lain', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'outp', 'Dari Rawat Jalan', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'psych', 'Rujukan dari RS Jiwa', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (21, 'rehab', 'Rujukan Fasilitas Rehab', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (22, '0', 'Tidak Ada Pemakaian', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (22, '1', 'Ada Pemakaian', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (23, 'peserta', 'Peserta', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (23, 'pemberi_kerja', 'Pemberi Kerja', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (23, 'asuransi_tambahan', 'Asuransi Tambahan', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (24, '0', 'Multiple Use', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (24, '1', 'Single Use', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (25, 'spontan', 'Spontan', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (25, 'induksi', 'Induksi', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (25, 'non_spontan_non_induksi', 'Non Spontan Non Induksi', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (26, 'vaginal', 'Vaginal', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (26, 'sc', 'Sectio Caesarean', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (27, 'kepala', 'Kepala', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (27, 'sungsang', 'Sungsang', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (27, 'lintang', 'Lintang/Obique', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (28, 'livebirth', 'Hidup', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (28, 'stillbirth', 'Meninggal', '', NULL);

INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (29, '0', 'Tidak', '', NULL);
INSERT INTO `inacbg` (`JENIS`, `KODE`, `DESKRIPSI`, `VERSION`, `TANGGAL_BERLAKU`) VALUES (29, '1', 'Ya', '', NULL);
