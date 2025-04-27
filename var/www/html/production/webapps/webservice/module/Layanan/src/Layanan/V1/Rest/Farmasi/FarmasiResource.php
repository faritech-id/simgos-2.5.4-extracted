<?php
namespace Layanan\V1\Rest\Farmasi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class FarmasiResource extends Resource
{
    protected $title = "Farmasi";

	public function __construct() {
		parent::__construct();
		$this->service = new FarmasiService();
        $this->service->setResource($this);
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
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
        return new ApiProblem(405, 'The DELETE method has not been defined for individual resources farmasi');
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
        return new ApiProblem(405, 'The GET method has not been defined for individual resources');
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        if(isset($params['ALL'])){
            unset($params['ALL']);
            if(isset($params['start'])) unset($params['start']);
            if(isset($params['limit'])) unset($params['limit']);
        }
        parent::fetchAll($params);		
        $order = ["TANGGAL DESC", "GROUP_RACIKAN"];
		$data = null;
		
		if(isset($params->NORM_REKONSILIASI_ADMISI)){
			$data = $this->service->getDataLayananRJSatuBulanTerakhir($params);
			return array(
				"success" => count($data) > 0 ? true : false,
				"total" => count($data),
				"data" => $data
			);
		}
		else if(isset($params->REKONSILIASI)){
			$data = $this->service->getDataLayananDepoSebelumnya($params);
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
		$result = parent::update($id, $data);
        $params['ID'] = $data->ID;
        $params['GET_BATAS_LYN'] = $data->ID;
        $params['GET_STOK_RUANGAN'] = $data->ID;
        $data = $this->service->load($params, ['*']);
		return $data;
    }
}
