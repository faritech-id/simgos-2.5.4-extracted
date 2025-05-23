<?php
namespace General\V1\Rest\Instansi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
//use Laminas\ApiTools\Rest\AbstractResourceListener;
use DBService\Resource;

class InstansiResource extends Resource
{
	public function __construct() {
        parent::__construct();
        $this->authType = self::AUTH_TYPE_NOT_SECURE;
        $this->allowIfLocking = true;
		$this->service = new InstansiService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        //return $this->service->simpan($data);
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
    public function fetchAll($params = array())
    {
        $data = $this->service->load($params);	
        $total = isset($param["page"]) || (isset($param["start"]) && isset($param["limit"])) ? $this->service->getRowCount($params) : count($data);
		
		return array(
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
            "from" => $_SERVER['SERVER_NAME']
		);
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
        //return $this->service->simpan($data);
        return new ApiProblem(405, 'The PUT method has not been defined for individual resources');
    }
}
