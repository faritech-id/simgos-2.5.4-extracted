<?php
namespace General\V1\Rest\NilaiRujukanLab;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as dbService;
use General\V1\Rest\Referensi\ReferensiService;

class Service extends dbService{
    private $JenisKelamin;

    protected $references = [
		'JenisKelamin' => true
    ];

    public function __construct($includeReferences = true, $references = []){
        $this->config["entityName"] = "\\General\\V1\\Rest\\NilaiRujukanLab\\NilaiRujukanLabEntity";
        $this->config["entityId"] = "ID";
        $this->table = DatabaseService::get("SIMpel")->get(new TableIdentifier("nilai_rujukan_lab","master"));
        $this->entity = new NilaiRujukanLabEntity();
        
        $this->setReferences($references);
		
		$this->includeReferences = $includeReferences;

		if($includeReferences) {
            if($this->references['JenisKelamin']) $this->JenisKelamin = new ReferensiService();
        }
    }

    public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
            if($this->includeReferences) {
                if($this->references['JenisKelamin']){
                    $JenisKelamin = $this->JenisKelamin->load(array('ID' => $entity['JENIS_KELAMIN'], 'JENIS' => 2));
                    if(count($JenisKelamin) > 0) $entity['REFERENSI']['JENIS_KELAMIN'] = $JenisKelamin[0];
                }
            }
		}
        	
		return $data;
	}
}