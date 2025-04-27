USE `kemkes-rsonline`;

CREATE TABLE IF NOT EXISTS `data_kebutuhan_apd` (
	PRIMARY KEY(id_kebutuhan),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.data_kebutuhan_apd;

CREATE TABLE IF NOT EXISTS `data_kebutuhan_sdm` (
	PRIMARY KEY(id_kebutuhan),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.data_kebutuhan_sdm;

CREATE TABLE IF NOT EXISTS `data_tempat_tidur` (
	PRIMARY KEY(id),
	UNIQUE(id_tt, ruang),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.data_tempat_tidur;

CREATE TABLE IF NOT EXISTS `diagnosa_pasien` (
	PRIMARY KEY(id),
	UNIQUE(nomr, icd, LEVEL),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.diagnosa_pasien;

CREATE TABLE IF NOT EXISTS `icd_covid19` (
	PRIMARY KEY(KODE)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.icd_covid19;

CREATE TABLE IF NOT EXISTS `jenis_kelamin` (
	PRIMARY KEY(id_gender)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.jenis_kelamin;

CREATE TABLE IF NOT EXISTS `jenis_pasien` (
	PRIMARY KEY(id_jenis_pasien)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.jenis_pasien;

CREATE TABLE IF NOT EXISTS `kabupaten` (
	PRIMARY KEY(kode),
	KEY(propinsi)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.kabupaten;

CREATE TABLE IF NOT EXISTS `kamar_simrs_rs_online` (
	PRIMARY KEY(id),
	UNIQUE(ruang_kamar),
	KEY(tempat_tidur),
	KEY(status)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.kamar_simrs_rs_online;

CREATE TABLE IF NOT EXISTS `kebutuhan_apd` (
	PRIMARY KEY(id_kebutuhan)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.kebutuhan_apd;

CREATE TABLE IF NOT EXISTS `kebutuhan_sdm` (
	PRIMARY KEY(id_kebutuhan)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.kebutuhan_sdm;

CREATE TABLE IF NOT EXISTS `kecamatan` (
	PRIMARY KEY(kode),
	KEY(kabkota)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.kecamatan;

CREATE TABLE IF NOT EXISTS `kewarganegaraan` (
	PRIMARY KEY(id_nation)
) ENGINE=INNODB
AS
SELECT * FROM kemkes.kewarganegaraan;

CREATE TABLE IF NOT EXISTS `pasien` (
	PRIMARY KEY(nomr),
	KEY(noc),
	KEY(kirim)
) ENGINE=INNODB COMMENT 'Pasien yang teridentifikasi ODP, PDP dan Covid'
AS
SELECT * FROM kemkes.pasien;

CREATE TABLE IF NOT EXISTS `propinsi` (
	PRIMARY KEY(prop_kode)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.propinsi;

CREATE TABLE IF NOT EXISTS `rekap_pasien_keluar` (
	PRIMARY KEY(id),
	UNIQUE(tanggal),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.rekap_pasien_keluar;

CREATE TABLE IF NOT EXISTS `rekap_pasien_komorbid` (
	PRIMARY KEY(id),
	UNIQUE(tanggal),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.rekap_pasien_komorbid;

CREATE TABLE IF NOT EXISTS `rekap_pasien_masuk` (
	PRIMARY KEY(id),
	UNIQUE(tanggal),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.rekap_pasien_masuk;

CREATE TABLE IF NOT EXISTS `rekap_pasien_nonkomorbid` (
	PRIMARY KEY(id),
	UNIQUE(tanggal),
	KEY(kirim)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.rekap_pasien_nonkomorbid;

CREATE TABLE IF NOT EXISTS `status_isolasi` (
	PRIMARY KEY(id_isolasi),
	KEY(id_status_rawat)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.status_isolasi;

CREATE TABLE IF NOT EXISTS `status_keluar` (
	PRIMARY KEY(id_status)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.status_keluar;

CREATE TABLE IF NOT EXISTS `status_rawat` (
	PRIMARY KEY(id_status_rawat)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.status_rawat;

CREATE TABLE IF NOT EXISTS `sumber_penularan` (
	PRIMARY KEY(id_source)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.sumber_penularan;

CREATE TABLE IF NOT EXISTS `tempat_tidur` (
	PRIMARY KEY(kode_tt)
) ENGINE=InnoDB
AS
SELECT * FROM kemkes.tempat_tidur;
