<?php
namespace Pembayaran\V1\Rest\Tagihan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class TagihanResource extends Resource
{
    protected $title = "Tagihan";

	public function __construct(){
		parent::__construct();
		$this->service = new TagihanService();
        $this->authType = self::AUTH_TYPE_IP_OR_LOGIN;
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {				
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
        if(isset($data->KUNCI)) {
            if($data->KUNCI == 1) {
                $pembayaranService = $this->service->getPembayaranService();
                if(!$pembayaranService->isTagihanPendaftaranTerpisah($id)) {
                    $found = $pembayaranService->masihAdaKunjunganBlmFinal($id);
                    if(is_string($found)) return new ApiProblem(428, '<b>Kunjungan:</b><br/> '.$found.' <b>Belum di Finalkan</b>');
                    
                    $found = $pembayaranService->masihAdaOrderKonsulMutasiYgBlmDiterima($id);
                    if(is_string($found)) return new ApiProblem(428, '<b>'.$found.'Status: Belum Diterima</b>');
                }
            }
        }
        if(isset($data->HITUNGULANG)) {
            if(isset($data->JENIS)) {
                // penjualan
                if($data->JENIS == 4) return $this->service->hitungTotalTagihanPenjualan($id);
            }
            return $this->service->reStoreTagihan($id);
        }
        if(isset($data->REDISTRIBUSI)) {
            $this->service->reDistribusiTagihan($id);
            return $this->fetch($id);
        }
        if(isset($data->STATUS) || isset($data->KUNCI)) {
            $message = isset($data->KUNCI) ? ($data->KUNCI == 1 ? "mengunci" : "membuka kunci") : "membatalkan";
            $data->OLEH = $this->user;
            $success = $this->service->simpanData($data, false);
            if($success) {
                $result["status"] = 200;
                $result["success"] = true;
                $result["data"] = $success[0];
                $result["detail"] = "Berhasil ".$message." tagihan";
                return $result;
            }
            return new ApiProblem(422, 'Terjadi kesalahan pada saat '.$message.' tagihan');
        }
        return [
            'success' => false
        ];
    }
}
