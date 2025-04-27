USE `master`;

REPLACE INTO `jenis_laporan_detil` (`JENIS`, `ID`, `DESKRIPSI`, `KODE`, `REPORT_PARAMS`, `STATUS`) VALUES ('12', 7, 'Tarif Tindakan Per Pasien', '', '{\r\n  NAME: \'pendaftaran.LaporanTarifTindakanPerpasienTglMasuk\',\r\n  TYPE: \'Pdf\', \r\n  EXT: \'pdf\',\r\n  PARAMETER: {\r\n   TGLAWAL: \'\',\r\n   TGLAKHIR: \'\',\r\n   RUANGAN:\'\',\r\n   LAPORAN:\'\',\r\n   CARABAYAR:\'\'\r\n  },\r\n  REQUEST_FOR_PRINT: false,\r\n  PRINT_NAME: \'CetakKunjungan\'\r\n}', 1);
