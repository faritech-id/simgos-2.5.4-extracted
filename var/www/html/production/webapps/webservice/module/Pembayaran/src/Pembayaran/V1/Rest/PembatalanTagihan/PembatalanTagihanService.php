<?php
namespace Pembayaran\V1\Rest\PembatalanTagihan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;
use Pembayaran\V1\Rest\TagihanKlaim\Service as TagihanKlaimService;

class PembatalanTagihanService extends Service
{
	private $tagihanKlaim;
	
    public function __construct() {
		$this->config["entityName"] = "Pembayaran\\V1\\Rest\\PembatalanTagihan\\PembatalanTagihanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pembatalan_tagihan", "pembayaran"));
		$this->entity = new PembatalanTagihanEntity();

		$this->tagihanKlaim = new TagihanKlaimService(false);
    }

	public function sudahKlaim($tagihan) {
		$founds = $this->tagihanKlaim->load([
			"TAGIHAN" => $tagihan,
			"STATUS" => 1
		]);

		return count($founds) > 0;
	}
}
