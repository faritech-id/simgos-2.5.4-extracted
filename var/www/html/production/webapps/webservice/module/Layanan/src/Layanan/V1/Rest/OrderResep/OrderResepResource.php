<?php
namespace Layanan\V1\Rest\OrderResep;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class OrderResepResource extends Resource
{
    protected $title = "Order Resep";

	public function __construct() {
		parent::__construct();
		$this->service = new OrderResepService();
		$this->service->setPrivilage(true);

        $this->service->setResource($this);
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {		
		if(!$this->isAllowPrivilage('110305')) return new ApiProblem(405, 'Anda tidak memiliki akses order resep');
        if($this->service->isNotValidateStok($data)) return new ApiProblem(405, 'Jumlah Item Obat Lebih Besar Dari Jumlah STOK Obat Faskes');
        
        $isValidasiRetriksi = true;
        if($data->RESEP_PASIEN_PULANG == 1){
            if($this->getPropertyConfig(80) == 'TRUE') {
                $isValidasiRetriksi = false;
            }
        }
        if($isValidasiRetriksi){
            $retriksihari = $this->service->isNotValidRetriksi($data);
            if($retriksihari) {
                if($retriksihari['success']) {
                    $notifyMsg = $retriksihari['message'];
                    return new ApiProblem(405, $notifyMsg);
                }
            }
        }

        $kjgn = $this->service->getKunjungan();
        $kjgns = $kjgn->load([
            "NOMOR" => $data->KUNJUNGAN
        ]);
        if(count($kjgns) == 0) return new ApiProblem(405, 'Kunjungan di order resep ini tidak ditemukan');
        if($kjgns[0]["STATUS"] != 1) new ApiProblem(405, 'Kunjungan di order resep tersebut sudah final / dibatalkan');

        $data->OLEH = $this->user;
        $cek = $this->service->load([
            'KUNJUNGAN' => $data->KUNJUNGAN, 
            'TANGGAL' => [
                "VALUE" => $data->TANGGAL
            ]
        ]);		
        if(count($cek) > 0) return new ApiProblem(405, 'Order Resep ini sudah terkirim sebelumnya');
        $data = is_array($data) ? $data : (array) $data;
        if(isset($data["UNIT_LAYANAN"])){
            $results = [];
            $_result = [
                "status" => 422,
                "success" => false,
                "detail" => "Gagal menyimpan ".$this->title
            ];
            $ref = "0";
            foreach($data["UNIT_LAYANAN"] as $tgs) {
                $data["TUJUAN"] = $tgs['TUJUAN'];
                $data["REF"] = $ref;
                $result = parent::create($data);
                if($result["success"]) {
                    $results[] = $result["data"];
                    $ref = $result["data"]["NOMOR"];
                    $_result = $result;
                }
            }
            if($_result["success"]) $_result["data"] = $results;
            return $_result;
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
    public function fetchAll($params = [])
    {
		parent::fetchAll($params);
		$order = ["order_resep.TANGGAL DESC"];
		if (isset($params->sort)) {
			$orders = json_decode($params->sort);
			if(is_array($orders)) {
			} else {
				$orders->direction = strtoupper($orders->direction);
				$orders->property = $orders->property == "TANGGAL" ? "order_resep.TANGGAL" : $orders->property;
				$order = [$orders->property." ".($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : "")];
			}
			unset($params->sort);
		}
		$this->service->setUser($this->user);
		$total = $this->service->getRowCount($params);
		$data = [];
		if($total > 0) $data = $this->service->load($params, ['*'], ['CITO DESC','TANGGAL ASC']);		
		
		return [
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data
        ];
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
        
		$status = isset($data->STATUS) ? $data->STATUS : 1;
		if($status = 0) {
			if(!$this->isAllowPrivilage('11080106')) return new ApiProblem(405, 'Anda tidak memiliki akses Pembatalan Order Resep');
		}

		$result = parent::update($id, $data);
		return $result;
    }
}
