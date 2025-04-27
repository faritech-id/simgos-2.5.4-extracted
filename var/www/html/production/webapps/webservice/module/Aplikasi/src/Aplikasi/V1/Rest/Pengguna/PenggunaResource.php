<?php
namespace Aplikasi\V1\Rest\Pengguna;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Aplikasi\Password;
use Laminas\Authentication\Storage\Session as StorageSession;

class PenggunaResource extends Resource
{
    protected $title = "Pengguna";

	public function __construct() {
		parent::__construct();
        $this->allowIfLocking = true;
		$this->service = new PenggunaService();
	}

    protected function onAfterAuthenticated($params = []) {
        $event = $params["event"];
        $id = $event->getParam('id', null);
        $data = (array) $event->getParam('data', []);
        $prms = (array) $event->getQueryParams();
        if(count($data) > 0) {
            if(!empty($data["ID"])) $id = $data["ID"];
        } else {
            if(count($prms) > 0) {
                if(!empty($prms["ID"])) $id = $prms["ID"];
            }
        }
        $allow = $this->isAllowPrivilage('1903');
        if (!$allow) {        
            if($event->getName() == "create") return new ApiProblem(405, 'Anda tidak memiliki hak akses webservice pengguna');
            if(!empty($id)) $allow = ($id == $this->user);
            if(!$allow) $allow = $this->isAllowPrivilage('2702');
            if(!$allow) return new ApiProblem(405, 'Anda tidak memiliki hak akses webservice pengguna');
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
        if($result["success"]) unset($result["data"]["PASSWORD"]);
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
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        parent::fetchAll($params);
        $columns = ['ID', 'LOGIN', 'NAMA', 'NIP', 'NIK', 'JENIS', 'STATUS', 'MASA_AKTIF', 'LOCK_APP', 'TERAKHIR_UBAH_PASSWOD'];
		$pwd = null;
		if(isset($params['PASSWORD'])) {
			$columns[] = 'PASSWORD';
			$pwd = $params['PASSWORD'];
            if(empty($params['PASSWORD'])) {
                return [
                    "status" => 404,
                    "success" => false,
                    "total" => 0,
                    "data" => null,
                    "detail" => $this->title." tidak ditemukan"
                ];
            }
			unset($params['PASSWORD']);
		}
        $order = ["NAMA ASC"];
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
        if (isset($params["NOT"])) {
			$nots = (array) json_decode($params["NOT"]);
			foreach($nots as $key => $val) {        
                $params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOT pengguna.".$key." = ".$val.")");                
			}
			unset($params["NOT"]);
		}
        
        $total = $this->service->getRowCount($params);
		if($total > 0) {
            $data = $this->service->load($params, $columns, $order);
            if($pwd) {
                $results = [];
                foreach($data as $row) {
                    if(Password::verify($row["PASSWORD"], $pwd)) {
                        unset($row["PASSWORD"]);
                        $results[] = $row;
                        break;
                    }
                }
                $total = count($results);
                $data = $results;
            }
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
        if($result["success"]) unset($result["data"]["PASSWORD"]);
		return $result;
    }
}
