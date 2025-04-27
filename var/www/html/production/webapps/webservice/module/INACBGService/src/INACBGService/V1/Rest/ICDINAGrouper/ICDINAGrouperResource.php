<?php
namespace INACBGService\V1\Rest\ICDINAGrouper;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class ICDINAGrouperResource extends Resource
{
    private $serviceInacbg;

    public function __construct() {
        parent::__construct();
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        $this->service = new Service();
    }
    
    public function setServiceManager($serviceManager) {
        parent::setServiceManager($serviceManager);        
        $this->serviceInacbg = $serviceManager->get('INACBGService\Service');
	}

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        return new ApiProblem(405, 'The POST method has not been defined');
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
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        parent::fetchAll($params);		
        $data = null;        

        $params = is_array($params) ? $params : (array) $params;

        if(!isset($params["icd_type"])) {
            return new ApiProblem(412, 'Parameter icd_type harus di masukkan');
        }

        if($params["icd_type"] > 2) {
            return new ApiProblem(412, 'Nilai parameter icd_type tidak valid');
        }

        if(!isset($params["tipe"])) {
            return new ApiProblem(412, 'Parameter type (tipe inacbg) harus di masukkan');
        }

        if(!isset($params["query"])) {
            return new ApiProblem(412, 'Parameter query (pencarian kode / deskripsi) harus di masukkan');
        }
        
        if(isset($params["load_from_inacbg"])) {
            unset($params["load_from_inacbg"]);
            $result = null;                        
            if($params["icd_type"] == 1) $result = $this->serviceInacbg->diagnosaInaGrouper($params);
            if($params["icd_type"] == 2) $result = $this->serviceInacbg->prosedurInaGrouper($params);
            
            if($result) {
                if($result->metadata->code == 200) {
                    if($result->response->count > 0) {
                        foreach($result->response->data as $dt) {
                            $dt = (array) $dt;
                            $dt["icd_type"] = $params["icd_type"];
                            $founds = $this->service->load([
                                "code" => $dt["code"]
                            ]);
                            $this->service->simpanData($dt, count($founds) == 0, false);
                        }
                    }
                }
            }
        }

        unset($params["tipe"]);

        $total = $this->service->getRowCount($params);
		if($total > 0) $data = $this->service->load($params, ['*']);
		
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
