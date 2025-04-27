USE kemkes;

ALTER TABLE `rekap_pasien_komorbid`
	CHANGE COLUMN `icu_tekanan_negatif_dengan_ventilator_confim_l` `icu_tekanan_negatif_dengan_ventilator_confirm_l` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_dengan_ventilator_suspect_p`,
	CHANGE COLUMN `icu_tekanan_negatif_dengan_ventilator_confim_p` `icu_tekanan_negatif_dengan_ventilator_confirm_p` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_dengan_ventilator_confirm_l`,
	CHANGE COLUMN `icu_tekanan_negatif_tanpa_ventilator_confim_l` `icu_tekanan_negatif_tanpa_ventilator_confirm_l` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_tanpa_ventilator_suspect_p`,
	CHANGE COLUMN `icu_tekanan_negatif_tanpa_ventilator_confim_p` `icu_tekanan_negatif_tanpa_ventilator_confirm_p` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_tanpa_ventilator_confirm_l`;

ALTER TABLE `rekap_pasien_nonkomorbid`
	CHANGE COLUMN `icu_tekanan_negatif_dengan_ventilator_confim_l` `icu_tekanan_negatif_dengan_ventilator_confirm_l` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_dengan_ventilator_suspect_p`,
	CHANGE COLUMN `icu_tekanan_negatif_dengan_ventilator_confim_p` `icu_tekanan_negatif_dengan_ventilator_confirm_p` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_dengan_ventilator_confirm_l`,
	CHANGE COLUMN `icu_tekanan_negatif_tanpa_ventilator_confim_l` `icu_tekanan_negatif_tanpa_ventilator_confirm_l` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_tanpa_ventilator_suspect_p`,
	CHANGE COLUMN `icu_tekanan_negatif_tanpa_ventilator_confim_p` `icu_tekanan_negatif_tanpa_ventilator_confirm_p` SMALLINT NOT NULL DEFAULT '0' AFTER `icu_tekanan_negatif_tanpa_ventilator_confirm_l`;

ALTER TABLE `rekap_pasien_keluar`
	CHANGE COLUMN `meninggal_disarded_komorbid` `meninggal_discarded_komorbid` SMALLINT NOT NULL DEFAULT '0' AFTER `meninggal_prob_lansia_tanpa_komorbid`;