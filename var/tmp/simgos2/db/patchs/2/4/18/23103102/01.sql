INSERT INTO `master`.referensi(JENIS, ID, DESKRIPSI, REF_ID, STATUS)
SELECT 172, 6, 'Deposit', '', 0 FROM `master`.referensi r
 WHERE jenis = 172 AND NOT EXISTS(SELECT 1 FROM `master`.referensi r2 WHERE r2.JENIS = 172 AND r2.ID = 6)
 LIMIT 1;