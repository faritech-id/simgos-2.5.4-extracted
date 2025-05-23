<?php
namespace General\V1\Rest\RuangKamarTidur;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class RuangKamarTidurResource extends Resource
{
	public function __construct() {
		parent::__construct();
		$this->service = new RuangKamarTidurService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		return $this->service->simpan($data);
        //return new ApiProblem(405, 'The POST method has not been defined');
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
		if(isset($params['INFO_RUANG_KAMAR'])){
			$data =  $this->service->execute("CALL informasi.InfoRuangKamarTidurDetil(?)", [$params['INFO_RUANG_KAMAR']]);
            if(count($data) > 0){
                return [
                    "status" => 200,
                    "success" => true,
                    "total" => 1,
                    "data" => $data,
                    "detail" => "Info Tempat Tidur ditemukan"
                ];
            } else {
                return [
                    "status" => 404,
                    "success" => false,
                    "total" => 0,
                    "data" => "",
                    "detail" => "Info Tempat Tidur tidak ditemukan"
                ];
            }
        } else {
			$total = $this->service->getRowCount($params);
			$data = $this->service->load($params);	
			
			return [
				"success" => $total > 0 ? true : false,
				"total" => $total,
				"data" => $data
			];
		}
        //return new ApiProblem(405, 'The GET method has not been defined for collections');
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
        return $this->service->simpan($data);
    }
}
