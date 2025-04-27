<?php
namespace Layanan\V1\Rest\PasienPulang;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Layanan\V1\Rest\OrderLab\OrderLabService;
use Layanan\V1\Rest\OrderRad\OrderRadService;
use Layanan\V1\Rest\OrderResep\OrderResepService;
use Pembayaran\V1\Rest\Tagihan\TagihanService;

class PasienPulangResource extends Resource
{
    protected $title = "Pasien Pulang";
    private $orderlab;
    private $orderrad;
    private $orderresep;
    private $tagihan;

	public function __construct() {
		parent::__construct();
		$this->service = new PasienPulangService();
        $this->orderlab = new OrderLabService(false);
        $this->orderrad = new OrderRadService(false);
        $this->orderresep = new OrderResepService(false);
        $this->tagihan = new TagihanService(false);
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $find = $this->service->load([
            "NOPEN" => $data->NOPEN,
            "STATUS" => 1
        ]);
        if(count($find) > 0) return new ApiProblem(405, 'Pasien telah di pulangkan');

        $orderlab = $this->orderlab->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
        if(count($orderlab) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order laboratorium yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

        $orderrad = $this->orderrad->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
        if(count($orderrad) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order radiologi yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

        $orderresep = $this->orderresep->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
        if(count($orderresep) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order resep yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

        if($this->getPropertyConfig(67) == 'TRUE') {
            $info = $this->tagihan->getDataJumlahLamaDirawatDanVisiteDokterPerawat($data->NOPEN);
            if($info) {
                if($info != '') {
                    try {
                        $info = (array) json_decode($info);
                        if($info["AKOMODASI"] != $info["VISITE"]) {
                            $msg = "Jumlah lama dirawat (akomodasi): ".$info["AKOMODASI"]
                                ."<br>dan<br>"
                                ."Jumlah Visite Dokter dan Perawat: ".$info["VISITE"]
                                ."<br><br>"
                                .'<strong>Harus sama</strong>'; 
                            return new ApiProblem(406, $msg);
                        }
                    } catch(\Exception $e) {}
                }
            }
        }

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
    public function fetchAll($params = array())
    {
        parent::fetchAll($params);		
        $order = ["TANGGAL DESC"];
        $data = null;        
        if (isset($params->sort)) {
			$orders = json_decode($params->sort);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$order = [$orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : "")];
			}
			unset($params->sort);
		}
        $params = is_array($params) ? $params : (array) $params;
        if (isset($params["NOT"])) {
			$nots = (array) json_decode($params["NOT"]);
			foreach($nots as $key => $val) {                
                $params[] = new \Laminas\Db\Sql\Predicate\Expression("(NOT pasien_pulang.".$key." = ".$val.")");                
			}
			unset($params["NOT"]);
		}
        
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
		$result = parent::update($id, $data);
		return $result;
    }
}
