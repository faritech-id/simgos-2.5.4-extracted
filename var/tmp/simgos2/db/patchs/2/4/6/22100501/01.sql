USE `aplikasi`;

REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `CONFIG`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`, `MENU_MASTER`, `PACKAGE_NAME`, `INTERNAL_PACKAGE`, `CRUD`, `C`, `R`, `U`, `D`) VALUES ('130405', 'RISIKO JATUH', 3, 'Risiko Jatuh', 1, 'rekammedis-penilaian-risikojatuh-workspace', NULL, NULL, 1, 0, 0, NULL, 1, 0, 0, 0, 0, 0);
REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `CONFIG`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`, `MENU_MASTER`, `PACKAGE_NAME`, `INTERNAL_PACKAGE`, `CRUD`, `C`, `R`, `U`, `D`) VALUES ('13040501', 'SKALA MORSE', 4, 'Skala Morse', 1, 'rekammedis-penilaian-risikojatuh-skalamorse-workspace', NULL, NULL, 0, 0, 0, NULL, 1, 0, 0, 0, 0, 0);

REPLACE INTO `objek` (`ID`, `TABEL`, `ENTITY`, `SERVICE`, `DESKRIPSI`, `STATUS`) VALUES ('21033', 'medicalrecord.penilaian_skala_morse', 'MedicalRecord\\V1\\Rest\\PenilaianSkalaMorse\\PenilaianSkalaMorseEntity', 'MedicalRecord\\V1\\Rest\\PenilaianSkalaMorse\\Service', NULL, 1);
