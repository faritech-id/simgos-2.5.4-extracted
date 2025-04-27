
UPDATE master.referensi SET ID = 8 WHERE ID = 6 AND JENIS = 215;
UPDATE master.referensi SET ID = 9 WHERE ID = 7 AND JENIS = 215;
UPDATE master.referensi SET ID = 10 WHERE ID = 8 AND JENIS = 216;

UPDATE layanan.telaah_awal_resep t SET REF_TELAAH = 8 WHERE REF_TELAAH = 6 AND JENIS = 1;
UPDATE layanan.telaah_awal_resep t SET REF_TELAAH = 9 WHERE REF_TELAAH = 7 AND JENIS = 1;
UPDATE layanan.telaah_awal_resep t SET REF_TELAAH = 10 WHERE REF_TELAAH = 8 AND JENIS = 2;