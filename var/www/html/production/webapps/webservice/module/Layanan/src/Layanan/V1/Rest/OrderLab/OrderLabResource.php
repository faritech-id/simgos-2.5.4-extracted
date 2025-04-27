<?php
namespace Layanan\V1\Rest\OrderLab;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class OrderLabResource extends Resource
{
    protected $title = "Order Laboratorium";

	public function __construct() {
		parent::__construct();
		$this->service = new OrderLabService();
		$this->service->setPrivilage(true);
	}

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		if(!$this->isAllowPrivilage('110303')) return new ApiProblem(405, 'Anda tidak memiliki akses order laboratorium');
        
        $cek = $this->service->load([
            'KUNJUNGAN' => $data->KUNJUNGAN, 
            'TANGGAL' => [
                "VALUE" => $data->TANGGAL
            ]
        ]);
        if(count($cek) > 0) return new ApiProblem(405, 'Order Laboratorium sudah terkirim');
        
        $result = parent::create($data);
        return $result;
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
        $result = parent::fetch($id);
		return $result;
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        parent::fetchAll($params);		
        $order = ["order_lab.TANGGAL ASC"];
        $data = null;        
        if (isset($params->sort)) {
			$orders = json_decode($params->sort);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
                $orders->property = $orders->property == "TANGGAL" ? "order_lab.TANGGAL" : $orders->property;
				$order = [$orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : "")];
			}
			unset($params->sort);
		}
        $params = is_array($params) ? $params : (array) $params;
        if (isset($params["NOT"])) {
			$nots = (array) json_decode($params["NOT"]);
			foreach($nots as $key => $val) {                
                $params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOT order_lab.".$key." = ".$val.")");                
			}
			unset($params["NOT"]);
		}
        
        $this->service->setUser($this->user);
        $total = $this->service->getRowCount($params);
		if($total > 0) $data = $this->service->load($params, ['*'], $order);
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $this->title.($total > 0 ? " ditemukan" : " tidak ditemukan")
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
        if(!$this->isAllowPrivilage('11080104')) return new ApiProblem(405, 'Anda tidak memiliki akses pembatalan laboratorium');
        $result = parent::update($id, $data);
        return $result;
    }
}
