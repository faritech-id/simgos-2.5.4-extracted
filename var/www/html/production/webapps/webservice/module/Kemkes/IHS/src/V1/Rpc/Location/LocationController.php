<?php
namespace Kemkes\IHS\V1\Rpc\Location;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Location\Service;

class LocationController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new Service();
        $this->resourceType = "Location";
        $this->title = 'location';
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
            $record["status"] = $record["status"] == 1 ? 'active' : 'inactive';

            unset($record["refId"]);
            unset($record["sendDate"]);
            unset($record["send"]);
            unset($record["flag"]);
            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($this->httpcode == 200 || $this->httpcode == 201){
                if($respon){
                    if(isset($respon->id)){
                        $record["refId"] = $refid;
                        $record["id"] = $respon->id;
                        $record["send"] = 0;
                        $this->update($refid, $record);
                    }
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
            $codestatus = $record["status"];
           
            unset($record["refId"]);
            unset($record["sendDate"]);
            unset($record["send"]);
            unset($record["flag"]);
            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    $record["status"] = $codestatus;
                    $record["refId"] = $refid;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;
                    $this->update($refid, $record);
                }
            }
        }
        return (array) $respon;
    }
    
    public function updateResource($id, $data)
    {
        $data = is_array($data) ? $data : (array) $data;

        if(isset($data["id"])){
            $data["refId"] = $data["id"];
            unset($data["id"]);
        }

        $update = parent::update($id, $data);
        return $update;
    }
}
