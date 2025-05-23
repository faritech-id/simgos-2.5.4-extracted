-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang data untuk tabel aplikasi.modules: ~196 rows (lebih kurang)
/*!40000 ALTER TABLE `modules` DISABLE KEYS */;
REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`) VALUES
	('10', 'PENDAFTARAN', 1, '', 1, NULL, NULL, 0, 0),
	('1001', 'PASIEN BARU', 2, '', 1, NULL, NULL, 0, 0),
	('1002', 'RAWAT JALAN', 2, '', 1, NULL, NULL, 0, 0),
	('1003', 'GAWAT DARURAT', 2, '', 1, NULL, NULL, 0, 0),
	('1004', 'RAWAT INAP', 2, '', 1, NULL, NULL, 0, 0),
	('1005', 'LABORATORIUM', 2, '', 1, NULL, NULL, 0, 0),
	('1006', 'RADIOLOGI', 2, '', 1, NULL, NULL, 0, 0),
	('1007', 'PERUBAHAN DATA', 2, '', 1, NULL, NULL, 0, 0),
	('100701', 'PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('10070101', 'UPDATE STATUS PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('100702', 'PENJAMIN / CARA PEMBAYARAN', 3, '', 1, NULL, NULL, 0, 0),
	('100703', 'TUJUAN', 3, '', 1, NULL, NULL, 0, 0),
	('100704', 'PAKET', 3, '', 1, NULL, NULL, 0, 0),
	('100705', 'TANGGAL PENDAFTARAN', 3, '', 1, NULL, NULL, 0, 0),
	('100706', 'UPLOAD PHOTO PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('1008', 'PENCETAKAN', 2, '', 1, NULL, NULL, 0, 0),
	('100801', 'BARU', 3, '', 1, NULL, NULL, 0, 0),
	('10080101', 'KARTU PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('10080102', 'BARCODE PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('10080103', 'BUKTI PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('10080104', 'BARCODE PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('10080105', 'TRACERT', 4, '', 1, NULL, NULL, 0, 0),
	('100802', 'ULANG', 3, '', 1, NULL, NULL, 0, 0),
	('10080201', 'KARTU PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('10080202', 'BARCODE PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('10080203', 'BUKTI PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('10080204', 'BARCODE PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('10080205', 'TRACERT', 4, '', 1, NULL, NULL, 0, 0),
	('1009', 'HISTORY', 2, '', 1, NULL, NULL, 0, 0),
	('100901', 'PENDAFTARAN', 3, '', 1, NULL, NULL, 0, 0),
	('1010', 'PEMBATALAN', 2, '', 1, NULL, NULL, 0, 0),
	('1011', 'PENERIMAAN', 2, '', 1, NULL, NULL, 0, 0),
	('101101', 'PENDAFTARAN KELAHIRAN', 3, '', 1, NULL, NULL, 0, 0),
	('11', 'LAYANAN', 1, '', 1, NULL, NULL, 0, 0),
	('1101', 'PENERIMAAN', 2, '', 1, NULL, NULL, 0, 0),
	('110101', 'PASIEN PENDAFTARAN / KUNJUNGAN', 3, '', 1, NULL, NULL, 0, 0),
	('110102', 'PASIEN KONSUL', 3, '', 1, NULL, NULL, 0, 0),
	('110103', 'PASIEN MUTASI', 3, '', 1, NULL, NULL, 0, 0),
	('110104', 'ORDER LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110105', 'ORDER RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('110106', 'RESEP PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('110107', 'OTOMATIS TERIMA ORDER LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110108', 'OTOMATIS TERIMA ORDER RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('110109', 'OTOMATIS TERIMA RESEP', 3, '', 1, NULL, NULL, 0, 0),
	('110110', 'PERUBAHAN TANGGAL KUNJUNGAN', 3, '', 1, NULL, NULL, 0, 0),
	('1102', 'PENGINPUTAN TINDAKAN / PEMERIKSAAN MEDIS ', 2, '', 1, NULL, NULL, 0, 0),
	('1103', 'PENGIRIMAN', 2, '', 1, NULL, NULL, 0, 0),
	('110301', 'PASIEN KONSUL', 3, '', 1, NULL, NULL, 0, 0),
	('110302', 'PASIEN MUTASI', 3, '', 1, NULL, NULL, 0, 0),
	('110303', 'ORDER LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110304', 'ORDER RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('110305', 'RESEP PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('1104', 'FEEDBACK / UMPAN BALIK', 2, '', 1, NULL, NULL, 0, 0),
	('110401', 'JAWABAN KONSUL', 3, '', 1, NULL, NULL, 0, 0),
	('110402', 'PENGINPUTAN HASIL LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110403', 'PENGINPUTAN HASIL RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('1105', 'PEMBACAAN', 2, '', 1, NULL, NULL, 0, 0),
	('110501', 'JAWABAN KONSUL', 3, '', 1, NULL, NULL, 0, 0),
	('110502', 'HASIL LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110503', 'HASIL RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('1106', 'HISTORY', 2, '', 1, NULL, NULL, 0, 0),
	('110601', 'PASIEN KUNJUNGAN', 3, '', 1, NULL, NULL, 0, 0),
	('110602', 'PASIEN KONSUL', 3, '', 1, NULL, NULL, 0, 0),
	('110603', 'PASIEN MUTASI', 3, '', 1, NULL, NULL, 0, 0),
	('110604', 'ORDER LABORATORIUM', 3, '', 1, NULL, NULL, 0, 0),
	('110605', 'ORDER RADIOLOGI', 3, '', 1, NULL, NULL, 0, 0),
	('110606', 'RESEP PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('1107', 'PENCETAKAN', 2, '', 1, NULL, NULL, 0, 0),
	('1108', 'PEMBATALAN', 2, '', 1, NULL, NULL, 0, 0),
	('110801', 'PENERIMAAN / PENGIRIMAN', 3, '', 1, NULL, NULL, 0, 0),
	('11080101', 'PASIEN PENDAFTARAN / KUNJUNGAN (TUJUAN PASIEN)', 4, '', 1, NULL, NULL, 0, 0),
	('11080102', 'PASIEN KONSUL', 4, '', 1, NULL, NULL, 0, 0),
	('11080103', 'PASIEN MUTASI', 4, '', 1, NULL, NULL, 0, 0),
	('11080104', 'ORDER LABORATORIUM', 4, '', 1, NULL, NULL, 0, 0),
	('11080105', 'ORDER RADIOLOGI', 4, '', 1, NULL, NULL, 0, 0),
	('11080106', 'RESEP PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('110802', 'PASIEN KUNJUNGAN', 3, '', 1, NULL, NULL, 0, 0),
	('110803', 'PENGINPUTAN TINDAKAN / PEMERIKSAAN MEDIS ', 3, '', 1, NULL, NULL, 0, 0),
	('110804', 'FINAL', 3, '', 1, NULL, NULL, 0, 0),
	('1109', 'FINAL / SELESAI', 2, '', 1, NULL, NULL, 1, 0),
	('110901', 'FINAL HASIL', 3, '', 1, NULL, NULL, 0, 0),
	('110902', 'BATAL FINAL HASIL', 3, '', 1, NULL, NULL, 0, 0),
	('1110', 'KELAHIRAN', 2, '', 1, NULL, NULL, 0, 0),
	('12', 'PEMBAYARAN', 1, '', 1, NULL, NULL, 0, 0),
	('1201', 'FINAL TAGIHAN', 2, '', 1, NULL, NULL, 0, 0),
	('1202', 'PENERIMAAN UANG MUKA', 2, '', 1, NULL, NULL, 0, 0),
	('1203', 'PENGEMBALIAN UANG MUKA', 2, '', 1, NULL, NULL, 0, 0),
	('1204', 'PIUTANG', 2, '', 1, NULL, NULL, 0, 0),
	('1205', 'PELUNASAN PIUTANG', 2, '', 1, NULL, NULL, 0, 0),
	('1206', 'PEMBAYARAN NON TUNAI / EDC', 2, '', 1, NULL, NULL, 0, 0),
	('1207', 'DISKON', 2, '', 1, NULL, NULL, 0, 0),
	('1208', 'PEMBATALAN TAGIHAN FINAL', 2, '', 1, NULL, NULL, 0, 0),
	('1209', 'TRANSAKSI KASIR', 2, '', 1, NULL, NULL, 0, 0),
	('1211', 'BATAL GABUNG TAGIHAN', 2, '', 1, NULL, NULL, 0, 0),
	('1212', 'PENJAMIN', 2, '', 1, NULL, NULL, 0, 0),
	('1213', 'PENCETAKAN', 2, '', 1, NULL, NULL, 0, 0),
	('121301', 'KUITANSI TAGIHAN', 3, '', 1, NULL, NULL, 0, 0),
	('13', 'REKAM MEDIS', 1, '', 1, NULL, NULL, 0, 0),
	('1301', 'PENCETAKAN / LEMBARAN', 2, '', 1, NULL, NULL, 0, 0),
	('130101', 'RAWAT JALAN', 3, '', 1, NULL, NULL, 0, 0),
	('13010101', 'MR1 - PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('130102', 'GAWAT DARURAT', 3, '', 1, NULL, NULL, 0, 0),
	('13010201', 'MR2 - PENGKAJIAN AWAL MEDIS PASIEN', 4, '', 1, NULL, NULL, 0, 0),
	('130103', 'RAWAT INAP', 3, '', 1, NULL, NULL, 0, 0),
	('13010301', 'MR1a - PENDAFTARAN', 4, '', 1, NULL, NULL, 0, 0),
	('13010302', 'MR1 - RINGKASAN MASUK DAN KELUAR', 4, '', 1, NULL, NULL, 0, 0),
	('13010303', 'MR2 - RESUME MEDIS', 4, '', 1, NULL, NULL, 0, 0),
	('1302', 'CODING ICD', 2, '', 1, NULL, NULL, 0, 0),
	('14', 'LAPORAN', 1, 'Laporan', 1, 'laporan.Workspace', 'x-fa fa-file-text-o', 0, 1),
	('1401', 'REKAPITULASI LAPORAN (RL)', 2, '', 1, NULL, NULL, 0, 0),
	('1402', 'PENGUNJUNG', 2, '', 1, NULL, NULL, 0, 0),
	('1403', 'KUNJUNGAN', 2, '', 1, NULL, NULL, 0, 0),
	('1404', 'LAYANAN', 2, '', 1, NULL, NULL, 0, 0),
	('1405', 'PENERIMAAN KASIR', 2, '', 1, NULL, NULL, 0, 0),
	('1406', 'JASA PELAYANAN', 2, '', 1, NULL, NULL, 0, 0),
	('1407', 'INVENTORY', 2, '', 1, NULL, NULL, 0, 0),
	('1408', 'REKAM MEDIS', 2, '', 1, NULL, NULL, 0, 0),
	('1409', 'PENDAPATAN', 2, '', 1, NULL, NULL, 0, 0),
	('1410', 'KEGIATAN RI & RD', 2, '', 1, NULL, NULL, 0, 0),
	('1411', 'MONITORING PELAYANAN', 2, '', 1, NULL, NULL, 0, 0),
	('19', 'MASTER', 1, 'Master', 1, 'master.Workspace', 'x-fa fa-cogs', 1, 1),
	('1901', 'PPK', 2, 'PPK', 1, 'master.ppk.Workspace', 'x-fa fa-hospital-o', 0, 0),
	('1902', 'PEGAWAI', 2, 'Pegawai', 1, 'master.pegawai.Workspace', 'x-fa fa-users', 0, 0),
	('1903', 'MANAJEMEN PENGGUNA', 2, 'Manajemen Pengguna', 1, 'master.manajemenpengguna.Workspace', 'x-fa fa-table', 0, 0),
	('1904', 'RUANGAN', 2, 'Ruangan', 1, 'master.ruangan.Workspace', 'x-fa fa-bed', 0, 0),
	('1905', 'TINDAKAN', 2, 'Tindakan', 1, 'master.tindakan.Workspace', 'x-fa fa-medkit', 1, 0),
	('190501', 'HANYA MENAMPILKAN TINDAKAN DAN TARIF', 3, '', 1, NULL, NULL, 0, 0),
	('1906', 'KATEGORI', 2, 'Kategori', 1, 'master.inventory.kategori.Workspace', 'x-fa fa-cube', 0, 0),
	('1907', 'PENYEDIA', 2, 'Penyedia', 1, 'master.penyedia.Workspace', 'x-fa fa-user-secret', 0, 0),
	('1908', 'BARANG', 2, 'Barang', 1, 'master.inventory.barang.Workspace', 'x-fa fa-cubes', 1, 0),
	('190801', 'HANYA MENAMPILKAN BARANG DAN HARGA', 3, '', 1, NULL, NULL, 0, 0),
	('1909', 'PAKET', 2, 'Paket', 1, 'master.paket.Workspace', 'x-fa fa-cart-plus', 0, 0),
	('1910', 'PAKET TINDAKAN FARMASI', 2, 'Paket Tindakan Farmasi', 1, 'master.pakettindakanfarmasi.Workspace', 'x-fa fa-user-secret', 0, 0),
	('1911', 'GROUP TINDAKAN LAB', 2, 'Group Tindakan Lab', 1, 'master.grouptindakanlab.Workspace', 'x-fa fa-exchange', 0, 0),
	('1912', 'TARIF', 2, 'Tarif', 1, 'master.tarif.Workspace', 'x-fa fa-money', 1, 0),
	('191201', 'HANYA MENAMPILKAN TARIF', 3, '', 1, NULL, NULL, 0, 0),
	('1913', 'MARGIN OBAT', 2, 'Margin Obat', 1, 'master.marginpenjaminfarmasi.Workspace', 'x-fa fa-money', 0, 0),
	('1914', 'PENJAMIN RUANGAN', 2, 'Penjamin Ruangan', 1, 'master.penjaminruangan.Workspace', 'x-fa fa-user-secret', 0, 0),
	('1915', 'BPJS', 2, 'BPJS', 1, 'plugins.bpjs.Workspace', 'simpel-bpjs', 0, 0),
	('1916', 'NEGARA', 2, 'Negara', 1, 'master.negara.Workspace', 'x-fa fa-flag-o', 0, 0),
	('1917', 'WILAYAH', 2, 'Wilayah', 1, 'master.wilayah.Workspace', 'x-fa fa-flag-checkered', 0, 0),
	('1918', 'REFERENSI', 2, 'Referensi', 1, 'master.referensi.Workspace', 'x-fa fa-file-archive-o', 0, 0),
	('1919', 'KEMENKES', 2, 'Kemenkes', 1, 'plugins.kemkes.Workspace', 'simpel-kemkes', 0, 0),
	('191901', 'RS ONLINE', 3, '', 1, NULL, NULL, 0, 0),
	('19190101', 'LAPORAN COVID - 19', 4, 'Laporan Covid-19', 1, 'plugins.kemkes.rsonline.laporancovid.Workspace', 'x-fa fa-shield', 0, 1),
	('1919010100', 'DASHBOARD', 5, '', 1, NULL, NULL, 0, 0),
	('1919010101', 'PASIEN', 5, '', 1, NULL, NULL, 0, 0),
	('191901010101', 'AMBIL DATA DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010102', 'TAMBAH DATA', 6, '', 1, NULL, NULL, 0, 0),
	('191901010103', 'EDIT DATA', 6, '', 1, NULL, NULL, 0, 0),
	('191901010104', 'KIRIM DATA KE RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('1919010102', 'KETERSEDIAAN RUANGAN', 5, '', 1, NULL, NULL, 0, 0),
	('191901010201', 'AMBIL DATA REFERENSI DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010202', 'AMBIL DATA DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010203', 'SIMPAN DATA', 6, '', 1, NULL, NULL, 0, 0),
	('191901010204', 'KIRIM DATA KE RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('1919010103', 'KETERSEDIAAN SDM', 5, '', 1, NULL, NULL, 0, 0),
	('191901010301', 'AMBIL DATA REFERENSI DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010302', 'AMBIL DATA DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010303', 'SIMPAN DATA', 6, '', 1, NULL, NULL, 0, 0),
	('191901010304', 'KIRIM DATA KE RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('1919010104', 'KETERSEDIAAN APD, OBAT & ALKES', 5, '', 1, NULL, NULL, 0, 0),
	('191901010401', 'AMBIL DATA REFERENSI DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010402', 'AMBIL DATA DARI RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('191901010403', 'SIMPAN DATA', 6, '', 1, NULL, NULL, 0, 0),
	('191901010404', 'KIRIM DATA KE RS ONLINE', 6, '', 1, NULL, NULL, 0, 0),
	('1920', 'MAPPING', 2, 'Mapping', 1, 'master.mapping.Workspace', 'x-fa fa-map-signs', 0, 0),
	('1921', 'PENGATURAN', 2, 'Pengaturan', 1, 'aplikasi.pengaturan.Workspace', 'x-fa fa-cog', 0, 0),
	('20', 'INFORMASI', 1, 'Informasi', 1, 'informasi.Workspace', 'x-fa fa-stack-exchange', 0, 1),
	('2001', 'PENGUNJUNG', 2, '', 1, NULL, NULL, 1, 0),
	('200101', 'TAMPILKAN IDENTITAS PASIEN', 3, '', 1, NULL, NULL, 0, 0),
	('2002', 'RUANG TEMPAT TIDUR KOSONG', 2, '', 1, NULL, NULL, 0, 0),
	('2003', 'PASIEN RAWAT INAP', 2, '', 1, NULL, NULL, 0, 0),
	('21', 'PENJUALAN', 1, 'Penjualan', 1, 'penjualan.Workspace', 'x-fa fa-cart-plus', 0, 1),
	('2101', 'ENTRY ITEM BARANG', 2, '', 1, NULL, NULL, 0, 0),
	('2102', 'FINAL PEMBAYARAN', 2, '', 1, NULL, NULL, 0, 0),
	('22', 'TEMPAT TIDUR', 1, 'Tempat Tidur', 1, 'informasi.ruangkamartidur.Workspace', 'x-fa fa-bed', 1, 1),
	('2201', 'RESERVASI', 2, '', 1, NULL, NULL, 0, 0),
	('2202', 'TAMPILKAN IDENTITAS PASIEN', 2, '', 1, NULL, NULL, 0, 0),
	('23', 'INVENTORY', 1, 'Inventory', 1, 'inventory.Workspace', 'x-fa fa-cubes', 0, 1),
	('2301', 'PERMINTAAN', 2, '', 1, NULL, NULL, 0, 0),
	('2302', 'PENERIMAAN', 2, '', 1, NULL, NULL, 0, 0),
	('2303', 'PENGIRIMAN', 2, '', 1, NULL, NULL, 0, 0),
	('2304', 'STOK OPNAME', 2, '', 1, NULL, NULL, 0, 0),
	('2305', 'REKANAN', 2, '', 1, NULL, NULL, 0, 0),
	('230501', 'PENERIMAAN', 3, '', 1, NULL, NULL, 0, 0),
	('230502', 'PENGEMBALIAN', 3, '', 1, NULL, NULL, 0, 0),
	('230503', 'PEMBATALAN PENERIMAAN', 3, '', 1, NULL, NULL, 0, 0),
	('24', 'PANEL PENCARIAN', 1, '', 1, NULL, NULL, 0, 0),
	('2401', 'PENCARIAN', 2, '', 1, NULL, NULL, 0, 0),
	('240101', 'PENCARIAN', 3, '', 1, NULL, NULL, 0, 0),
	('24010101', 'PASIEN', 4, '', 1, 'pasien.Pencarian', NULL, 0, 0),
	('24010102', 'PEGAWAI', 4, '', 0, 'pegawai.Pencarian', NULL, 0, 0),
	('25', 'INTEGRASI / BRIDGING', 1, '', 1, NULL, NULL, 0, 0),
	('2501', 'BPJS', 2, '', 1, NULL, NULL, 0, 0),
	('250103', 'SEP', 3, '', 1, NULL, NULL, 0, 0),
	('25010306', 'APROVAL PENGAJUAN', 4, '', 1, NULL, NULL, 0, 0);
/*!40000 ALTER TABLE `modules` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
