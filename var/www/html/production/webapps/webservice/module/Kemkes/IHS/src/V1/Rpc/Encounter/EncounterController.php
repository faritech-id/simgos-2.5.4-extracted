<?php
namespace Kemkes\IHS\V1\Rpc\Encounter;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Encounter\Service;

class EncounterController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new Service();
        $this->resourceType = "Encounter";
        $this->title = 'encounter';
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
            $id = $record["id"];
            unset($record["refId"]);
            unset($record["sendDate"]);
            unset($record["send"]);

            $cektatus = false;
            if($record["status"] == "finished" && $record["diagnosis"] == null) {
                $cektatus = true;
                $record["status"] = "in-progress";
            }

            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    if($cektatus) $record["status"] = "finished";

                    $record["refId"] = $refid;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;
                    $this->update($refid, $record);
                }else if($this->httpcode == 400){   
                    if($cektatus) $record["status"] = "finished";
                             
                    $record['send'] = 0;
                    $this->update($refid, $record);
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
            $id = $record["id"];
            unset($record["refId"]);
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
                    $record["id"] = $respon->id;
                    $record["send"] = 0;
                    $this->update($refid, $record);
                }else if($this->httpcode == 400){            
                    $record['send'] = 0;
                    $this->update($refid, $record);
                }
            }
        }
        return (array) $respon;
    }
}
