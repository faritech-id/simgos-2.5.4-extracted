<?php
namespace Penjualan\V1\Rest\Penjualan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class PenjualanResource extends Resource
{
	public function __construct() {
		parent::__construct();
		$this->service = new PenjualanService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {	
		$emptyRuangan = false;
		if(!isset($data->RUANGAN)){
			$emptyRuangan = true;
		}else{
			if($data->RUANGAN == ''){
				$emptyRuangan = true;
			}
		}
		if($emptyRuangan){
			return new ApiProblem(405, 'Ruangan Harus Diisi');
		}
		$data->OLEH = $this->user;
        $cekStokBarangRuangan = $this->service->getValidasiStokBarangRuangan($data);
        if(!$cekStokBarangRuangan['success']) {
            return new ApiProblem(405, $cekStokBarangRuangan['message']);
        } else {
            return $this->service->simpan($data);
        }

        //return new ApiProblem(405, 'The POST method has not been defined');
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
    public function fetchAll($params = array())
    {
		$total = $this->service->getRowCount($params);
		$data = $this->service->load($params, array('*'), array('TANGGAL'=>'DESC'));	
		
		return array(
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data
		);
        //return new ApiProblem(405, 'The GET method has not been defined for collections');
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
