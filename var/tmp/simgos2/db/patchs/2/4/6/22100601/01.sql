USE `aplikasi`;

REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `CONFIG`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`, `MENU_MASTER`, `PACKAGE_NAME`, `INTERNAL_PACKAGE`, `CRUD`, `C`, `R`, `U`, `D`) VALUES ('130407', 'DEKUBITUS', 3, 'Dekubitus', 1, 'rekammedis-penilaian-dekubitus-workspace', NULL, NULL, 0, 0, 0, NULL, 1, 0, 0, 0, 0, 0);

REPLACE INTO `objek` (`ID`, `TABEL`, `ENTITY`, `SERVICE`, `DESKRIPSI`, `STATUS`) VALUES ('21034', 'medicalrecord.penilaian_dekubitus', 'MedicalRecord\\V1\\Rest\\PenilaianDekubitus\\PenilaianDekubitusEntity', 'MedicalRecord\\V1\\Rest\\PenilaianDekubitus\\Service', NULL, 1);
