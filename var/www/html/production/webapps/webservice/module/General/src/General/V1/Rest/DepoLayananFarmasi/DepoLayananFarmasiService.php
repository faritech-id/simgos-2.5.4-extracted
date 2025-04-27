<?php
namespace General\V1\Rest\DepoLayananFarmasi;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use Laminas\Db\Sql\Expression;
use DBService\System;
use DBService\Service;
use General\V1\Rest\Ruangan\RuanganService;
class DepoLayananFarmasiService extends Service
{
	private $ruanganfarmasi;
    private $ruanganlayanan;
	
    public function __construct() {
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("depo_layanan_farmasi", "master"));
		$this->entity = new DepoLayananFarmasiEntity();

		$this->config["entityName"] = "\\General\\V1\\Rest\\DepoLayananFarmasi\\DepoLayananFarmasiEntity";
        $this->config["entityId"] = "ID";
		
		$this->ruangan = new RuanganService();
    }
	
	public function load($params = [], $columns = ['*'], $orders = []) {
		$data = parent::load($params, $columns, $orders);
		foreach($data as &$entity) {
			$ruanganfarmasi = $this->ruangan->load(['ID' => $entity['RUANGAN_FARMASI']]);
			if(count($ruanganfarmasi) > 0) $entity['REFERENSI']['RUANGAN_FARMASI'] = $ruanganfarmasi[0];
            $ruanganlayanan = $this->ruangan->load(['ID' => $entity['RUANGAN_LAYANAN']]);
			if(count($ruanganlayanan) > 0) $entity['REFERENSI']['RUANGAN_LAYANAN'] = $ruanganlayanan[0];
		}
				
		return $data;
	}

	protected function queryCallback(Select &$select, &$params, $columns, $orders) {
		if(!System::isNull($params, 'RUANGAN_FARMASI')) { 
			$select->where(["depo_layanan_farmasi.RUANGAN_FARMASI" => $params['RUANGAN_FARMASI']]);
			unset($params['RUANGAN_FARMASI']);
		}
        if(!System::isNull($params, 'RUANGAN_LAYANAN')) { 
			$select->where(["depo_layanan_farmasi.RUANGAN_LAYANAN" => $params['RUANGAN_LAYANAN']]);
			unset($params['RUANGAN_LAYANAN']);
		}
        if(!System::isNull($params, 'STATUS')) {
			$select->where(["depo_layanan_farmasi.STATUS" => $params['STATUS']]);
			unset($params['STATUS']);
		}
		if(!System::isNull($params, 'SELESAI')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("depo_layanan_farmasi.SELESAI >= ?", [$params["SELESAI"]]);
			unset($params['SELESAI']);
		}
		if(!System::isNull($params, 'JAMORDER')) {
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("depo_layanan_farmasi.MULAI <= ?", [$params["JAMORDER"]]);
			$params[] = new \Laminas\Db\Sql\Predicate\Expression("depo_layanan_farmasi.SELESAI >= ?", [$params["JAMORDER"]]);
			unset($params['JAMORDER']);
		}

		if(!System::isNull($params, 'GET_RUANGAN_DEPO_LYN')) {
			$usr = $this->user;
			$join = "par.RUANGAN = depo_layanan_farmasi.RUANGAN_FARMASI";
			$select->join(["par" => new Expression(
				"(SELECT DISTINCT par.RUANGAN
				FROM aplikasi.pengguna_akses_ruangan par
					 INNER JOIN master.ruangan ru
			   WHERE par.STATUS = 1 
				 AND par.PENGGUNA = $usr
				 AND ru.ID = par.RUANGAN 
				 AND ru.JENIS_KUNJUNGAN = 11
				 AND ru.JENIS = 5)")],
				 $join,
				[]
			);
			unset($params['GET_RUANGAN_DEPO_LYN']);
		}
		if(isset($params['QUERY'])) {
			if(!System::isNull($params, 'QUERY')) {
				$select->join(['c' => new TableIdentifier("ruangan", "master")], "depo_layanan_farmasi.RUANGAN_LAYANAN = c.ID", ['DESKRIPSI']);
				$select->where->like("c.DESKRIPSI", "%".$params['QUERY']."%");
				
				unset($params['QUERY']);
			}
		}
	}

	public function getRuanganDepoLyn() {
		$usr = $this->user;
        $adapter = $this->table->getAdapter();
        $stmt = $adapter->query("
			SELECT ru.ID, ru.JENIS, ru.JENIS_KUNJUNGAN, ru.REF_ID, ru.DESKRIPSI, ru.`STATUS`, ru.AKSES_PERMINTAAN
		      FROM aplikasi.pengguna_akses_ruangan p
				   , master.ruangan r, master.depo_layanan_farmasi dl
				   LEFT JOIN master.ruangan ru ON ru.ID = dl.RUANGAN_LAYANAN
		     WHERE dl.RUANGAN_FARMASI = r.ID 
			   AND r.ID = p.RUANGAN 
			   AND r.JENIS_KUNJUNGAN = ?
			   AND p.PENGGUNA = 1 
			   AND p.`STATUS` = 1");
		$stmt->execute([$usr]);
        
        return [
			'success' => true
		];
    }
}
