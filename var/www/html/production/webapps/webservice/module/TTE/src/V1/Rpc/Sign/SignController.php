<?php
namespace TTE\V1\Rpc\Sign;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\DatabaseService;
use DBService\System;
use DBService\RPCResource;

class SignController extends RPCResource
{
    protected $title = "Sign";
    protected $driver;

    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
        $this->config = $controller->get('Config');
    }

    public function getList()
    {
		$this->response->setStatusCode(405); 
		return [
            'status' => 405,
            'success' => false,
            'data' => null,
			'detail' => 'Method Not Allowed'
		];
    }

    public function get($id)
    {
		$this->response->setStatusCode(405); 
		return [
            'status' => 405,
            'success' => false,
            'data' => null,
			'detail' => 'Method Not Allowed'
		];
    }

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $pc = (array) $this->getPropertyConfig(87, "json");
        if(!$pc["enabled"]) return $this->handleErrorMessage(new ApiProblem(412, "Silahkan aktifkan tanda tangan elektronik di properti config"));
        if(empty($pc["driver"])) return $this->handleErrorMessage(new ApiProblem(412, "Parameter driver tidak boleh kosong"));
        $className = "\\".str_replace(".", "\\", $pc["driver"]);
        if(!class_exists($className)) return $this->handleErrorMessage(new ApiProblem(412, "Driver tidak valid"));
        try {
            $this->config["services"]["tte"] = $pc;
            $this->driver = new $className($this);
            $res = $this->driver->sign($data);
            return $res;
        } catch(\Exception $e) {
            return $this->handleErrorMessage(new ApiProblem($e->getCode(), $e->getMessage()));
        }
	}

    private function handleErrorMessage(ApiProblem $problem) {
        $error = $problem->toArray();
        $this->response->setStatusCode($error["status"]);
        return $error;
    }
}
