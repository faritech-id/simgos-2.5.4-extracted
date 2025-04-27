<?php
namespace Layanan\V1\Rest\OrderDetilLab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use General\V1\Rest\Tindakan\TindakanService;
use General\V1\Rest\Referensi\ReferensiService;
use Layanan\V1\Rest\PermintaanDarahDetail\Service as PermintaanDarahDetailService;

class OrderDetilLabService extends Service
{
	private $tindakan;
	private $referensi;
	private $permintaandarah;

    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("order_detil_lab", "layanan"));
		$this->entity = new OrderDetilLabEntity();
		
		$this->tindakan = new TindakanService();
		$this->permintaandarah = new PermintaanDarahDetailService();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$order_id = $this->entity->get('ORDER_ID');
		$tindakan = $this->entity->get('TINDAKAN');
		
		$cek = $this->table->select(["ORDER_ID" => $order_id, "TINDAKAN" => $tindakan])->toArray();
		if(count($cek) > 0) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, ["ORDER_ID" => $order_id, "TINDAKAN" => $tindakan]);
		} else {
			$_data = $this->entity->getArrayCopy();
			$this->table->insert($_data);
		}

		$this->SimpanDetilPermintaanDarah($data, $order_id);
	}

	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$tindakan = $this->tindakan->load(['ID' => $entity['TINDAKAN']]);
			if(count($tindakan) > 0) $entity['REFERENSI']['TINDAKAN'] = $tindakan[0];
		}
		
		return $data;
	}

	private function SimpanDetilPermintaanDarah($data, $order_id) {
		if(isset($data['PD'])) {
			foreach($data['PD'] as $tgs) {
				$tgs = [
					"KUNJUNGAN" => $tgs['KUNJUNGAN'],
					"KOMPONEN" => (int)$tgs['KOMPONEN'],
					"QTY" => (int)$tgs['QTY'],
					"ORDER_ID" => $order_id
				];
				$this->permintaandarah->simpanData($tgs, true);
			}
		}
	}
	
}