USE `pembayaran`;

REPLACE INTO `penyedia` (`ID`, `NAMA`, `JENIS_PENYEDIA_ID`, `REFERENSI_ID`, `STATUS_ID`) VALUES (1, 'Bank Tabungan Negara (BTN)', 2, 1, 1);
REPLACE INTO `penyedia` (`ID`, `NAMA`, `JENIS_PENYEDIA_ID`, `REFERENSI_ID`, `STATUS_ID`) VALUES (2, 'Bank Rakyat Indonesia (BRI)', 2, 2, 1);
REPLACE INTO `penyedia` (`ID`, `NAMA`, `JENIS_PENYEDIA_ID`, `REFERENSI_ID`, `STATUS_ID`) VALUES (3, 'Bank Negara Indonesia (BNI)', 2, 3, 1);
REPLACE INTO `penyedia` (`ID`, `NAMA`, `JENIS_PENYEDIA_ID`, `REFERENSI_ID`, `STATUS_ID`) VALUES (4, 'Bank Mandiri', 2, 4, 1);
REPLACE INTO `penyedia` (`ID`, `NAMA`, `JENIS_PENYEDIA_ID`, `REFERENSI_ID`, `STATUS_ID`) VALUES (5, 'Bank Central Asia (BCA)', 2, 5, 0);

REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (1, 1, 2, 'pembayaran.tagihan.nontunai.edc.Workspace', NULL, 1);
REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (2, 2, 2, 'pembayaran.tagihan.nontunai.edc.Workspace', NULL, 1);
REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (3, 3, 2, 'pembayaran.tagihan.nontunai.edc.Workspace', NULL, 0);
REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (4, 4, 2, 'pembayaran.tagihan.nontunai.edc.Workspace', NULL, 0);
REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (5, 1, 3, 'pembayaran.tagihan.nontunai.bank.transfer.Workspace', NULL, 1);
REPLACE INTO `layanan_penyedia` (`ID`, `PENYEDIA_ID`, `JENIS_LAYANAN_ID`, `DRIVER`, `KODE`, `STATUS_ID`) VALUES (6, 2, 3, 'pembayaran.tagihan.nontunai.bank.transfer.Workspace', NULL, 1);
