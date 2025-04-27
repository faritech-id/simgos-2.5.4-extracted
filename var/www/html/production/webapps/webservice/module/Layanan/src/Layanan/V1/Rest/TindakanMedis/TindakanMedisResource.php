<?php
namespace Layanan\V1\Rest\TindakanMedis;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class TindakanMedisResource extends Resource
{
    protected $title = "Tindakan Medis";

    public function __construct() {
        parent::__construct();
        $this->service = new TindakanMedisService();
    }
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        if(!$this->isAllowPrivilage('1102')) return new ApiProblem(405, 'Anda tidak memiliki akses Penginputan Tindakan');	
        if(isset($data->KUNJUNGAN)) {
            if($this->getPropertyConfig(69) == 'TRUE') {
                $kjgn = $this->service->getKunjungan()->load(["NOMOR" => $data->KUNJUNGAN]);

                if(count($kjgn) > 0) {
                    if($this->service->getTagihan()->isTagihanTerkunci($kjgn[0]["NOPEN"]))
                        return new ApiProblem(405, "Anda tidak dapat melakukan transaksi ini,<br>karena telah dilakukan penguncian transaksi tagihan oleh kasir");
                }
            }
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
        $this->service->setUser($this->user);	
        $order = ["tindakan_medis.TANGGAL DESC"];
        $data = null;        
		
		if(isset($params->BERKAS_KLAIM_OBAT_LAB_KLINIK)){
			$data = $this->service->getDataBerkasKlaimObatLabKlinik($params);
			return array(
				"success" => count($data) > 0 ? true : false,
				"total" => count($data),
				"data" => $data
			);
		}
		else {
			if (isset($params->sort)) {
				$orders = json_decode($params->sort);
				if(is_array($orders)) {
				} else {
					$orders->direction = strtoupper($orders->direction);
					$order = [$orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : "")];
				}
				unset($params->sort);
			}
			$params = is_array($params) ? $params : (array) $params;
			if (isset($params["NOT"])) {
				$nots = (array) json_decode($params["NOT"]);
				foreach($nots as $key => $val) {                
					$params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOT tindakan_medis.".$key." = ?)",  [$val]);                
				}
				unset($params["NOT"]);
			}
			$total = $this->service->getRowCount($params);
			if($total > 0) $data = $this->service->load($params, ['*'], $order);
		}
		
		return [
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
        $status = isset($data->STATUS) ? $data->STATUS : 1;
        if($status = 0) {
            if(!$this->isAllowPrivilage('110803')) {
                return new ApiProblem(405, 'Anda tidak memiliki akses Pembatalan Tindakan');
            }			
        }

        if($this->getPropertyConfig(69) == 'TRUE') {
            $founds = $this->service->load(["ID" => $id]);
            if(count($founds) > 0) {
                $kjgn = $founds[0]["REFERENSI"]["KUNJUNGAN"];
                if($this->service->getTagihan()->isTagihanTerkunci($kjgn["NOPEN"]))
                    return new ApiProblem(405, "Anda tidak dapat melakukan transaksi ini,<br>karena telah dilakukan penguncian transaksi tagihan oleh kasir");
            }
        }

        $result = parent::update($id, $data);
		return $result;
    }
}
