<?php
namespace Pembatalan\V1\Rest\PembatalanKunjungan;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use DBService\System;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;

use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;
//use General\V1\Rest\Referensi\ReferensiService;

class PembatalanKunjunganService extends Service
{
	private $kunjungan;

	protected $references = array(
		'Kunjungan' => true
	);
	
    public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("pembatalan_kunjungan", "pembatalan"));
		$this->entity = new PembatalanKunjunganEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
				
		if($includeReferences) {			
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService();
		}
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;		
		$this->entity->exchangeArray($data);
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : 0;
		
		if($id > 0) {
			$this->table->update($this->entity->getArrayCopy(), array("ID" => $id));
		} else {			
			$this->table->insert($this->entity->getArrayCopy());
			$id = $this->table->getLastInsertValue();
		}
		
		return $this->load(array('ID' => $id));
	}
	
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Kunjungan']) {
					$kunjungan = $this->kunjungan->load(array('NOMOR' => $entity['KUNJUNGAN']));
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
			}
		}
		
		return $data;
	}
	
	public function getKunjungan() {
		return $this->kunjungan;
	}

	public function isValidasiTransaksiStokOpname($ruangan,$tanggal) {
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("SELECT inventory.getPeriodeAkhirSo('".$ruangan."') PERIODE");
		$queryLmt = $strLmt->execute();
		if(count($queryLmt) > 0) {
			$rowLmt = $queryLmt->current();
			if($rowLmt['PERIODE']  > $tanggal) {
				return false;
			}
		}
		return true;
	}
	public function isFoundRetur($kunjungan) {
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("SELECT 1 FROM layanan.farmasi f, layanan.retur_farmasi r WHERE r.ID_FARMASI = f.ID AND f.KUNJUNGAN = ? ");
		$queryLmt = $strLmt->execute([$kunjungan]);
		if(count($queryLmt) > 0) {
			return true;
		}
		return false;
	}
	public function isFoundLynBonSisa($kunjungan) {
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("SELECT 1 FROM layanan.farmasi f, layanan.bon_sisa_farmasi bf, layanan.layanan_bon_sisa_farmasi lbf WHERE lbf.REF = bf.ID AND lbf.STATUS = 1 AND bf.REF = f.ID AND bf.STATUS = 1 AND f.KUNJUNGAN = ? ");
		$queryLmt = $strLmt->execute([$kunjungan]);
		if(count($queryLmt) > 0) {
			return true;
		}
		return false;
	}
}