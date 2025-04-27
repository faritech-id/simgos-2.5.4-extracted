<?php
namespace Dashboard\V1\Rpc\KasusDiagnosa;

use DBService\RPCResource;

class KasusDiagnosaController extends RPCResource
{
    protected $title = "10 Kasus Terbesar Diagnosa";

    public function __construct($controller)
    {
        $this->authType = self::AUTH_TYPE_LOGIN;
        $this->service = new Service();
    }

    public function rjAction() {
        $queries = (array) $this->request->getQuery();
        $data = $this->service->getRJ($queries);
        $total = count($data);
        return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." rawat jalan ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ]; 
    }

    public function rdAction() {
        $queries = (array) $this->request->getQuery();
        $data = $this->service->getRD($queries);
        $total = count($data);
        return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." rawat darurat ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ]; 
    }

    public function riAction() {
        $queries = (array) $this->request->getQuery();
        $data = $this->service->getRI($queries);
        $total = count($data);
        return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." rawat inap ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ]; 
    }
}
