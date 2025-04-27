USE `aplikasi`;

REPLACE INTO `modules` (`ID`, `NAMA`, `LEVEL`, `DESKRIPSI`, `STATUS`, `CLASS`, `CONFIG`, `ICON_CLS`, `HAVE_CHILD`, `MENU_HOME`, `MENU_MASTER`, `PACKAGE_NAME`, `INTERNAL_PACKAGE`, `CRUD`, `C`, `R`, `U`, `D`) VALUES ('13040503', 'EDMONSON PSYCHIATRIC FALL RISK ASSESSMENT', 4, 'Edmonson Psychiatric Fall Risk Assessment', 1, 'rekammedis-penilaian-risikojatuh-epfra-workspace', NULL, NULL, 0, 0, 0, NULL, 1, 0, 0, 0, 0, 0);

REPLACE INTO `objek` (`ID`, `TABEL`, `ENTITY`, `SERVICE`, `DESKRIPSI`, `STATUS`) VALUES ('21036', 'medicalrecord.penilaian_epfra', 'MedicalRecord\\V1\\Rest\\PenilaianEpfra\\PenilaianEpfraEntity', 'MedicalRecord\\V1\\Rest\\PenilaianEpfra\\Service', NULL, 1);
