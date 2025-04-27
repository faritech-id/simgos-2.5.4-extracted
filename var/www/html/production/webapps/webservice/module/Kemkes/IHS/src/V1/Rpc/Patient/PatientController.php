<?php
namespace Kemkes\IHS\V1\Rpc\Patient;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Patient\Service;
use General\V1\Rest\KIP\KIPService;

class PatientController extends RPCResource
{
    private $kipservice;
    public function __construct($controller)
    {
        parent::__construct($controller);
        $this->service = new Service();
        $this->resourceType = "Patient";
        $this->title = 'patient';
        $this->paramsQuery = [
            'nik' => 'identifier=https://fhir.kemkes.go.id/id/nik|'
        ];
        $this->kipservice = new KIPService();
    }

    public function getIhsAction()
    {
        $params = [
            "httpRequest" => 'GET',
            "statusRequest" => 1,
            "start" => 0,
            "limit" => 15
        ];
        $data = $this->service->load($params);
        foreach($data as &$record){
            $parameter = '';
            $parameter = $this->setParamsIhs(["nik" => $record['nik']]);
            $return = $this->sendToIhs($this->resourceType."?".$parameter);
             /* cek data yang tampil */
            if($this->httpcode == 200 || $this->httpcode == 201){
                if(isset($return->entry)){
                    if(count($return->entry) > 0){
                        foreach($return->entry as $object){
                            if(isset($object->resource)){
                                $datains = $this->jsonToString($object->resource);
                                $datains['refId'] = $record['refId'];
                                $datains['statusRequest'] = 0;
                                $update = $this->update($record['refId'], $datains);
                                $record = $datains;
                            }
                        }
                    }else{
                        $record['statusRequest'] = 0;
                        $update = $this->update($record['refId'], $record);
                    }
                }else{
                    $record['statusRequest'] = 0;
                    $update = $this->update($record['refId'], $record);
                }
            }
        }
        return $data;
    }

    public function getList()
    { 
        $respon = parent::getList();
        $params = (array) $this->getRequest()->getQuery();
        if(isset($params["nik"])){
            if(isset($respon['entry'])){
                foreach($respon['entry'] as $record){
                    if(isset($record->resource)){
                        $cek = $this->kipservice->load(["JENIS" => 1, "NOMOR" => $params["nik"]]);
                        if(count($cek) > 0){
                            $cekpatien = $this->service->load(["refId" => $cek[0]["NORM"]]);
                            $datains = $this->jsonToString($record->resource);
                            $datains = is_array($datains) ? $datains : (array) $datains;      
                            $datains['refId'] = count($cekpatien) > 0 ?  $cekpatien[0]["refId"] : $cek[0]["NORM"];
                            $datains['nik'] = $params["nik"];
                            $datains['statusRequest'] = 0;
                            if(count($cekpatien) > 0) $this->update($datains['refId'], $datains);
                            else $this->create($datains);
                        }
                    }
                };
            }
        }
        
        return $respon;
    }
}
