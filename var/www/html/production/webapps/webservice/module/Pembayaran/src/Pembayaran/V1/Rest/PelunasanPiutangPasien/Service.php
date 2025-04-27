<?php
namespace Pembayaran\V1\Rest\PelunasanPiutangPasien;
use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\TableIdentifier;
use DBService\System;
use DBService\generator\Generator;
use DBService\Service as dbService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;

class Service extends dbService {
	private $tagihan;
	
    public function __construct($includereferences = true, $references = array()) {
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("pelunasan_piutang_pasien", "pembayaran"));
        $this->entity = new PelunasanPiutangPasienEntity(); 
        $this->config["entityName"] = "\\Pembayaran\\V1\\Rest\\PelunasanPiutangPasien\\PelunasanPiutangPasienEntity";
        $this->config["entityId"] = "ID";

        $this->tagihan = new TagihanService();
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
				foreach($tagihan as $dtl) {
					$dtl['ID'] = $nomor;
					$dtl['REF'] = $id;
					$this->tagihan->simpan($dtl);
				}
			}
		}
	}

	public function cekPembayaranPiutangBelumFinal($tagihan){
		$data = $this->execute("
			SELECT * FROM pembayaran.pelunasan_piutang_pasien ppp
			LEFT JOIN pembayaran.tagihan t ON t.REF = ppp.ID AND t.JENIS = 2
			WHERE ppp.TAGIHAN_PIUTANG = '".$tagihan."' AND t.`STATUS` = 1"
		);
		return count($data) > 0;
	}
}
