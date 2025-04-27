<?php
namespace BPJS\ICare\V1\Rpc\Validate;

use BPJS\ICare\RPCResource;

class ValidateController extends RPCResource
{
    protected $title = "Validate";

	public function __construct($controller) {
        parent::__construct($controller);
    }

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $return = [
	        "status" => 406,
	        "success" => false,
	        "data" => null,
	        "detail" => $this->title." gagal"
	    ];

        $valid = true;
        if(!isset($data["nomor"])) {
            $return["status"] = 412;
            $return["detail"] = "Parameter nomor tidak boleh kosong";
            $valid = false;
        }
        if(!isset($data["dokterId"])) {
            $return["status"] = 412;
            $return["detail"] = "Parameter dokterId tidak boleh kosong";
            $valid = false;
        }

        if($valid) {
            $result = $this->doSendRequest([
                "url" => $this->config['url'],
                "action" => "validate",
                "method" => "POST",
                "data" => [
                    "param" => $data["nomor"],
                    "kodedokter" => $data["dokterId"]
                ],
                "header" => [
                    "Content-type: application/json"
                ]
            ]);

            if($this->httpcode == 200) {
                if($result->metaData->code == 200) {
                    $return["status"] = 200;
                    $return["success"] = true;
                    $return["data"] = (array) $result->response;
                    $return["detail"] = $this->title." berhasil";
                } else $return["detail"] = $result->metaData->message;
            } else {
                if(is_object($result)) {
                    if(isset($result->metaData)) {
                        if(isset($result->metaData->message)) $return["detail"] = $result->metaData->message;
                    }
                }
            }
        }

        $this->response->setStatusCode($return["status"]);
        return $return;
    }
}
