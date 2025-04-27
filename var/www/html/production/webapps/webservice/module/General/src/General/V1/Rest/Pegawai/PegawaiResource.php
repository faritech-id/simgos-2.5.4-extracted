<?php
namespace General\V1\Rest\Pegawai;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use Pegawai\V1\Rest\KartuIdentitas\Service as KipService;
use DBService\Resource;

class PegawaiResource extends Resource
{
    protected $title = "Pegawai";

	public function __construct(){
		parent::__construct();
        $this->allowIfLocking = true;
		$this->service = new PegawaiService();
        $this->kipservice = new KipService();
	}

    protected function onAfterAuthenticated($params = []) {
        $event = $params["event"];
        if($this->authTypeAccess == self::AUTH_TYPE_LOGIN) {
            if($event->getName() == "create" || $event->getName() == "update") {
                if(!$this->isAllowPrivilage('1902')) return new ApiProblem(405, 'Anda tidak memiliki hak akses');
            }
            if($event->getName() == "fetchAll" || $event->getName() == "fetch") {
                $allow = $this->isAllowPrivilage('24010102') || $this->isAllowPrivilage('1902') || $this->isAllowPrivilage('2701');
                if(!$allow) {
                    $nip = "";
                    $prms = (array) $event->getQueryParams();
                    if(count($prms) > 0) {
                        if(!empty($prms["NIP"])) $nip = $prms["NIP"];
                        if($this->dataAkses->NIP != $nip) return new ApiProblem(405, 'Anda tidak memiliki hak akses');
                    }
                }
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
        $data->NIP = isset($data->NIP_BARU) ? $data->NIP_BARU : $data->NIP;
        
        if(isset($data->KARTU_IDENTITAS)){
            $kip = $data->KARTU_IDENTITAS;
            $notValidEntity = $this->kipservice->getEntity()->getNotValidEntity($kip[0], false);
            if(count($notValidEntity) > 0) {
                $result["status"] = 412;
                $result["detail"] = $notValidEntity["messages"];
                return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
            }
        }

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
        if(!$result["success"]) {
            $data = $this->service->load(["NIP" => $id]);
		
            $result = [
                "status" => count($data) > 0 ? 200 : 404,
                "success" => count($data) > 0 ? true : false,
                "total" => count($data),
                "data" => count($data) ? $data[0] : null,
                "detail" => $this->title.(count($data) > 0 ? " ditemukan" : " tidak ditemukan")
            ];
        }
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
        $order = ["ID ASC"];
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
    public function update($id, $data)
    {
        if(isset($data->KARTU_IDENTITAS)){
            $kip = $data->KARTU_IDENTITAS;
            $notValidEntity = $this->kipservice->getEntity()->getNotValidEntity($kip[0], false, "PUT");
            if(count($notValidEntity) > 0) {
                $result["status"] = 412;
                $result["detail"] = $notValidEntity["messages"];
                return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
            }
        }
        
        if(!isset($data->NIP)) {
            if(isset($data->NIP_BARU)) $data->NIP = $data->NIP_BARU;
        }
        $result = parent::update($id, $data);
		return $result;
    }
}
