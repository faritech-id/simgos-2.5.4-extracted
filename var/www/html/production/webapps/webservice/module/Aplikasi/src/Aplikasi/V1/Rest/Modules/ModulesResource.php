<?php
namespace Aplikasi\V1\Rest\Modules;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class ModulesResource extends Resource
{
	public function __construct() {
		parent::__construct();
		$this->service = new ModulesService();
		$this->service->setPrivilage(true);
	}

    protected function onAfterAuthenticated($params = []) {
        $allow = $this->isAllowPrivilage('1903');
        if (!$allow) return new ApiProblem(405, 'Anda tidak memiliki hak akses webservice pengguna');
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
		if(count($params) == 0 || (isset($params['TREE']) && !empty($params['TREE']))) {
			if(isset($params['TREE'])) unset($params['TREE']);
			$columns = ['*'];
			if(isset($params['TIPE'])) {
				if($params['TIPE'] == 1) {		
					if(isset($params['GROUP_PENGGUNA'])) {
						$columns = ['*', 'checked' => new \Laminas\Db\Sql\Expression("aplikasi.isSelectedGroupPenggunaAksesModule(?, modules.ID)", [$params['GROUP_PENGGUNA']])];						
						unset($params['GROUP_PENGGUNA']);
					}
				} else {					
					if(isset($params['GROUP_PENGGUNA']) && isset($params['PENGGUNA'])) {
						$columns = ['*', 'checked' => new \Laminas\Db\Sql\Expression("aplikasi.isSelectedPenggunaAkses(?, modules.ID, ?)", [$params['PENGGUNA'], $params['GROUP_PENGGUNA']])];						
						unset($params['PENGGUNA']);
					}
				}
								
				unset($params['TIPE']);
			}
			
			$collection = $this->service->loadTree($params, $columns);
			return [
				"children" => $collection['data']
            ];
		} else {
			if(isset($params['TREE'])) unset($params['TREE']);
			if(isset($params['TIPE'])) unset($params['TIPE']);
			//if(isset($params['GROUP_PENGGUNA'])) unset($params['GROUP_PENGGUNA']);
			$total = $this->service->getRowCount($params);
			$data = $this->service->load($params);	
			
			return [
				"success" => $total > 0 ? true : false,
				"total" => $total,
				"data" => $data
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
