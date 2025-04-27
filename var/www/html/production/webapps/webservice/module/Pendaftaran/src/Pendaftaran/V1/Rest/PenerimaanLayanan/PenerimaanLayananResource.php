<?php
namespace Pendaftaran\V1\Rest\PenerimaanLayanan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Laminas\Stdlib\Parameters;
use Pendaftaran\V1\Rest\TujuanPasien\TujuanPasienService;
use Pendaftaran\V1\Rest\Konsul\KonsulService;
use Pendaftaran\V1\Rest\Mutasi\MutasiService;
use Layanan\V1\Rest\OrderLab\OrderLabService;
use Layanan\V1\Rest\OrderRad\OrderRadService;
use Layanan\V1\Rest\OrderResep\OrderResepService;

class PenerimaanLayananResource extends Resource
{
    protected $title = "Penerimaan Layanan";

    private $tujuan;
    private $konsul;
    private $mutasi;
    private $lab;
    private $rad;
    private $resep;
	
	public function __construct() {
		parent::__construct();
		$this->service = new TujuanPasienService(true, [
            'Pendaftaran' => false,
            'Ruangan' => true,
            'Referensi' => true,
            'Dokter' => false,
            'AntrianRuangan' => false
        ]);
        $this->konsul = new KonsulService(true, [
            'Ruangan' => true,
            'Referensi' => true,
            'Dokter' => false,
            'Kunjungan' => false
        ]);
        $this->mutasi = new MutasiService(true, [
            'Ruangan' => true,
            'Referensi' => true,
            'Kunjungan' => false,
            'Reservasi' => false,
            'DPJP' => false
        ]);
        $this->lab = new OrderLabService(true, [
            'Ruangan' => true,
            'Referensi' => true,
            'Dokter' => false,
            'OrderDetil' => false,
            'Kunjungan' => false,
            'Pegawai' => false
        ]);
        $this->rad = new OrderRadService(true, [
            'Pendaftaran' => false,
            'Ruangan' => true,
            'Referensi' => true,
            'Dokter' => false,
            'OrderDetil' => false,
            'Kunjungan' => false
        ]);
        $this->resep = new OrderResepService(true, [
            'Ruangan' => true,
            'Referensi' => true,
            'Dokter' => false,
            'OrderDetil' => false,
            'Kunjungan' => false
        ]);
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
     * @param  array|Parameters $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
        if(count($params) == 0) return new ApiProblem(405, 'Silahkan melakukan pencarian menggunakan parameter NORM, NOPEN dan STATUS');
		if(!isset($params["NORM"]) && !isset($params["NOPEN"])) return new ApiProblem(405, 'Silahkan melakukan pencarian menggunakan parameter NORM atau NOPEN');
        $data = $this->service->load($params, ['*', new \Laminas\Db\Sql\Expression("1 AS JENIS")]);
        $konsul = $this->konsul->load($params, ['*', new \Laminas\Db\Sql\Expression("2 AS JENIS")]);
        if(count($konsul) > 0) $data = array_merge($data, $konsul);
        $mutasi = $this->mutasi->load($params, ['*', new \Laminas\Db\Sql\Expression("3 AS JENIS")]);
        if(count($mutasi) > 0) $data = array_merge($data, $mutasi);
        $lab = $this->lab->load($params, ['*', new \Laminas\Db\Sql\Expression("4 AS JENIS")]);
        if(count($lab) > 0) $data = array_merge($data, $lab);
        $rad = $this->rad->load($params, ['*', new \Laminas\Db\Sql\Expression("5 AS JENIS")]);
        if(count($rad) > 0) $data = array_merge($data, $rad);
        //$resep = $this->resep->load($params, ['*', new \Laminas\Db\Sql\Expression("6 AS JENIS")]);

		return [
			"success" => count($data) > 0 ? true : false,
			"total" => count($data),
			"data" => $data
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
     * Patch (partial in-place update) a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patchList($data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for collections');
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
