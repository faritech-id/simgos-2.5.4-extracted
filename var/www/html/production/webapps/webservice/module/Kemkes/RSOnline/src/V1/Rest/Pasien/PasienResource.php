<?php
namespace Kemkes\RSOnline\V1\Rest\Pasien;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use Kemkes\RSOnline\Resource;

class PasienResource extends Resource
{
    protected $title = "Pasien";

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
        $data->dibuat_oleh = $this->user;
        $result = parent::create($data);
        if(isset($data->kirim)) {
            if($data->kirim) {
                if($result["success"]) {            
                    $this->kirim($result["data"]);
                }    
            }
        }        
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
        $order = ["tgl_lapor DESC"];
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

        if(isset($params["statistik"])) {            
            unset($params["statistik"]);
            $data = $this->service->statistikPasien();
            return [
                "status" => 200,
                "success" => true,
                "data" => $data,
                "detail" => "Data statistik ditemukan"
            ];
        }

        if(isset($params["kirim"])) {            
            unset($params["kirim"]);

            $data = $this->service->load([
                "kirim" => 1
            ]);
            
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
                    "action" => "Pasien",
                    "method" => "GET"
                ];
                if(isset($this->config["timeout"])) $options["timeout"] = $this->config["timeout"];             
                $result = $this->sendRequest($options);
                
                if($result) {
                    foreach($result->pasien as $row) {
                        $row = (array) $row;
                        if(isset($row["status"])) {
                            if(is_numeric($row["status"])) {
                                $msg = json_decode($row["message"]);
                                return new ApiProblem(401, $msg->response);
                                break;
                            }
                        }

                        $founds = $this->service->load([
                            "nomr" => $row["nomr"]
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
            "noc" => $row["noc"]
            , "nomr" => $row["nomr"]
            , "initial" => $row["initial"]
            , "nama_lengkap" => $row["nama_lengkap"]
            , "tglmasuk" => $row["tglmasuk"]
            , "gender" => $row["gender"]
            , "birthdate" => $row["birthdate"]
            , "kewarganegaraan" => $row["kewarganegaraan"]
            , "sumber_penularan" => $row["sumber_penularan"]
            , "kecamatan" => $row["kecamatan"]
            , "tglkeluar" => $row["tglkeluar"]
            , "status_keluar" => $row["status_keluar"]
            , "tgl_lapor" => $row["tgl_lapor"]
            , "status_rawat" => $row["status_rawat"]
            , "status_isolasi" => $row["status_isolasi"]
            , "email" => $row["email"]
            , "notelp" => $row["notelp"]
            , "sebab_kematian" => $row["sebab_kematian"]
            , "jenis_pasien" => $row["jenis_pasien"]
        ];
        $options = [
            "url" => $this->config["url"],
            "action" => "Pasien",
            "method" => $row["baru"] == 1 ? "POST" : "PUT",
            "data" => $params
        ];
        if($row["hapus"] == 1) {
            $options["method"] = "DELETE";
            $options["header"] = [
                "nomr: ".$params["nomr"]
            ];
            $options["data"] = "";
        }
        if(isset($this->config["timeout"])) $options["timeout"] = $this->config["timeout"];
        $result = $this->sendRequest($options);

        if($result) {
            foreach($result->pasien as $_row) {
                $_row = (array) $_row;
                if(isset($_row["status"])) {
                    if(is_numeric($_row["status"])) {
                        if($_row["status"] == 200 || $_row["status"] == 201) {                                    
                            $row["response"] = $_row["message"];
                            $row["baru"] = 0;
                            $row["kirim"] = 0;
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
        $data->diubah_oleh = $this->user;
        $data->tgl_diubah = new \Laminas\Db\Sql\Expression("NOW()");
        $result = parent::update($id, $data);        
        if(isset($data->kirim)) {
            if($data->kirim) {
                if($result["success"]) {            
                    $this->kirim($result["data"]);
                }    
            }
        }

		return $result;
    }
}
