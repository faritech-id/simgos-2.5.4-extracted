<?php
namespace Kemkes\IHS\V1\Rpc\Organization;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Organization\Service as organizationService;

class OrganizationController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new organizationService();
        $this->resourceType = "Organization";
        $this->title = 'organization';
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
            unset($record["flag"]);
            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    $record["active"] = $record["active"] ? 1 : 0;
                    $record["refId"] = $refid;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;
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
            unset($record["flag"]);
            $record = $this->stringToJson($record);
            
            $method = $id ? "PUT" : "POST";
            $action =  $id ? $this->resourceType."/".$id : $this->resourceType;

            $respon =  $this->sendToIhs($action, $method, $record);
            $record = $this->jsonToString($record);
            if($respon){
                if(isset($respon->id)){
                    $record["active"] = $record["active"] ? 1 : 0;
                    $record["refId"] = $refid;
                    $record["id"] = $respon->id;
                    $record["send"] = 0;
                    $this->update($refid, $record);
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
                $cek = $this->service->load(["refId" => $data["id"]]);
                $idtemp = $data["idTemp"];
                if(count($cek) > 0){
                    $data = $cek[0];
                    $data["id"] = $idtemp;
                    $return = parent::update($id, $data);
                    return [
                        "success" => true,
                        "entry" => $return['entry']
                    ];
                }else return new ApiProblem(405, 'Gagal Update Organization ID');
            }
            unset($data["local"]);
        }
        $respon = parent::update($id, $data);
        return $respon;
    }
}
