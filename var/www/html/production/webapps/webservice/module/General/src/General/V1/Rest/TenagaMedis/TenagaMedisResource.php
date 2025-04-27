<?php
namespace General\V1\Rest\TenagaMedis;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use General\V1\Rest\Dokter\DokterResource;
use General\V1\Rest\Perawat\PerawatResource;
use General\V1\Rest\Pegawai\PegawaiResource;
use General\V1\Rest\Referensi\ReferensiResource;

class TenagaMedisResource extends Resource
{
	private $dokter;
	private $tenagamedis = [];
	
	public function __construct() {
		parent::__construct();
		$this->tenagamedis[4] = new DokterResource();	
		$this->tenagamedis[6] = new PerawatResource();
		$this->pegawai = new PegawaiResource();
		$this->referensi = new ReferensiResource(null);
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
		if(isset($params['JENIS'])) {
		    $jenis = $params['JENIS'];
			unset($params['JENIS']);
            $referensi = $this->referensi->fetchAll(["JENIS" => 32, "ID" => $jenis]);
            $id = $referensi['data'][0]['REF_ID'];

            if(isset($this->tenagamedis[$id])) return $this->tenagamedis[$id]->fetchAll($params);
            unset($params["RUANGAN"]);
            $params["PROFESI"] = $id;
            return $this->pegawai->fetchAll($params);
		} else {
            if(isset($params['PROFESI'])) return $this->pegawai->fetchAll($params);
        }
		
		return [];
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
