<?php
namespace Pendaftaran\V1\Rest\Kunjungan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Layanan\V1\Rest\TindakanMedis\TindakanMedisService;
use Layanan\V1\Rest\Farmasi\FarmasiService;
use Layanan\V1\Rest\OrderResep\OrderResepService;
use Pendaftaran\V1\Rest\TujuanPasien\TujuanPasienService;
use Pendaftaran\V1\Rest\Reservasi\ReservasiService;
use Pembayaran\V1\Rest\GabungTagihan\GabungTagihanService;

class KunjunganResource extends Resource
{	
	private $ruangan;
	protected $title = "Kunjungan";
	
	public function __construct() {
		parent::__construct();
		$this->service = new KunjunganService();
		$this->service->setPrivilage(true);
		$this->tindakanMedis = new TindakanMedisService();
		$this->farmasi = new FarmasiService();
		$this->orderfarmasi = new OrderResepService(true, [
		    'Ruangan' => false,
		    'Referensi' => false,
		    'Dokter' => false,
		    'OrderDetil' => false,
		    'Kunjungan' => true
		]);
		$this->tujuan = new TujuanPasienService(false);
		$this->reservasi = new ReservasiService(false);
		$this->gabungtagihan = new GabungTagihanService();
	}
	
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		$data->DITERIMA_OLEH = $this->user;
		$ref = isset($data->REF) ? "= '".$data->REF."'" : "IS NULL";
		
		if(isset($data->REF)){
			if(substr($data->REF, 0, 2) == 10){
				if(!$this->isAllowPrivilage('110102')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan konsul');	
				
			} else if(substr($data->REF, 0, 2) == 11){
				if(!$this->isAllowPrivilage('110103')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan mutasi');	

			} else if(substr($data->REF, 0, 2) == 12){
				if(!$this->isAllowPrivilage('110104')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan order laboratorium');	

			} else if(substr($data->REF, 0, 2) == 13){
				if(!$this->isAllowPrivilage('110105')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan order radiologi');	

			} else if(substr($data->REF, 0, 2) == 14){
				if(!$this->isAllowPrivilage('110106')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan order resep');	
			}
		} else {
			if(!$this->isAllowPrivilage('110101')) return new ApiProblem(405, 'Anda tidak memiliki akses penerimaan pendaftaran kunjungan');				
		}

		if(isset($data->NOPEN)) {
			if($this->getPropertyConfig(69) == 'TRUE') {
				if($this->service->getTagihan()->isTagihanTerkunci($data->NOPEN))
					return new ApiProblem(405, "Anda tidak dapat melakukan transaksi ini,<br>karena telah dilakukan penguncian transaksi tagihan oleh kasir");
			}
		}
		
		$find = $this->service->load(['NOPEN' => $data->NOPEN, 'RUANGAN' => $data->RUANGAN, new \Laminas\Db\Sql\Predicate\Expression("REF ".$ref)]);
		if(count($find) > 0) {
			$tujuans = $this->tujuan->load([
				"NOPEN" => $data->NOPEN
			]);
			if(count($tujuans) == 1) {
				if($tujuans[0]["STATUS"] == 1) {
					$this->tujuan->simpan([
						"NOPEN" => $data->NOPEN,
						"STATUS" => 2
					]);
					if($find[0]["STATUS"] == 0) {
						$data = $find[0];
						$data["RUANGAN"] = $tujuans[0]["RUANGAN"];
						$data["DPJP"] = $tujuans[0]["DOKTER"];
						$data["STATUS"] = 1;
						$reservasi = $this->reservasi->load(["NOMOR" => $tujuans[0]["RESERVASI"]]);
						if(count($reservasi) > 0) $data["RUANG_KAMAR_TIDUR"] = $reservasi[0]["RUANG_KAMAR_TIDUR"];
						return $this->update($data["NOMOR"], $data);
					}
				}
			}
			return new ApiProblem(405, 'penerimaan pendaftaran kunjungan ini sudah diterima');	
		}
		
        $result = parent::create($data);
		return $result;
    }

    /**
     * Delete a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function delete($id)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for individual resources');
    }

    /**
     * Delete a collection, or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function deleteList($data)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for collections');
    }

    /**
     * Fetch a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function fetch($id)
    {
		$result = parent::fetch($id);
		return $result;
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
		parent::fetchAll($params);
		$data = [];
		$this->service->setUser($this->user);
		$this->service->setUserAkses($this->dataAkses);		
		
		if(isset($params->BERKAS_KLAIM_OBAT_FARMASI)){
			$data = $this->service->getDataBerkasKlaimObatFarmasi($params);
			return array(
				"success" => count($data) > 0 ? true : false,
				"total" => count($data),
				"data" => $data
			);
		}
		else {
			$total = $this->service->getRowCount($params);
		
			if($total > 0) {
				$data = $this->service->load($params, ['*'], ['MASUK DESC']);
				
				foreach($data as &$entity) {
					if(isset($params['JENIS_KUNJUNGAN'])) {
						if($params['JENIS_KUNJUNGAN'] == 11) {
							$orderfarmasi = $this->orderfarmasi->load(['NOMOR' => $entity['REF']]);
							if(count($orderfarmasi) > 0) $entity['REFERENSI']['ASAL'] = $orderfarmasi[0];
						}
					}
				}
			}
		}
		
		return [
			/*"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,*/
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $this->title.($total > 0 ? " ditemukan" : " tidak ditemukan")
		];
    }

    /**
     * Patch (partial in-place update) a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patch($id, $data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for individual resources');
    }

    /**
     * Replace a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function replaceList($data)
    {
        return new ApiProblem(405, 'The PUT method has not been defined for collections');
    }

    /**
     * Update a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function update($id, $data)
    {		
		$kjgn = $this->service->load(["NOMOR" => $id]);

		if(count($kjgn) > 0 && !isset($data->FINAL_HASIL)) {
			if($this->getPropertyConfig(69) == 'TRUE') {
				if($this->service->getTagihan()->isTagihanTerkunci($kjgn[0]["NOPEN"]))
					return new ApiProblem(405, "Anda tidak dapat melakukan transaksi ini,<br>karena telah dilakukan penguncian transaksi tagihan oleh kasir");
			}
		}

		if(isset($data->STATUS)) {
			$notify = false;
            $notifyMsg = "";
			if($data->STATUS == 0) {				
				if(!$this->isAllowPrivilage('110802')) {
                    $notify = true;
                    $notifyMsg = 'Anda tidak memiliki akses untuk melakukan pembatalan';
                } 
                
    			if(!$notify) {
    			    $rows = $this->tindakanMedis->load(['KUNJUNGAN' => $id, 'STATUS' => 1]);
    			    if(count($rows) > 0) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan tindakan';
    			    }
    			}
    				
    			if(!$notify) {				
    			    $rows = $this->farmasi->load(['KUNJUNGAN' => $id, 'STATUS' => 2]);
    				if(count($rows) > 0) {
    				    $notify = true;
    				    $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan farmasi';
    				}
    			}
    				
    			if(!$notify) {
    			    if($this->service->getMutasi()->kunjunganSudahDimutasikan($id)) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan mutasi';
    			    }
    			}
    				
    			if(!$notify) {
    			    if($this->service->getKonsul()->kunjunganSudahDikonsulkan($id)) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan konsul';
    			    }
    			}
    				
    			if(!$notify) {
    			    if($this->service->getOrderLab()->kunjunganSudahDiOrderLabkan($id)) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan order laboratorium';
    			    }
    			}
    				
    			if(!$notify) {
    			    if($this->service->getOrderRad()->kunjunganSudahDiOrderRadkan($id)) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan order radiologi';
    			    }
    			}
    			
    			if(!$notify) {
    			    if($this->service->getEResep()->kunjunganSudahDiOrderResepkan($id)) {
    			        $notify = true;
    			        $notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini sudah memiliki layanan resep';
    			    }
    			}

				/** 
				 * cek jika memiliki gabung tagihan maka tidak dapat di lakukan pembatalan kunjungan
				 * harus di lakukan pembatalan gabung tagihan terlebih dahulu
				*/

				$properticonf = $this->getPropertyConfig(93);
				if($properticonf){
					if($properticonf == "TRUE"){
						if(count($kjgn) > 0) {
							$nopen = $kjgn[0]["NOPEN"];
							$hasilcek = $this->gabungtagihan->cekGabungTagihanBerdasakanNopen($nopen);
							if($hasilcek){
								$notify = true;
								$notifyMsg = 'Anda tidak dapat melakukan pembatalan kunjungan ini karena kunjungan ini telah dilakukan pengabungan tagihan. 
									silahkan batalkan gabung tagihan terlebih dahulu jika tetap ingin membatalkan kunjungan ini.';
							}					
						}
					}
				}
			} else if($data->STATUS == 1) {
                if(!$notify) {
                    if(count($kjgn) > 0) {
						if($kjgn[0]["STATUS"] == 0){
							$rows = $this->service->getPendaftaran()->load(['NOMOR' => $kjgn[0]["NOPEN"], 'STATUS' => 0]);
							if(count($rows) > 0) {
								$notify = true;
								$notifyMsg = 'Anda tidak dapat mengaktifkan kunjungan ini karena pendaftarannya tidak aktif';
							}
						}
                    }
                }
            } else if($data->STATUS == 2) {
                if(!$notify) {
                    $result = $this->service->adaPetugasMedisYgTidakTerisi($id);                    
                    if($result) {
						$notify = true;
						$notifyMsg = 'Anda tidak dapat memfinalkan kunjungan ini, karena masih ada petugas medis yang belum terisi.';					
                    }
					if(count($kjgn) > 0) {
						$refs = $kjgn[0]['REFERENSI'];
						$jenisRuanganKunjungan = isset($refs['RUANGAN']) ? $refs['RUANGAN'] : null;
						if($jenisRuanganKunjungan['JENIS_KUNJUNGAN'] == 11){
							$result = $this->service->adaItemObatYangTervalidasiStok($id);
							if($result) {
								$notify = true;
								$notifyMsg = 'Kunjungan tidak dapat difinalkan, karena ada item obat yang melebihi qty stok';
							}
							$resultf = $this->service->isValidasiRetriksiHari($id);
							if($resultf) {
								$notify = true;
								$notifyMsg = 'Kunjungan tidak dapat difinalkan, karena ada item obat yang retriksi hari pelayanan, silahkan cek riwayat pelayanan';
							}
						}
					}
                }                
            }

			if($notify) {
    		    return new ApiProblem(405, $notifyMsg);
    		}
		}

		if(isset($data->FINAL_HASIL)) {
			if($data->FINAL_HASIL == 0) {
				if(!$this->isAllowPrivilage('110902')) {
					return new ApiProblem(405, 'Anda tidak memiliki akses untuk melakukan pembatalan final hasil');
				}
			} else {
				if(!$this->isAllowPrivilage('110901')) {
					return new ApiProblem(405, 'Anda tidak memiliki akses untuk melakukan final hasil');
				}
			}
			
			$data->FINAL_HASIL_OLEH = $this->user;
			$data->FINAL_HASIL_TANGGAL = new \Laminas\Db\Sql\Expression('NOW()');
		}

		$result = parent::update($id, $data);
		return $result;
    }
}
