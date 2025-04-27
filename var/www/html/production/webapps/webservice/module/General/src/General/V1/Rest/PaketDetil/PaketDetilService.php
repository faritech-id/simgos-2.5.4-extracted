<?php
namespace General\V1\Rest\PaketDetil;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

use General\V1\Rest\Tindakan\TindakanService;
use Inventory\V1\Rest\Barang\BarangService;
use General\V1\Rest\Administrasi\AdministrasiService;
use General\V1\Rest\Ruangan\RuanganService;

class PaketDetilService extends Service
{
	private $tindakan;
	private $barang;
	private $administrasi;
	private $ruangan;
	
	protected $references = [
		'Ruangan' => true
	];

    public function __construct($includeReferences = true, $references = []) {
		$this->config["entityName"] = "General\\V1\\Rest\\PaketDetil\\PaketDetilEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("paket_detil", "master"));
		$this->entity = new PaketDetilEntity();
		$this->limit = 1000;
		
		$this->setReferences($references);

		$this->includeReferences = $includeReferences;
		if($includeReferences) {			
			if($this->references['Ruangan']) $this->ruangan = new RuanganService();
		}
		
		$this->tindakan = new TindakanService();
		$this->barang = new BarangService();
		$this->administrasi = new AdministrasiService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Ruangan']) {
					$ruangan = $this->ruangan->load(['ID' => $entity['RUANGAN']]);
					if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $ruangan[0];
				}
				if ($entity['JENIS'] == 1) {
					$namaitem = $this->tindakan->load(['ID' => $entity['ITEM']]);
					if(count($namaitem) > 0) $entity['REFERENSI']['NAMA_ITEM'] = $namaitem[0];

				} else if($entity['JENIS'] == 2) {
					$namaitem = $this->barang->load(['ID' => $entity['ITEM']]);
					if(count($namaitem) > 0) $entity['REFERENSI']['NAMA_ITEM'] = $namaitem[0];
				
				} else if($entity['JENIS'] == 3) {
					$namaitem = $this->administrasi->load(['ID' => $entity['ITEM']]);
					if(count($namaitem) > 0) $entity['REFERENSI']['NAMA_ITEM'] = $namaitem[0];
				} else {
					$entity['REFERENSI']['NAMA_ITEM'] = [
						"ID" => 0,
						"NAMA" => "O2",
						"STATUS" => "1"
					];
				}
			}
		}
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'STATUS')) {
			$params['paket_detil.STATUS'] = $params['STATUS'];
			unset($params['STATUS']);
		}
		if(!System::isNull($params, 'JENIS')) {
			$params['paket_detil.JENIS'] = $params['JENIS'];
			unset($params['JENIS']);
		}
		if(!System::isNull($params, 'JENIS_KUNJUNGAN')) {
			$select->join(
				['r' => new TableIdentifier('ruangan', 'master')],
				'r.ID = paket_detil.RUANGAN',
				[]
			);
			$params['r.JENIS_KUNJUNGAN'] = $params['JENIS_KUNJUNGAN'];
			unset($params['JENIS_KUNJUNGAN']);
		}
	}
}