INSERT INTO layanan.status_hasil_pemeriksaan(TINDAKAN_MEDIS_ID, JENIS)
SELECT tm.ID, t.JENIS
  FROM layanan.tindakan_medis tm,
  		 `master`.tindakan t
 WHERE t.ID = tm.TINDAKAN
   AND tm.`STATUS` = 1
   AND t.JENIS IN (8);

INSERT INTO layanan.status_hasil_pemeriksaan(TINDAKAN_MEDIS_ID, JENIS)
SELECT tm.ID, t.JENIS
  FROM layanan.tindakan_medis tm,
  		 `master`.tindakan t
 WHERE t.ID = tm.TINDAKAN
   AND tm.`STATUS` = 1
   AND t.JENIS IN (7);

UPDATE layanan.status_hasil_pemeriksaan shp, layanan.hasil_lab hl, layanan.tindakan_medis tm, pendaftaran.kunjungan k
   SET shp.STATUS_HASIL = IF(k.FINAL_HASIL = 1, 3, 2)
 WHERE shp.JENIS = 8
   AND hl.TINDAKAN_MEDIS = shp.TINDAKAN_MEDIS_ID
   AND tm.ID = hl.TINDAKAN_MEDIS
   AND tm.`STATUS` = 1
   AND k.NOMOR = tm.KUNJUNGAN;

UPDATE layanan.status_hasil_pemeriksaan shp, layanan.hasil_rad hr, layanan.tindakan_medis tm, pendaftaran.kunjungan k
   SET shp.STATUS_HASIL = IF(k.FINAL_HASIL = 1, 3, 2)
 WHERE shp.JENIS = 7
   AND hr.TINDAKAN_MEDIS = shp.TINDAKAN_MEDIS_ID
   AND tm.ID = hr.TINDAKAN_MEDIS
   AND tm.`STATUS` = 1
   AND k.NOMOR = tm.KUNJUNGAN;
