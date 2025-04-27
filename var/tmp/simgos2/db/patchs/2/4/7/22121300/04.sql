INSERT INTO `master`.group_pemeriksaan(JENIS, KODE, LEVEL, DESKRIPSI, STATUS)
SELECT 8, gl.ID, gl.JENIS LEVEL, gl.DESKRIPSI, gl.`STATUS`
  FROM `master`.group_lab gl
 WHERE NOT EXISTS(SELECT 1 FROM `master`.group_pemeriksaan gp WHERE gp.JENIS = 8 AND gp.KODE = gl.ID AND gp.`LEVEL` = gl.JENIS);

INSERT INTO `master`.mapping_group_pemeriksaan(GROUP_PEMERIKSAAN_ID, PEMERIKSAAN, STATUS)
SELECT gp.ID, gt.TINDAKAN, gt.`STATUS`
  FROM `master`.group_tindakan_lab gt,
       `master`.group_pemeriksaan gp
 WHERE gp.KODE = gt.GROUP_LAB
   AND NOT EXISTS(SELECT 1 FROM `master`.mapping_group_pemeriksaan mgp WHERE mgp.GROUP_PEMERIKSAAN_ID = gp.ID AND mgp.PEMERIKSAAN = gt.TINDAKAN)
 ORDER BY gp.ID, gt.TINDAKAN