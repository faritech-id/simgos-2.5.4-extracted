<?php
namespace Pembayaran\V1\Rest\RincianTagihan;

use DBService\DatabaseService;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Laminas\Db\Sql\TableIdentifier;

class RincianTagihanService extends Service
{
	protected $limit = 5000;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("rincian_tagihan", "pembayaran"));
		$this->entity = new RincianTagihanEntity();
    }
   
	public function listRincianTagihan($tagihan, $status) {
		return $this->execute("CALL pembayaran.listRincianTagihan(?,?)", [$tagihan, $status]);
	}
}