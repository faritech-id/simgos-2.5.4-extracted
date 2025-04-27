<?php
namespace Kemkes\IHS\V1\Rpc\Consent;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Consent\Service;

class ConsentController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $config = $controller->get('Config');
        $config = $config['services']['KemkesService'];
        $config = $config['IHS'];
        $consent = $config['consent'];


        $this->service = new Service();
        //$this->resourceType = "Consent";
        $this->title = 'consent';
        $this->url = $consent['url'];
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
            unset($record["norm"]);
            unset($record["sendDate"]);
            unset($record["send"]);
            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : "Consent";
            $respon =  $this->sendToIhs($action, $method, $record["bodySend"]);
            
            if($respon){
                if(isset($respon->id)){
                    $resarry = is_array($respon) ? $respon : (array) $respon;
                    $resarry = $this->jsonToString($resarry);
                    $resarry["id"] = $respon->id;
                    $resarry["send"] = 0;
                    $this->update($refid, $resarry);
                }else if($this->httpcode == 400){
                    $record["send"] = 0;
                    $this->update($refid, $record);
                }
            }
        }
        return $data;
    }
}
