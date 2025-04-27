<?php
namespace Aplikasi\V1\Rest\PenggunaAkses;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use Aplikasi\V1\Rest\GroupPenggunaAksesModule\GroupPenggunaAksesModuleService;

class PenggunaAksesService extends Service
{
	private $penggunaaksesmodul;
	
    public function __construct() {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\PenggunaAkses\\PenggunaAksesEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pengguna_akses", "aplikasi"));
		$this->entity = new PenggunaAksesEntity();
		$this->limit = 5000;
		$this->penggunaaksesmodul = new GroupPenggunaAksesModuleService();
	}
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		foreach($data as &$entity) {
			$grouppengguna = $this->penggunaaksesmodul->load(['ID' => $entity['GROUP_PENGGUNA_AKSES_MODULE']]);
			if(count($grouppengguna) > 0) $entity['REFERENSI']['GROUP_PENGGUNA'] = $grouppengguna[0];
		}
		
		return $data;
	}
}
