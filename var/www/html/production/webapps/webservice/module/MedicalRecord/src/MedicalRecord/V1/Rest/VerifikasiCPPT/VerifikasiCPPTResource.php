<?php
namespace MedicalRecord\V1\Rest\VerifikasiCPPT;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class VerifikasiCPPTResource extends Resource
{
    protected $title = "Verifikasi CPPT";

	public function __construct() {
		parent::__construct();
		$this->service = new Service();
    }

    protected function onAfterAuthenticated($params = []) {
        $event = $params["event"];
        if($event->getName() == "create" || $event->getName() == "update") {
            $ppa = $this->pengguna
                ->getPegawaiService()
                ->isPPA($this->dataAkses->NIP);
            if(!$ppa) return new ApiProblem(405, 'Anda tidak memiliki akses untuk melakukan penginputan / perubahan '.$this->title);
        }
    }
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $cekdpjp = $this->service->cekDPJPKunjungan($data->KUNJUNGAN, $this->dataAkses->NIP);
        if(!$cekdpjp) return  new ApiProblem(405, 'Verifikasi CPPT hanya dapat di lakukan oleh DPJP terkait <br>Silahkan login mengunakan user DPJP terkait');
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
        parent::fetchAll($params);		
        $order = ["TANGGAL DESC"];
		$data = null;
		
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
        $result = parent::update($id, $data);
		return $result;
    }
}
