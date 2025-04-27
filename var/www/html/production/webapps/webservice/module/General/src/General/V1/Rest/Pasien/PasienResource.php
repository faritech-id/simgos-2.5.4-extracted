<?php
namespace General\V1\Rest\Pasien;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class PasienResource extends Resource
{
    protected $title = "Pasien";

	public function __construct() {
        parent::__construct();
        $this->authType = self::AUTH_TYPE_SIGNATURE_OR_LOGIN;
        $this->service = new PasienService();
	}

    protected function onAfterAuthenticated($params = []) {
        $event = $params["event"];
        if($this->authTypeAccess == self::AUTH_TYPE_LOGIN) {
            if($event->getName() == "create") {
                if(!$this->isAllowPrivilage('1001')) return new ApiProblem(405, 'Anda tidak memiliki hak akses'); 
            }
            if($event->getName() == "update") {
                if(!$this->isAllowPrivilage('100701')) return new ApiProblem(405, 'Anda tidak memiliki hak akses'); 
            }
            if($event->getName() == "fetchAll" || $event->getName() == "fetch") {
                if(!$this->isAllowPrivilage('24010101')) return new ApiProblem(405, 'Anda tidak memiliki hak akses'); 
            }
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
        $data = is_array($data) ? $data : (array) $data;

        $valid = $this->service->isValidCustomValidationEntity($data);
        if($valid instanceof ApiProblem) return $valid;

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
		parent::fetchAll($params);		
        $order = ["TANGGAL DESC"];
		$data = null;
		if (isset($params->sort)) {
			$orders = json_decode($params->sort);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$order = array($orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : ""));
			}
			unset($params->sort);
		}
		
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
    public function update($id, $data){
		$result = parent::update($id, $data);
		return $result;
    }
}