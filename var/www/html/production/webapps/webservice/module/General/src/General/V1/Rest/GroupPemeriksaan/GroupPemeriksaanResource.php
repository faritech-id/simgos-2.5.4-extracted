<?php
namespace General\V1\Rest\GroupPemeriksaan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class GroupPemeriksaanResource extends Resource
{
    protected $title = "Group Pemeriksaan";

	public function __construct() {
		parent::__construct();
		$this->service = new GroupPemeriksaanService();
	}

    protected function onAfterAuthenticated($params = []) {
        $allow = $this->isAllowPrivilage('1911');
        if (!$allow) {
            $allow = $this->isAllowPrivilage('2602') || $this->isAllowPrivilage('2603');
            $event = $params["event"];
            if($event->getName() == "create" || $event->getName() == "update") {
                $allow = false;
            }
            if (!$allow) return new ApiProblem(405, 'Anda tidak memiliki hak akses webservice Mapping Group Pemeriksaan');
        }
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
		if(isset($params["TREE"])) {
            unset($params["TREE"]);
			$collection = $this->service->loadTree($params);		
			return [
				"children" => $collection['data']
            ];
		} else {	
			parent::fetchAll($params);		
            $order = ["ID DESC"];
            $data = null;   
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
            
            return [
                "status" => $total > 0 ? 200 : 404,
                "success" => $total > 0 ? true : false,
                "total" => $total,
                "data" => $data,
                "detail" => $this->title.($total > 0 ? " ditemukan" : " tidak ditemukan")
            ];
		}
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
        $result = parent::update($id, $data);
		return $result;
    }
}
