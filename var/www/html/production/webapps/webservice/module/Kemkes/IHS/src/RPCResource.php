<?php
namespace Kemkes\IHS;

use Laminas\Authentication\Storage\Session as StorageSession;
use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\DatabaseService;
use DBService\System;
use DBService\RPCResource as DBRPCResource;
use Laminas\Json\Json;

class RPCResource extends DBRPCResource{
    protected $token = false;
    protected $resourceType = null;
    protected $storageSession;
    protected $paramsQuery = [];
    protected $url = '';


    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;

        $this->config = $controller->get('Config');
        $this->config = $this->config['services']['KemkesService'];
        $this->config = $this->config['IHS'];
        $this->storageSession = new StorageSession("OAUTH_IHS", "TOKEN");

        $this->token = $this->getToken();
    }

    private function getToken(){
        $db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();
        $session = $this->storageSession->read();
        $sysdate = System::getSysDate($adapter);
        $tanggal = explode(" ", $sysdate);
        $waktu = $tanggal[1];

        /* cek session storege */
        if($session) {
            $data = (array) $session;
            if(!empty($data["access_token"])) {
                $expiresIn = "hh:mm:ss";
                if(strpos($data["expires_in"], "h")) { // h:jam, m:menit, s:second
                    $h = str_pad(str_replace("h", "", $data["expires_in"]), 2, "0", STR_PAD_LEFT);
                    $expiresIn = $h.":00:00";
                }

                if($expiresIn != "hh:mm:ss") {
                    if($data["tanggal"] == $tanggal[0]) {
                        $currentTime = System::getDiffTime($adapter, $data["waktu"], $waktu);
                        if($currentTime < $expiresIn) return $data["access_token"];
                    }
                }
            }
        }
       
        $default = ini_get('max_execution_time');
        $token = false;
        try {
            $timeout = isset($this->config["timeout"]) ? $this->config["timeout"] : 5;
            set_time_limit($timeout);
            /* requset token to ihs */
            $result = $this->doSendRequest([
                "url" => $this->config["auth_url"],
                "action" => "accesstoken?grant_type=client_credentials",
                "method" => "POST",
                "header" => [
                    'Content-type: application/x-www-form-urlencoded'
                ],
                "dataIsJson" => false,
                "data" => 'client_id='.$this->config['id'].'&client_secret='.$this->config['secret']
            ]);
            if($this->httpcode == 200) {
                $data = (array) $result;
                $data["tanggal"] = $tanggal[0];
                $data["waktu"] = $waktu;
                $data["expires_in"] = "1h"; // set expired session 1h: 1hours, 1m: 1menit, 1s: 1second
                /* set session storege */
                $this->storageSession->write(json_decode(json_encode($data)));
                $token = $result->access_token;
            }
        }  catch(\Exception $e) {
            $token = false;
        } finally {
            set_time_limit($default);
            return $token;
        }
    }

    protected function onBeforeSendRequest() {
        if($this->token) $this->headers[count($this->headers)] =  "Authorization: Bearer ".$this->token;
    }

    protected function sendToIhs($action = "", $method = "GET", $data = ""){
        $this->headers = [];
        if($method == "POST" || $method == "PUT") {
            if($this->resourceType) $data["resourceType"] = $this->resourceType;
            $data = json_encode($data);
        }
        
        $default = ini_get('max_execution_time');
        $return = [];

        try {
            $timeout = isset($this->config["timeout"]) ? $this->config["timeout"] : 5;
            set_time_limit($timeout);
            $return = $this->sendRequest($action, $method, $data, "application/json", $this->url);
        }  catch(\Exception $e) {
            $return = [];
        } finally {
            set_time_limit($default);
            return json_decode($return);
        }
    }

    protected function stringToJson($record, $allowNull = false){
        $return = [];
        foreach($record as $key => $val) {
            if(!$allowNull){
                if(empty($val)) continue;
            }
            try{
                $json = Json::decode($val, Json::TYPE_ARRAY);
                $return[$key] = $json ? (is_array($json) || is_object($data) ? $json : $val) : $val;
            }catch(\Exception $e){
                $return[$key] = $val;
            }
        }
        return $return;
    }

    protected function jsonToString($record, $allowNull = false){
        $return = [];
        foreach($record as $key => $val) {
            if(is_array($val) || is_object($val)){
                $json = Json::encode($val, true);
                $return[$key] = $json;
            }else $return[$key] = $val;
        }
        return $return;
    }

    protected function setParamsIhs($params){
        $parameter = '';
        $paramkey = $this->paramsQuery;
        foreach($params as $key => $val){
            $query = '';
            if(isset($paramkey[$key])) $query = $paramkey[$key].''.$val;
            else $query = $key.'='.$val;
            $parameter = empty($parameter) ? $query : $parameter.'&'.$query;
        }
        return $parameter;
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
                $data["refId"] = $data["id"];                
                unset($data["id"]);
            }
            unset($data["local"]);
        }
        $respon = parent::update($id, $data);
        $record = $respon["data"];
        $record["resourceType"] = $this->resourceType;
        $return["entry"] = [
            "resource" => $this->stringToJson($record, true)
        ];
        return $return;
    }

    /**
     * Return single resource
     *
     * @param  mixed $id
     * @return mixed
     */
    public function get($id)
    {
        $return = $this->sendToIhs($this->resourceType."/".$id);
        return (array) $return;
    }

    /**
     * Return list of resources
     *
     * @return mixed
     */
    public function getList()
    {
        $method = $this->request->getMethod();
		$params = (array) $this->getRequest()->getQuery();
        if(isset($params["local"])){
            unset($params["local"]);
            if(isset($params["_dc"])) unset($params["_dc"]);
            if(isset($params["page"])) unset($params["page"]);
            $temp = [];
            $total = $this->service->getRowCount($params);
            $data = $this->service->load($params);
            foreach($data as &$record){
                $record["resourceType"] = $this->resourceType;
                array_push($temp, [
                    "resource" => $this->stringToJson($record, true)
                ]);
            }
            $return["entry"] = $temp;
            $return["total"] = $total;
            return $return;
        }else{
            $parameter = $this->setParamsIhs($params);
            $return = $this->sendToIhs($this->resourceType."?".$parameter);
            return (array) $return;
        }
    }

    public function getInfoTokenAction() {
        $session = $this->storageSession->read();
        if($session) {
            $data = (array) $session;
            return $data;
        }

        return [];
    }
}