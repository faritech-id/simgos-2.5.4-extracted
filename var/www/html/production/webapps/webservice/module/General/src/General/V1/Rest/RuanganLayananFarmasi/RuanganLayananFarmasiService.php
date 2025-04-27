<?php
namespace General\V1\Rest\RuanganLayananFarmasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;

use General\V1\Rest\Ruangan\RuanganService;

class RuanganLayananFarmasiService extends Service
{   
	private $ruangankunjungan;
	private $ruanganlayanan;
	
	public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("poli_layanan_resep", "master"));
		$this->entity = new RuanganLayananFarmasiEntity();
		
		$this->ruangankunjungan = new RuanganService();
		$this->ruanganlayanan = new RuanganService();
    }
    

	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		$ruangan = $this->entity->get('RUANGAN_KUNJUNGAN');
		$farmasi = $this->entity->get('RUANGAN_LAYANAN');
		$cek = $this->table->select(array("RUANGAN_KUNJUNGAN" => $ruangan, "RUANGAN_LAYANAN" => $farmasi))->toArray();
		if(count($cek) > 0) {
			$this->table->update($this->entity->getArrayCopy(), array('RUANGAN_KUNJUNGAN' => $ruangan, "RUANGAN_LAYANAN" => $farmasi));
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return array(
			'success' => true
		);
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		foreach($data as &$entity) {
			$ruangankunjungan = $this->ruangankunjungan->load(array('ID' => $entity['RUANGAN_KUNJUNGAN']));
			if(count($ruangankunjungan) > 0) $entity['REFERENSI']['RUANGAN_KUNJUNGAN'] = $ruangankunjungan[0];
			$ruanganlayanan = $this->ruanganlayanan->load(array('ID' => $entity['RUANGAN_LAYANAN']));
			if(count($ruanganlayanan) > 0) $entity['REFERENSI']['RUANGAN_LAYANAN'] = $ruanganlayanan[0];
		}
		
		return $data;
	}
}