<?php
namespace Kemkes\RSOnline\V1\Rest\DataTempatTidur;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use Kemkes\RSOnline\Resource;

class DataTempatTidurResource extends Resource
{
    protected $title = "Data Tempat Tidur";

    public function __construct() {
        parent::__construct();
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
        $result = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal hapus ".$this->title
        ];
		
        $result["data"] = null;

        $data = $this->service->load([
            "id" => $id
        ]);

        if(count($data) > 0) {            
            /* kirim data */
            $options = [
	            "url" => $this->config["url"],
                "action" => "Fasyankes",
                "method" => "DELETE",
                "data" => [
                    "id_tt" => $data[0]["id_tt"],
                    "ruang" => $data[0]["ruang"]
                ]
            ];
            if(isset($this->config["timeout"])) $options["timeout"] = $this->config["timeout"];
	        $this->sendRequest($options);

            $this->service->hapus([
                "id" => $id
            ]);

            $result["status"] = 200;
			$result["success"] = true;
			//$result["data"] = $success[0];
			$result["detail"] = "Berhasil hapus ".$this->title;            
        } else {
            $result["status"] = 404;
			$result["success"] = false;
			$result["detail"] = 'Data yang akan dihapus dengan id '.$id.' tdk ditemukan';
        }
        
		if(!$result["success"]) return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]); 
		
		return $result;
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
        $order = ["id_tt"];
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

        if(isset($params["kirim"])) {         
            unset($params["kirim"]);
            $limit = 10;
            if(isset($params["limit"])) {
                $limit = $params["limit"];
                unset($params["limit"]);
            }

            $data = $this->service->load([
                "kirim" => 1,
                "start" => 0,
                "limit" => $limit
            ], ['*'], ['tgl_kirim ASC']);

            $total = count($data);
            $terkirim = 0;
            $error = false;
            foreach($data as &$row) {
                if($this->kirim($row)) {
                    $terkirim++;
                } else {
                    $error = true;
                    break;
                }
            }       
            if($error) return new ApiProblem(500, "Gagal kirim ke RS Online. #Silahkan hubungi admin");
            return [
                "status" => 200,
                "success" => true,
                "detail" => "Informasi Pengiriman Data:"
                    ."#Total: ".$total
                    ."#Terkirim: ".$terkirim
            ];
        }

        if(isset($params["loadFromWs"])) {
            if($params["loadFromWs"]) {                
                $options = [
                    "url" => $this->config["url"],
                    "action" => "Fasyankes",
                    "method" => "GET"
                ];
                if(isset($this->config["timeout"])) $options["timeout"] = $this->config["timeout"];
                $result = $this->sendRequest($options);
                
                if($result) {
                    foreach($result->fasyankes as $row) {
                        $row = (array) $row;
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                return new ApiProblem(401, $msg->response);
                                break;
                            }
                        }

                        $founds = $this->service->load([
                            "id_tt" => $row["id_tt"],
                            "ruang" => $row["ruang"] == null ? "" : $row["ruang"]
                        ]);
                        $row["baru"] = 0;
                        $row["kirim"] = 0;
                        $this->service->simpanData($row, count($founds) == 0, false);
                    }
                } else return new ApiProblem(500, "Gagal permintaan data ke RS Online. #Silahkan hubungi admin");
            }
            unset($params["loadFromWs"]);
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

    private function kirim(&$row) {
        $terkirim = false;        
        $params = [
            "id_tt" => $row["id_tt"],
            "ruang" => $row["ruang"],
            "jumlah_ruang" => $row["jumlah_ruang"],
            "jumlah" => $row["jumlah"],
            "terpakai" => $row["terpakai"],
            "terpakai_suspek" => $row["terpakai_suspek"],
            "terpakai_konfirmasi" => $row["terpakai_konfirmasi"],
            "prepare" => $row["prepare"],
            "prepare_plan" => $row["prepare_plan"],
            "covid" => $row["covid"],
            "antrian" => $row["antrian"]
        ];
        $options = [
            "url" => $this->config["url"],
            "action" => "Fasyankes",
            "method" => $row["baru"] == 1 ? "POST" : "PUT",
            "data" => $params
        ];
        if(isset($this->config["timeout"])) $options["timeout"] = $this->config["timeout"];
        $result = $this->sendRequest($options);

        if($result) {
            foreach($result->fasyankes as $_row) {
                $_row = (array) $_row;
                if(isset($_row["status"])) {
                    if(is_numeric($_row["status"])) {
                        if($_row["status"] == 200 || $_row["status"] == 201) {                                    
                            $row["response"] = $_row["message"];
                            $row["baru"] = 0;
                            $row["kirim"] = 0;
                            $row["tgl_kirim"] = new \Laminas\Db\Sql\Expression("NOW()");
                            if(strpos($row["response"], "POST") > 0) {
                                $row["baru"] = 1;
                                $row["kirim"] = 1;
                            }
                            if(strpos($row["response"], "PUT") > 0) {
                                $row["baru"] = 0;
                                $row["kirim"] = 1;
                            }
                            $terkirim = true;
                            $this->service->simpanData($row, false, false);
                        }                                
                    }
                }
            }
        }

        return $terkirim;
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
