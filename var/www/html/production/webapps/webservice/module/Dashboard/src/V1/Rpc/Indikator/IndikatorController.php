<?php
namespace Dashboard\V1\Rpc\Indikator;

use DBService\RPCResource;

class IndikatorController extends RPCResource
{
    protected $title = "Indikator";

    public function __construct($controller)
    {
        $this->authType = self::AUTH_TYPE_NOT_SECURE;
        $this->service = new Service();
    }

    public function getList() {
        $queries = (array) $this->request->getQuery();
        $data = $this->service->getList($queries);
        $total = count($data);
        return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ]; 
    }

    public function dataGrafikAction() {
        $queries = (array) $this->request->getQuery();
        $data = $this->service->getDataGrafik($queries);
        $total = count($data);
        return [
	        "status" => $total > 0 ? 200 : 404,
	        "success" => $total > 0 ? true : false,
	        "total" => $total,
	        "data" => $data,
	        "detail" => $this->title." data grafik ".($total > 0 ? "ditemukan" : "tidak ditemukan")
	    ]; 
    }
}
