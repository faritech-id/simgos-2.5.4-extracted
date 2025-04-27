<?php
namespace Layanan\V1\Rest\HasilPa;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class HasilPaResource extends Resource
{
    protected $title = "Hasil Laboratorium Patologi Anatomi";

	public function __construct() {
		parent::__construct();
		$this->service = new HasilPaService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
       //if($this->isAllowPrivilage('110403')) {
        $data = is_object($data) ? (array) $data : $data;
        $notValidEntity = $this->service->getEntity()->getNotValidEntity($data, false);
        if(count($notValidEntity) > 0) return new ApiProblem(412, "Parameter ".$notValidEntity["messages"], null, null, ["success" => false]);
        if($this->service->findByKunjunganDanJenisPemeriksaan($data["KUNJUNGAN"], $data["JENIS_PEMERIKSAAN"])) new ApiProblem(422, "Hasil pemeriksaan ini telah terdaftar", null, null, ["success" => false]);
		$result = parent::create($data);
		return $result;
		//} else return new ApiProblem(405, 'Anda tidak memiliki hak untuk menginput hasil radiologi');
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
		//if($this->isAllowPrivilage('110503')) {
        parent::fetchAll($params);
        $order = [];
        $data = null;        
		if(isset($params->BERKAS_KLAIM_OBAT_PA)){
			$data = $this->service->getDataBerkasKlaimObatPa($params);
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
					$params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOT hasil_pa.".$key." = ".$val.")");                
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
		//} else return new ApiProblem(405, 'Anda tidak memiliki hak untuk melihat hasil radiologi');
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
		$result = parent::update($id, $data);
		return $result;
    }
}
