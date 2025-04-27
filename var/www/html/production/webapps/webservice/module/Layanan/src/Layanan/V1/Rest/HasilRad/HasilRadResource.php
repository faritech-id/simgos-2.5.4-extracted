<?php
namespace Layanan\V1\Rest\HasilRad;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class HasilRadResource extends Resource
{
    protected $title = "Hasil Radiologi";

	public function __construct() {
		parent::__construct();
		$this->service = new HasilRadService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		if(!$this->isAllowPrivilage('110403')) return new ApiProblem(405, 'Anda tidak memiliki hak untuk menginput hasil radiologi');
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
		if(!$this->isAllowPrivilage('110503')) return new ApiProblem(405, 'Anda tidak memiliki hak untuk melihat hasil radiologi');
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
		if(!$this->isAllowPrivilage('110503')) return new ApiProblem(405, 'Anda tidak memiliki hak untuk melihat hasil radiologi');
        parent::fetchAll($params);		
        $order = ["TANGGAL DESC"];
        $data = null;        
		
		if(isset($params->BERKAS_KLAIM_OBAT_RADIOLOGI)){
			$data = $this->service->getDataBerkasKlaimObatRadiologi($params);
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

    protected function isValidateBeforeUpdate($id, $data, $record) {
        if(is_array($records)) {
            if(count($records) > 0) {
                if($records[0]["STATUS"] == 2) {
                    if(empty($data["STATUS"])) return new ApiProblem(405, 'Hasil radiologi sudah difinalkan, silahkan lakukan pembatalan terlebih dahulu');
                    else {
                        if($data["STATUS"] == 1) {
                            if($this->isAllowPrivilage('110902')) return new ApiProblem(405, 'Anda tidak memiliki hak untuk membatalkan final hasil radiologi');
                        }
                    }
                }
            }
        }
		return true;
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
        //if($this->isAllowPrivilage('110403')) return new ApiProblem(405, 'Anda tidak memiliki hak untuk merubah hasil radiologi');
        $result = parent::update($id, $data);
        return $result;
    }
}
