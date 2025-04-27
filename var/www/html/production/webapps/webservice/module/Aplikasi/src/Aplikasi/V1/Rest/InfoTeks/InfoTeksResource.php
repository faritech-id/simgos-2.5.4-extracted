<?php
namespace Aplikasi\V1\Rest\InfoTeks;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class InfoTeksResource extends Resource
{
    protected $moduleId = "1921";

	public function __construct(){
		parent::__construct();
		$this->service = new InfoTeksService();
    }
    
    protected function onAfterAuthenticated($params = []) {
        $eventName = $params["eventName"];
        if($eventName == "create" || $eventName == "update") {
            if(!isset($this->privilages[$this->moduleId])) return new ApiProblem(405, 'Anda tidak memiliki hak akses');
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
		$result = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal menyimpan Info Teks"
        ];
		
        $result["data"] = null;
        $data->OLEH = $this->user;
		
		$success = $this->service->simpanData($data, true);
		if($success) {
			$result["status"] = 200;
			$result["success"] = true;
			$result["data"] = $success[0];
			$result["detail"] = "Berhasil menyimpan Info Teks";
		}
		
		if(!$result["success"]) return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
		
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
        $params = ["ID" => $id];
        $data = $this->service->load($params);
		
		$result = [
			"status" => count($data) > 0 ? 200 : 404,
			"success" => count($data) > 0 ? true : false,
			"total" => count($data),
			"data" => count($data) ? $data[0] : null,
			"detail" => count($data) > 0 ? "Info Teks ditemukan" : "Info Teks tidak ditemukan"
        ];
		
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
        $order = ["ID"];
		$data = null;
		$params = is_array($params) ? $params : (array) $params;
        
        $total = $this->service->getRowCount($params);
		if($total > 0) $data = $this->service->load($params, ['*'], $order);
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $total > 0 ? "Info Teks ditemukan" : "Info Teks tidak ditemukan"
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
        $result = [
			"status" => 422,
			"success" => false,
			"data" => null,
			"detail" => "Gagal merubah data Info Teks"
        ];
		
		$data->ID = $id;
		$params = ["ID" => $id];
		
		$records = $this->service->load($params);
		$canUpdate = count($records) > 0;
		
		if($canUpdate) {
			$success = $this->service->simpanData($data);
			if($success) {
				$result["status"] = 200;
				$result["success"] = true;
				$result["data"] = $success[0];
				$result["detail"] = "Berhasil merubah data Info Teks";
			}
		}
		
		if(!$result["success"]) return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
		
		return $result;
    }
}
