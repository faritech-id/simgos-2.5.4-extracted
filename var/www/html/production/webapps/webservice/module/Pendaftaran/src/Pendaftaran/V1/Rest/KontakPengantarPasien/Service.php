<?php
namespace Pendaftaran\V1\Rest\KontakPengantarPasien;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;

class Service extends DBService
{
    public function __construct() {
		$this->config["entityName"] = "Pendaftaran\\V1\\Rest\\KontakPengantarPasien\\KontakPengantarPasienEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("kontak_pengantar_pasien", "pendaftaran"));
		$this->entity = new KontakPengantarPasienEntity();	
    }
	
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		$jenis = $this->entity->get('JENIS');
		$id = $this->entity->get('ID');
		$cek = $this->table->select(["JENIS" => $jenis, "ID" => $id])->toArray(); 
		if(count($cek) > 0) {
			$this->table->update($this->entity->getArrayCopy(), ["JENIS" => $jenis, "ID" => $id]);
		} else {
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return [
			'success' => true
		];
	}
}