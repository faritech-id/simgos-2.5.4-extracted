USE `berkas_klaim`;

CREATE TABLE IF NOT EXISTS `obat_farmasi_detil` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `OBAT_FARMASI` int NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE KEY `UNIQUE_KUNJUNGAN` (`KUNJUNGAN`) USING BTREE,
  KEY `KUNJUNGAN` (`KUNJUNGAN`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `OBAT_FARMASI` (`OBAT_FARMASI`)
) ENGINE=InnoDB;

