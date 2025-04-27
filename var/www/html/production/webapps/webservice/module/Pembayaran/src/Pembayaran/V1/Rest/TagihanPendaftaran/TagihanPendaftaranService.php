<?php
namespace Pembayaran\V1\Rest\TagihanPendaftaran;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;
use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class TagihanPendaftaranService extends Service
{	
	private $pendaftaran;
	private $kunjungan;
	private $tagihan;
	
	protected $references = [
		'Pendaftaran' => true,
		'Kunjungan' => true,
		'Tagihan' => true,
	];
	
    public function __construct($includeReferences = true, $references = []) {
        $this->config["entityName"] = "Pembayaran\\V1\\Rest\\TagihanPendaftaran\\TagihanPendaftaranEntity";
		$this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("tagihan_pendaftaran", "pembayaran"));
		$this->entity = new TagihanPendaftaranEntity();
		
		$this->setReferences($references);
		
		$this->includeReferences = $includeReferences;
		
		if($includeReferences) {
			if($this->references['Pendaftaran']) $this->pendaftaran = new PendaftaranService();
			if($this->references['Kunjungan']) $this->kunjungan = new KunjunganService(true, [
				'Ruangan' => true,
				'Referensi' => false,
				'Pendaftaran' => false,
				'RuangKamarTidur' => false,
				'PasienPulang' => false,
				'Pembatalan' => false,
				'Perujuk' => false,
				'Mutasi' => false,
				'RujukanKeluar' => false,
				'DPJP' => false
			]);
			if($this->references['Tagihan']) $this->tagihan = new TagihanService();
		}
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);

		if($this->includeReferences) {
			foreach($data as &$entity) {
				if($this->references['Pendaftaran']) {
					if(is_object($this->references['Pendaftaran'])) {
						$references = isset($this->references['Pendaftaran']->REFERENSI) ? (array) $this->references['Pendaftaran']->REFERENSI : [];
						$this->pendaftaran->setReferences($references, true);
						if(isset($this->references['Pendaftaran']->COLUMNS)) $this->pendaftaran->setColumns((array) $this->references['Pendaftaran']->COLUMNS);
					}
					$pendaftaran = $this->pendaftaran->load(['NOMOR' => $entity['PENDAFTARAN']]);
					if(count($pendaftaran) > 0) $entity['REFERENSI']['PENDAFTARAN'] = $pendaftaran[0];
				}

				if($this->references['Kunjungan']) {
					if(is_object($this->references['Kunjungan'])) {
						$references = isset($this->references['Kunjungan']->REFERENSI) ? (array) $this->references['Kunjungan']->REFERENSI : [];
						$this->kunjungan->setReferences($references, true);
						if(isset($this->references['Kunjungan']->COLUMNS)) $this->kunjungan->setColumns((array) $this->references['Kunjungan']->COLUMNS);
					}
					$kunjungan = $this->kunjungan->load(['NOMOR' => $entity['REF']]);
					if(count($kunjungan) > 0) $entity['REFERENSI']['KUNJUNGAN'] = $kunjungan[0];
				}
				
				if($this->references['Tagihan']) {
					if(is_object($this->references['Tagihan'])) {
						$references = isset($this->references['Tagihan']->REFERENSI) ? (array) $this->references['Tagihan']->REFERENSI : [];
						$this->tagihan->setReferences($references, true);
						if(isset($this->references['Tagihan']->COLUMNS)) $this->tagihan->setColumns((array) $this->references['Tagihan']->COLUMNS);						
					}
					$tagihan = $this->tagihan->load(['ID' => $entity['TAGIHAN']]);
					if(count($tagihan) > 0) $entity['REFERENSI']['TAGIHAN'] = $tagihan[0];
				}
			}
		}
		
		return $data;
	}
}
