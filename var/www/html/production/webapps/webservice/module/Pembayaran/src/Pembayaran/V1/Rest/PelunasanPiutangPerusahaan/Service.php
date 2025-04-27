<?php
namespace Pembayaran\V1\Rest\PelunasanPiutangPerusahaan;
use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\generator\Generator;
use DBService\Service as dbService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends dbService {
	private $tagihan;
	private $referensi;
	
    public function __construct($includereferences = true, $references = array()) {
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pelunasan_piutang_perusahaan", "pembayaran"));
        $this->entity = new PelunasanPiutangPerusahaanEntity();
        $this->config["entityName"] = "\\Pembayaran\\V1\\Rest\\PelunasanPiutangPerusahaan\\PelunasanPiutangPerusahaanEntity";
        $this->config["entityId"] = "ID";

		$this->tagihan = new TagihanService();
		$this->referensi = new ReferensiService();
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$referensi = $this->referensi->load(array('ID' => $entity['PENJAMIN'], 'JENIS' => 10));
			if(count($referensi) > 0) $entity['REFERENSI']['PENJAMIN'] = $referensi[0];
		}
		
		return $data;
	}

    protected function onAfterSaveCallback($id, $data) {
		$this->SimpanTagihan($data, $id);
	}

    private function SimpanTagihan($data, $id) {
		if(isset($data['TAGIHAN'])) {
			$tagihan = $data['TAGIHAN'];
			if(isset($tagihan["REF"]) && isset($tagihan["JENIS"])) {
				$finds = $this->tagihan->load([
					"REF" => $tagihan["REF"],
					"JENIS" => $tagihan["JENIS"],
					"STATUS" => 1
				]);
				if(count($finds) > 0) {
					$tagihan["ID"] = $finds[0]["ID"];
					$this->tagihan->simpanData($tagihan, false, false);
				}
			} else {
				$nomor = Generator::generateNoTagihan();
				$user = $data['OLEH'];
				foreach($tagihan as $dtl) {
					$dtl['ID'] = $nomor;
					$dtl['REF'] = $id;
					$dtl['OLEH'] = $user;
					$this->tagihan->simpan($dtl);
				}
			}
		}
	}

	public function cekPembayaranPiutangBelumFinal($tagihan, $penjamin){
		$data = $this->execute("
			SELECT * FROM pembayaran.pelunasan_piutang_perusahaan ppp
			LEFT JOIN pembayaran.tagihan t ON t.REF = ppp.ID AND t.JENIS = 3
			WHERE ppp.TAGIHAN_PIUTANG = '".$tagihan."' AND ppp.PENJAMIN = '".$penjamin."' AND t.`STATUS` = 1
		");
		return count($data) > 0;
	}
}
