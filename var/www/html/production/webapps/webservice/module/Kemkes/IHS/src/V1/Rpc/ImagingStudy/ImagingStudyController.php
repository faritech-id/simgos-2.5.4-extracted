<?php
namespace Kemkes\IHS\V1\Rpc\ImagingStudy;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\ImagingStudy\Service;

class ImagingStudyController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new Service();
        $this->resourceType = "ImagingStudy";
        $this->title = 'imaging study';
        $this->paramsQuery = [
            'ascn' => 'identifier=http://sys-ids.kemkes.go.id/acsn/'.$this->config["organization_id"].'|'
        ];
    }

    public function getAction()
    {
        $params = [
            "get" => 1,
            "start" => 0,
            "limit" => 15
        ];
        $data = $this->service->load($params);
        foreach($data as &$record){
            $parameter = '';
            $parameter = $this->setParamsIhs(["ascn" => $record['refId']]);
            $return = $this->sendToIhs($this->resourceType."?".$parameter);
             /* cek data yang tampil */
            if($this->httpcode == 200 || $this->httpcode == 201){
                if(isset($return->entry)){
                    if(count($return->entry) > 0){
                        foreach($return->entry as $object){
                            if(isset($object->resource)){
                                $datains = $this->jsonToString($object->resource);
                                $record['id'] = $datains['id'];
                                $record['get'] = 0;
                                $update = $this->update($record['refId'], $record);
                            }
                        }
                    }
                }else{
                    $record['get'] = 0;
                    $update = $this->update($record['refId'], $record);
                }
            }
        }
        return $data;
    }
}
