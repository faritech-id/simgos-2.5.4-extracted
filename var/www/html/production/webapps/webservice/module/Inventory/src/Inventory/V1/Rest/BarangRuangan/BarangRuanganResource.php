<?php
namespace Inventory\V1\Rest\BarangRuangan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Inventory\V1\Rest\Barang\BarangService;

class BarangRuanganResource extends Resource
{
	public function __construct() {
		parent::__construct();
		$this->service = new BarangRuanganService();
	}	
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		$this->service->simpan($data);
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
		if(isset($params->BARANG_RS)){
            unset($params->BARANG_RS);
            unset($params->RUANGAN);

            $stok = "";
            if(isset($params->STOK)) {
                $stok = $params->STOK;
                unset($params->STOK);
            }
            $masterbarang = new BarangService();
            $total = $masterbarang->getRowCount($params);
            $params[] = new \Laminas\Db\Sql\Predicate\Expression("STATUS = 1");
            $row = $masterbarang->load($params, array('*'));
            $data = [];
            foreach($row as &$entity) {
                $rows = array();
                $rows['BARANG'] = $entity['ID'];
                $rows['REFERENSI']['BARANG'] = $entity;
                $rows['ID'] = $entity['ID'];
                $rows['RUANGAN'] = "0";
                $params2 = array();
                $params2['BARANG'] = $entity['ID'];
                $params2['STATUS'] = 1;
                $rec = $this->service->load($params2, array('*', "STOKTERSEDIA" => new \Laminas\Db\Sql\Expression('FLOOR(SUM(barang_ruangan.STOK))')));
                $rows['STOK'] = $rec[0]['STOKTERSEDIA'];
                $add = true;
                if($stok != "") {
                    $add = $this->service->compareValueWithOperator($stok, $rows['STOK']);
                }
                    
                if($add) array_push($data,$rows);
            }
        } else {
            $total = $this->service->getRowCount($params);
            $data = $this->service->load($params, array('*'));
        }
		return array(
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data
		);	
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
        if($data->STATUS == 0){
            $cek = $this->service->load([
                "ID" => $id
            ]);
            if(count($cek) == 0) return new ApiProblem(405, 'Record Not Found');
            if($cek[0]["STOK"] != 0) return new ApiProblem(405, 'Barang tidak dapat di non aktifkan, Stok tidak normal');
        }
        if($data->STATUS == 1){
            $cek = $this->service->load([
                "ID" => $id
            ]);
            if(count($cek) == 0) return new ApiProblem(405, 'Record Not Found');
            if($cek[0]["REFERENSI"]["STATUS"] != 1) return new ApiProblem(405, 'Barang tidak dapat di aktifkan, Status Master Tidak Aktif');
        }
		$this->service->simpan($data);
        //return new ApiProblem(405, 'The PUT method has not been defined for individual resources');
    }
}
