<?php
namespace PenjaminRS\V1\Rest\Dpjp;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class DpjpResource extends Resource
{
    protected $title = "Mapping DPJP";

    public function __construct($controller) {
		parent::__construct();
        $this->config = $controller->get('Config');
		$this->config = $this->config['services']['PenjaminRS'];
		#$this->authType = self::AUTH_TYPE_SIGNATURE_OR_LOGIN;
		$this->service = new Service();
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
        $newdata = [];
        if(isset($params["PENJAMIN"])){
            if(isset($params["LOCAL"])) {
                unset($params["LOCAL"]);
                $data = null;
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
            /* mendapatkan url berdasarkan parameter penjamin yang dikirim untuk request ke webservice penjamin */
            $config = $this->config[$params["PENJAMIN"]];
            if($config){
                $config["action"] = 'referensi/dpjp';
                $config["method"] = "GET";
                /* request data dpjp penjamin berdasarkan url penjamin yang dikirim*/
                $respon = $this->sendRequest($config);
                if($respon){
                    $respon = (array) $respon;			
                    $data = isset($respon['data']) ? $respon['data'] : null;
                    if(isset($data->metadata)){
                        if($data->metadata->code == 200){
                            $data = (array) $data->response;
                            $records = $data["list"];
                            foreach($records as &$record){
                                $record = (array) $record;
                                $record_dpjp_rs = $this->service->load(["PENJAMIN" => $params["PENJAMIN"], "DPJP_PENJAMIN" => $record["kode"]]);
                                if(count($record_dpjp_rs) > 0) {
                                    $record_dpjp_rs[0]["REFERENSI"]["DPJP_PENJAMIN"] = $record;
                                    array_push($newdata, $record_dpjp_rs[0]);
                                }else{
                                    array_push($newdata, [
                                        "PENJAMIN" => $params["PENJAMIN"],
                                        "DPJP_PENJAMIN" => $record["kode"],
                                        "DPJP_RS" => "",
                                        "STATUS" => 1,
                                        "REFERENSI" => [
                                            "DPJP_PENJAMIN" =>  $record
                                        ]
                                    ]);
                                }
                            }
                            return [
                                "success" => count($newdata) > 0 ? true : false,
                                "total" => count($newdata),
                                "detail" => $this->title.(count($newdata) > 0 ? " ditemukan" : " tidak ditemukan"),
                                "data" => $newdata
                            ];
                        }
                    }
                }
            }else{
                /* mengirim data kosong jika tidak di temukan url service penjaminRS*/
                return [
                    "success" => false,
                    "detail" => "Data Penjamin dpjp tidak ditemukan",
                    "total" => 0,
                    "data" => null
                ];
            }
        }else{
            return [
                "success" => false,
                "detail" => "Data Penjamin dpjp tidak ditemukan",
                "total" => 0,
                "data" => null
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
