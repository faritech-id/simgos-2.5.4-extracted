<?php
namespace Kemkes\IHS\V1\Rpc\Medication;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Medication\Service;


class MedicationController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new Service();
        $this->resourceType = "Medication";
        $this->title = 'medication';
    }

    public function sendAction()
    {
        $params = [
            "send" => 1,
            "start" => 0,
            "limit" => 10
        ];
        $data = $this->service->load($params);
        foreach($data as &$record){
            $refid = $record["refId"];
            $barang = $record["barang"];
            $group_racikan = $record["group_racikan"];
            $id = $record["id"];            
            $status_racikan = $record["status_racikan"];
            $jenis = $record["jenis"];

            unset($record["refId"]);
            unset($record["group_racikan"]);
            unset($record["nopen"]);
            unset($record["barang"]);
            unset($record["status_racikan"]);
            unset($record["jenis"]);
            unset($record["sendDate"]);
            unset($record["send"]);

            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    $record["refId"] = $refid;
                    $record["barang"] = $barang;
                    $record["group_racikan"] = $group_racikan;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;                               
                    $record["status_racikan"] = $status_racikan;
                    $record["jenis"] = $jenis;
                    $this->service->simpan($record);
                }else if($this->httpcode == 400){
                    $record["refId"] = $refid;
                    $record["barang"] = $barang;
                    $record["group_racikan"] = $group_racikan;
                    $record["send"] = 0;                                          
                    $record["status_racikan"] = $status_racikan;
                    $record["jenis"] = $jenis;
                    $this->service->simpan($record);
                }
            }
        }
        return $data;
    }


 public function sendResourceAction(){
        $method = $this->request->getMethod();
		$params = (array) $this->getRequest()->getQuery();
        
        if(isset($params["_dc"])) unset($params["_dc"]);
        if(isset($params["page"])) unset($params["page"]);

        $data = $this->service->load($params);
        foreach($data as &$record){
            $refid = $record["refId"];
            $barang = $record["barang"];
            $group_racikan = $record["group_racikan"];
            $id = $record["id"];            
            $status_racikan = $record["status_racikan"];
            $jenis = $record["jenis"];

            unset($record["refId"]);
            unset($record["group_racikan"]);
            unset($record["nopen"]);
            unset($record["barang"]);
            unset($record["status_racikan"]);
            unset($record["jenis"]);
            unset($record["sendDate"]);
            unset($record["send"]);

            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    $record["refId"] = $refid;
                    $record["barang"] = $barang;
                    $record["group_racikan"] = $group_racikan;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;                               
                    $record["status_racikan"] = $status_racikan;
                    $record["jenis"] = $jenis;
                    $this->service->simpan($record);
                }else if($this->httpcode == 400){
                    $record["refId"] = $refid;
                    $record["barang"] = $barang;
                    $record["group_racikan"] = $group_racikan;
                    $record["send"] = 0;                                          
                    $record["status_racikan"] = $status_racikan;
                    $record["jenis"] = $jenis;
                    $this->service->simpan($record);
                }
            }
        }
        return (array) $respon;
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
        if(isset($data["local"])){
            if($data["id"]){
                $explode = explode("-", $id);
                $data["refId"] = $explode[0];
                $data["barang"] = $explode[1];
                $data["group_racikan"] = $explode[2];     
                $data["status_racikan"] = $explode[3];
                $data["jenis"] = $explode[4];           
                unset($data["id"]);
            }
            unset($data["local"]);
        }
        $respon = $this->service->simpan($data);
        $return["entry"] = [
            "resource" => $data
        ];
        if($respon){
            $loaddt = $this->service->load([
                "refId" => $data["refId"],                    
                "barang" => $data["barang"],                    
                "group_racikan" => $data["group_racikan"],                    
                "status_racikan" => $data["status_racikan"],                    
                "jenis" => $data["jenis"]
            ]);
            if(count($loaddt) > 0){
                $row = $loaddt[0];
                $$row["resourceType"] = $this->resourceType;
                $return["entry"] = [
                    "resource" => $this->stringToJson($row, true)
                ];
            }            
        }
        
        return $return;
    }
}
