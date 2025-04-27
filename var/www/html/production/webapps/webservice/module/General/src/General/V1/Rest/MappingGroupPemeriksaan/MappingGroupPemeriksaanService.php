<?php
namespace General\V1\Rest\MappingGroupPemeriksaan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use General\V1\Rest\Tindakan\TindakanService;

class MappingGroupPemeriksaanService extends Service
{
	private $tindakan;
	protected $limit = 5000;
	
    public function __construct() {
		$this->config["entityName"] = "General\\V1\\Rest\\MappingGroupPemeriksaan\\MappingGroupPemeriksaanEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("mapping_group_pemeriksaan", "master"));
		$this->entity = new MappingGroupPemeriksaanEntity();
		$this->tindakan = new TindakanService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$result = $this->tindakan->load(['ID' => $entity['PEMERIKSAAN']]);
			if(count($result) > 0) $entity['REFERENSI']['PEMERIKSAAN'] = $result[0];
		}
		return $data;
	}
}