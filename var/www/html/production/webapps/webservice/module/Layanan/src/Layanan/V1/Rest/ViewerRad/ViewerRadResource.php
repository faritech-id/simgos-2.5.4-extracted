<?php
namespace Layanan\V1\Rest\ViewerRad;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class ViewerRadResource extends Resource
{
	private $api;
	
	public function __construct() {
		parent::__construct();
		$this->service = new Service();
	}
	
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        return new ApiProblem(405, 'The POST method has not been defined');
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
		$config = $this->serviceManager->get("Config");
		$pacs = $config["services"]["PACService"];
		$this->api = $pacs["api"];
        $series = $this->getSeriesId($params["TINDAKAN_MEDIS"]);
        if(is_array($series)) {
            if(count($series) > 0) header("Location: ".($this->api["url"].$this->api["viewer"])."?series=".$series[0]);
        }
		exit;
    }

    private function getSeriesId($accessionNumber) {
        $options = [
            "url" => $this->api["url"]."tools/find",
            "method" => "POST",
            "data" => [
                "Level" => "Series",
                "Query" => [
                    "0008,0050" => $accessionNumber
                ]
            ],
            "header" => [
                "Authorization: Basic ".base64_encode($this->api["username"].":".$this->api["password"])
            ]
        ];
        return $this->sendRequest($options);
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
