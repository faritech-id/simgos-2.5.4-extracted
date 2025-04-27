<?php
namespace Kemkes\V2\Rest\ReservasiAntrian;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service as DBService;
use General\V1\Rest\Ruangan\RuanganService;
use General\V1\Rest\Pegawai\PegawaiService;

class Service extends DBService
{	
	private $ruangan;
    private $pegawai;

	public function __construct() {
		$this->config["entityName"] = "Kemkes\\V2\\Rest\\ReservasiAntrian\\ReservasiAntrianEntity";		
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("reservasi_antrian", "kemkes"));
		$this->entity = new ReservasiAntrianEntity();

		$this->ruangan = new RuanganService();
		$this->pegawai = new PegawaiService();
    }

	public function load($params = [], $columns = ['*'], $orders = []) {
        $data = parent::load($params, $columns, $orders);
        
        if($this->includeReferences) {
            foreach($data as &$entity) {
                $ruangan = $this->ruangan->load(['ID' => $entity['RUANGAN']]);
                if(count($ruangan) > 0) $entity['REFERENSI']['RUANGAN'] = $ruangan[0];
                
                $entity['REFERENSI']['NAMA'] = $this->namaPegawai($entity['DOKTER']);
            }
        }
        
        return $data;
    }

	private function namaPegawai($nip){
	    $peg = $this->pegawai->load(['NIP'=>$nip], ["NIP", "NAMA", "GELAR_DEPAN", "GELAR_BELAKANG"]);
	    
	    if(count($peg) == 0) return '';
	    
	    if(str_replace(' ','', $peg[0]['GELAR_DEPAN']) != ''){
	        $titik = '. ';
	    }else{
	        $titik = '';
	    }
	    if(str_replace(' ','', $peg[0]['GELAR_BELAKANG']) != ''){
	        $koma = ', ';
	    }else{
	        $koma = '';
	    }
	    return $peg[0]['GELAR_DEPAN'].$titik.$peg[0]['NAMA'].$koma.$peg[0]['GELAR_BELAKANG'];
	}
}