USE `aplikasi`;

REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `CONFIG`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`, `MENU_MASTER`, `PACKAGE_NAME`, `INTERNAL_PACKAGE`, `CRUD`, `C`, `R`, `U`, `D`) VALUES ('13040502', 'SKALA HUMPTY DUMPY', 4, 'Skala Humpty Dumpty', 1, 'rekammedis-penilaian-risikojatuh-skalahumptydumpty-workspace', NULL, NULL, 0, 0, 0, NULL, 1, 0, 0, 0, 0, 0);

REPLACE INTO `objek` (`ID`, `TABEL`, `ENTITY`, `SERVICE`, `DESKRIPSI`, `STATUS`) VALUES ('21035', 'medicalrecord.penilaian_skala_humpty_dumpty', 'MedicalRecord\\V1\\Rest\\PenilaianSkalaHumptyDumpty\\PenilaianSkalaHumptyDumptyEntity', 'MedicalRecord\\V1\\Rest\\PenilaianSkalaHumptyDumpty\\Service', NULL, 1);
