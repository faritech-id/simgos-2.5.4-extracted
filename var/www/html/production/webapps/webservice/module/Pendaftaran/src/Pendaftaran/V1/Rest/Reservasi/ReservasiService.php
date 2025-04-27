<?php
/**
 * SIMpel Development
 *
 * @link      
 * @copyright Copyright (c) 2015-2019 SIMpel Development
 * @license   
 */

namespace Pendaftaran\V1\Rest\Reservasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\generator\Generator;
use Zend\json\Json;
use DBService\System;
use DBService\Service;
use General\V1\Rest\RuangKamarTidur\RuangKamarTidurService;
use Pendaftaran\V1\Rest\AntrianTempatTidur\Service as antrianTempatTidurService;
/**
 * Reservasi Service
 */
class ReservasiService extends Service
{
	/**
     * @var RuangKamarTidurService
     */
	private $ruangKamar;
	private $antriantt;
	
	/**
     * @var Config Referensi
     */
	protected $references = array(
		'RuangKamar' => true
	);
	
	/**
     * Constructor
     *
     * @param  boolean $includeReferences
     * @param  Config Referensi $references
     */
	public function __construct($includeReferences = true, $references = array()) {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("reservasi", "pendaftaran"));
		$this->entity = new ReservasiEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		$this->antriantt = new antrianTempatTidurService();
		if($includeReferences) {			
			if($this->references['RuangKamar']) $this->ruangKamar = new RuangKamarTidurService();
		}
    }	
	
	/**
     * Simpan Data Reservasi 
     *
     * @param object|array $data
     * @return array 
     */
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$nomor = $this->entity->get('NOMOR');
		$cek = $this->table->select(array("NOMOR" => $nomor))->toArray();  
		
		if(count($cek) > 0) {
			$_data = $this->entity->getArrayCopy();
			$this->table->update($_data, array("NOMOR" => $nomor, 'STATUS' => 1));
		} else {
			$nomor = Generator::generateNoReservasi();			
			$this->entity->set('NOMOR', $nomor);
			$this->entity->set('TANGGAL', new \Laminas\Db\Sql\Expression('NOW()'));			
			$_data = $this->entity->getArrayCopy();
			$this->table->insert($_data);
		}

		$this->onAfterSaveCallback($nomor, $data);

		return array(
			'success' => true,
			'data' => $this->load(array('NOMOR' => $nomor))
		);
	}

	protected function onAfterSaveCallback($id, $data) {
		if(isset($data['REFERENSI'])) {			
			foreach($data['REFERENSI'] as $att) {
				$att['STATUS'] = 2;
				$att['RESERVASI_NOMOR'] = $id;
				$this->antriantt->simpanData($att, false, false);
			}
		}
	}
	
	/**
     * Load Data Reservasi 
     *
     * @param array $params untuk filter data
	 * @param array $columns kolom yang akan ditampilkan
	 * @param array $orders urutan data berdasarkan field tertentu
     * @return array Data Reservasi
     */
	public function load($params = array(), $columns = array('*'), $orders = array()) {
		$data = parent::load($params, $columns, $orders);
		
		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['RuangKamar']) {
					$ruangKamar = $this->ruangKamar->load(array('ID' => $entity['RUANG_KAMAR_TIDUR']));
					if(count($ruangKamar) > 0) $entity['REFERENSI']['RUANG_KAMAR_TIDUR'] = $ruangKamar[0];
				}
			}
		}
		
		return $data;
	}

	/**
     * Pengecekan tempat tidur yang sudah terpesan
     *
     * @param date $tanggal untuk filter data berdasarkan tanggal format Y-m-d
	 * @param int $ruangKamarTidur untuk filter data berdasarkan ruang kamar tidur
	 * @return bool true jika terpesan & false jika belum terpesan
     */
	public function tempatTidurTerpesan($tanggal, $ruangKamarTidur) {
		$params = [];
		$params[] = new \Laminas\Db\Sql\Predicate\Between("TANGGAL", $tanggal." 00:00:00", $tanggal." 23:59:59");
		$params["RUANG_KAMAR_TIDUR"] = $ruangKamarTidur;
		$params["STATUS"] = 1;

		$terpesan = $this->getRowCount($params);
		
		return $terpesan > 0;
	}
}