<?php
namespace Plugins\V2\Rest\RequestReport;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Aplikasi\RequestReport;
use Aplikasi\db\request_report\Service as RequestReportService;
use Plugins\V2\Rest\RequestReport\RequestReportEntity;

class RequestReportResource extends Resource
{
    protected $title = "Request Report";

	private $requestReport;
    protected $authType = self::AUTH_TYPE_IP_OR_LOGIN;

    public function __construct(){
		parent::__construct();
        $this->service = new RequestReportService();
	}

    public function setServiceManager($serviceManager) {
        parent::setServiceManager($serviceManager);
        $this->config = $serviceManager->get('Config');
        $this->config = $this->config['services']['SIMpelService'];
        $this->requestReport = new RequestReport($serviceManager->get('Config'));
        $this->entity = new RequestReportEntity();
	}

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $data = is_object($data) ? (array) $data : $data;
        $notValidEntity = $this->entity->getNotValidEntity($data, false);
        if(count($notValidEntity) > 0) return new ApiProblem(412, "Parameter ".$notValidEntity["messages"], null, null, ["success" => false]); 
        if(isset($this->config['plugins']["Plugins"])) {
            $plugins = $this->config['plugins']["Plugins"];
            if($plugins["remote"]) {
                $data["USER_ID"] = $this->user;
                $data["USER_NAMA"] = $this->dataAkses->NAME;
                $data["USER_NIP"] = $this->dataAkses->NIP;
                $data["REMOTE"] = true;

                $result = $this->sendRequest([
                    "url" => $plugins["url"],
                    "action" => "request-report",
                    "method" => "POST",
                    "data" => $data
                ]);
                if($this->httpcode == 200 || $this->httpcode == 201) {
                    if($result) return (array) $result;
                }
                return new ApiProblem(404, $result);
            }
        }

        if(!isset($data["REMOTE"])) {
            $data["USER_ID"] = $this->user;
            $data["USER_NAMA"] = $this->dataAkses->NAME;
            $data["USER_NIP"] = $this->dataAkses->NIP;
        }
        return $this->requestReport->create($data);
    }

    /**
     * Delete a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function delete($id)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for individual resources');
    }

    /**
     * Delete a collection, or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function deleteList($data)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for collections');
    }

    /**
     * Fetch a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function fetch($id)
    {
        return new ApiProblem(405, 'The GET method has not been defined for individual resources');
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        if(count($params) < 2) return new ApiProblem(412, 'Parameter request tidak valid');
        $params["STATUS"] = 2;
        $rss = $this->requestReport->getRequestServiceStorage();
        $data = null;
        $total = $rss->getRowCount($params);
		if($total > 0) $data = $rss->load($params, ['*'], ["TTD_TANGGAL DESC"]);

        if($data) {
            foreach($data as &$d) {
                unset($d["KEY"]);
                unset($d["REQUEST_DATA"]);
                unset($d["KEY"]);
                unset($d["DOCUMENT_DIRECTORY_ID"]);
                unset($d["REF_ID"]);            
            }
        }
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => "Request Report ".($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];        
    }

    /**
     * Patch (partial in-place update) a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patch($id, $data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for individual resources');
    }

    /**
     * Replace a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function replaceList($data)
    {
        return new ApiProblem(405, 'The PUT method has not been defined for collections');
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
        return new ApiProblem(405, 'The PUT method has not been defined for individual resources');
    }
}
