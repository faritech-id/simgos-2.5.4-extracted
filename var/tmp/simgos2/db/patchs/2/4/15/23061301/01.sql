REPLACE INTO aplikasi.`properti_config` (`ID`, `NAMA`, `VALUE`, `DESKRIPSI`) VALUES (69, 'KUNCI_SEMUA_TRANSAKSI_SEBELUM_DI_FINAL_TAGIHAN', 'FALSE', 'Jika TRUE maka tombol penguncian semua transaksi pelayanan sebelum dilakukan final tagihan akan tampil di form tagihan. Semua pengguna harus melakukan login kembali');

USE pembayaran;

ALTER TABLE `tagihan`
	ADD COLUMN `KUNCI` TINYINT NOT NULL DEFAULT 0 COMMENT '0 = Tdk Terkunci; 1 = Terkunci' AFTER `LAMA_PENGGUNAAN_VENTILATOR`;
