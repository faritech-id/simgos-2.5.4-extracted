<?php
namespace Dashboard\V1\Rpc\Laboratorium;

use DBService\RPCResource;

class LaboratoriumController extends RPCResource
{
    protected $title = "Laboratorium";

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
}
