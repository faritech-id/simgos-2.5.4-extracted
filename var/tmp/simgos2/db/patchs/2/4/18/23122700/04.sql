USE `berkas_klaim`;

CREATE TABLE IF NOT EXISTS `lab_klinik_detil` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `LAB_KLINIK` int NOT NULL,
  `HASIL_LAB` char(12) NOT NULL,
  `TINDAKAN_MEDIS` char(11) NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `LAB_KLINIK` (`LAB_KLINIK`) USING BTREE,
  KEY `HASIL_LAB` (`HASIL_LAB`) USING BTREE,
  KEY `TINDAKAN_MEDIS` (`TINDAKAN_MEDIS`)
) ENGINE=InnoDB;
