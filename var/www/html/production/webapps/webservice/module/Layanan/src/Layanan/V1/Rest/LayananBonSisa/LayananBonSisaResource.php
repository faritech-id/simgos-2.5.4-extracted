<?php
namespace Layanan\V1\Rest\LayananBonSisa;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class LayananBonSisaResource extends Resource
{
    protected $title = "Layanan Bon Sisa Farmasi";

    public function __construct() {
		parent::__construct();
		$this->service = new LayananBonSisaService();
        $this->service->setPrivilage(true);
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
        $tgl = $data->TANGGAL;
        if(isset($data->BON_DETIL)) {
            $cekSo = $this->service->getValidasiStokOpname($data->BON_DETIL[0]['REF'], $data->TANGGAL);
            if(!$cekSo['success']) return new ApiProblem(405, $cekSo['message']);
            $isNotValidateQty = $this->service->isNotValidateQty($data);
            if(!$isNotValidateQty['success']) return new ApiProblem(405, $isNotValidateQty['message']);
            $isNotValidateStok = $this->service->isNotValidateStok($data);
            if(!$isNotValidateStok['success']) return new ApiProblem(405, $isNotValidateStok['message']);

			foreach($data->BON_DETIL as $tgs) {
				$tgs['TANGGAL'] = $tgl;
				$return = parent::create($tgs);
			}
		}
        return $return;
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
        return new ApiProblem(405, 'The GET method has not been defined for individual resources');
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array|Parameters $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        parent::fetchAll($params);
        $data = null;
        $order = ["ID ASC"];
        $total = $this->service->getRowCount($params);
		if($total > 0) $data = $this->service->load($params, ['*'], $order);
		
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
     * Patch (partial in-place update) a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patchList($data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for collections');
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
        return new ApiProblem(405, 'The PUT method has not been defined for individual resources');
    }
}
