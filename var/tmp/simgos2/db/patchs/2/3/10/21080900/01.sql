USE kemkes;

ALTER TABLE `pasien_tb`
    CHANGE COLUMN `id_tb_03` `id_tb_03` CHAR(30) NULL DEFAULT NULL COMMENT 'kod_faskes/4digit_nama_pasien/tanggal_lahir/urutan \r\ndata dikeluarkan oleh SITB sebagai feedback ketika\r\ndata berhasil dikirimkan' COLLATE 'latin1_swedish_ci' AFTER `nourut_pasien`,
    CHANGE COLUMN `Nik` `nik` CHAR(16) NOT NULL COMMENT 'NIK' COLLATE 'latin1_swedish_ci' AFTER `kd_pasien`,
	CHANGE COLUMN `Noregkab` `noregkab` CHAR(25) NULL DEFAULT NULL COMMENT 'urutan pasien ditingkat kab' COLLATE 'latin1_swedish_ci' AFTER `kd_wasor`,
	CHANGE COLUMN `Ppk` `ppk` TINYINT NULL DEFAULT NULL COMMENT 'REF 112 | jika pasien koinfeksi TB HIV diberikan PPK, pilihan: ya/tidak' AFTER `hasil_tes_hiv`,
	CHANGE COLUMN `Art` `art` TINYINT NULL DEFAULT NULL COMMENT 'REF 113 | jika pasien koinfeksi TB HIV mendapatkan ART, pilihan: ya/tidak' AFTER `ppk`,
	CHANGE COLUMN `Umur` `umur` TINYINT NULL DEFAULT NULL COMMENT 'umur pasien dalam tahun' AFTER `pindah_ro`,
	CHANGE COLUMN `Tahun` `tahun` YEAR NULL DEFAULT NULL COMMENT 'tahun pasien mulai pengobatan TB ' AFTER `keterangan`,
	CHANGE COLUMN `Asal_poli` `asal_poli` CHAR(10) NOT NULL COMMENT 'Di isi asal poli' COLLATE 'latin1_swedish_ci' AFTER `kode_icd_x`,
    CHANGE COLUMN `tanggal_mulai_pengobatan` `tanggal_mulai_pengobatan` DATETIME NULL COMMENT 'tanggal mulai pengobatan TB (yyyymmdd)\r\npasien yang pasti diobati\r\n' AFTER `konfirmasiSkoring6`,
	DROP INDEX `tahun`,
	ADD INDEX `tahun` (`tahun`) USING BTREE;