<?php
namespace Layanan\V1\Rest\ReturFarmasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use DBService\Service;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\generator\Generator;
use Pendaftaran\V1\Rest\Kunjungan\KunjunganService;

class ReturFarmasiService extends Service
{
	private $kunjungan;
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("retur_farmasi", "layanan"));
		$this->entity = new ReturFarmasiEntity();
    }
        
	public function simpan($data) {
		$data = is_array($data) ? $data : (array) $data;
		$this->entity->exchangeArray($data);
		
		$id = is_numeric($this->entity->get('ID')) ? $this->entity->get('ID') : false;
		if($id) {
			$this->table->update($this->entity->getArrayCopy(), ["ID" => $id]);
		} else {
			$id = Generator::generateIdReturFarmasi();
			$this->entity->set('ID', $id);
			$this->table->insert($this->entity->getArrayCopy());
		}
		
		return [
			'success' => true,
			'data' => $this->load[['ID' => $id]]
		];
	}

	public function getJumlahRetur($nomor) {
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("
				SELECT SUM(JUMLAH) JUMLAH
				FROM layanan.retur_farmasi r
				WHERE ID_FARMASI = '".$nomor."'");
		$queryLmt = $strLmt->execute();
		if(count($queryLmt) > 0) {
			$rowLmt = $queryLmt->current();
			return $rowLmt['JUMLAH'];
		} 
			
		return false;
	}

	public function getKunjungan($nomor) {
		$adapter = $this->table->getAdapter();
		$strLmt = $adapter->query("
							SELECT
							k.NOMOR, k.RUANGAN, k.MASUK, k.KELUAR
							FROM layanan.farmasi f, pendaftaran.kunjungan k
							WHERE k.NOMOR = f.KUNJUNGAN AND f.ID = '".$nomor."'");
		$queryLmt = $strLmt->execute();
		if(count($queryLmt) > 0) {
			$rowLmt = $queryLmt->current();
			return array($rowLmt);
		}
			
		return false;
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

	public function getDataKunjungan() {
		$this->kunjungan = new KunjunganService();
		return $this->kunjungan;
	}
	
}