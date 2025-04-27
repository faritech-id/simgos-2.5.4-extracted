<?php
namespace General\V1\Rest\Referensi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class ReferensiResource extends Resource
{
    protected $title = "Referensi";

	public function __construct($services) {
		parent::__construct();
        $this->authType = self::AUTH_TYPE_LOGIN_OR_TOKEN;
		$this->service = new ReferensiService();
	}

    protected function onAfterAuthenticated($params = []) {
        $event = $params["event"];
        if($this->authTypeAccess == self::AUTH_TYPE_LOGIN) {
            if($event->getName() == "create" || $event->getName() == "update") {
                if(!$this->isAllowPrivilage('1918')) return new ApiProblem(405, 'Anda tidak memiliki hak akses');
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
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
		if(isset($params['BAR_RUANGAN'])){
			$data =  $this->service->execute("CALL informasi.infoRuangKamarTidur(?)", [$params['BAR_RUANGAN']]);
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
            $columns = ['*'];
            $pengguna = null;
            if(!empty($params["PENGGUNA"])) {
                $pengguna = $params["PENGGUNA"];
                unset($params["PENGGUNA"]);
            }
            if(!empty($params["JENIS"])) {
                if($params["JENIS"] == 43) {
                    if(!empty($pengguna)) {
                        $columns = [
                            'JENIS', 'ID', 'DESKRIPSI', 'REF_ID', 'TEKS', 'CONFIG', 'SCORING', 'STATUS',
                            'CHECKED' => new \Laminas\Db\Sql\Expression('aplikasi.isUsingGroupPengguna(referensi.ID, '.$pengguna.')')
                        ];
                    }
                }
            }
			$total = $this->service->getRowCount($params);		
			$data = $this->service->load($params, $columns);	
			
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
        $result = parent::update($id, $data);
		return $result;
    }
}
