<?php
namespace Pembayaran\V1\Rest\PembayaranTagihan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class PembayaranTagihanResource extends Resource
{
    protected $title = "Pembayaran Tagihan";

	public function __construct(){
		parent::__construct();
		$this->service = new PembayaranTagihanService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $result = [
			"status" => 422,
			"success" => false,
			"detail" => "Gagal menyimpan ".$this->title
        ];

        $data = is_array($data) ? $data : (array) $data;
        if(isset($data["JENIS"])) $this->service->getEntity()->setRequiredFields(true, ["JENIS_LAYANAN_ID", "PENYEDIA_ID", "TANGGAL", "REF", "TOTAL"]);

		$notValidEntity = $this->service->getEntity()->getNotValidEntity($data, false);
        if(count($notValidEntity) > 0) {
			$result["status"] = 412;
            $result["detail"] = $notValidEntity["messages"];
			return new ApiProblem($result["status"], $result["detail"], null, null, ["success" => false]);
        }

        if($data["JENIS"] == 1) {
            if(!$this->service->isTagihanPendaftaranTerpisah($data["TAGIHAN"])) {
                $found = $this->service->masihAdaKunjunganBlmFinal($data["TAGIHAN"]);
                if(is_string($found)) return new ApiProblem(428, '<b>Kunjungan:</b><br/> '.$found.' <b>Belum di Finalkan</b>');
                
                $found = $this->service->masihAdaOrderKonsulMutasiYgBlmDiterima($data["TAGIHAN"]);
                if(is_string($found)) return new ApiProblem(428, '<b>'.$found.'Status: Belum Diterima</b>');
            }

            $founds = $this->service->load([
                "JENIS" => 1,
                "JENIS_LAYANAN_ID" => 1,
                "TAGIHAN" => $data["TAGIHAN"],
                "start" => 0,
                "limit" => 1
            ], ['*'], ['TANGGAL DESC']);
            if(count($founds) > 0) {
                if($founds[0]["STATUS"] == 2) return new ApiProblem(422, '<b>Tagihan ini telah difinalkan</b>');
                if($founds[0]["STATUS"] == 1) {
                    $data["NOMOR"] = $founds[0]["NOMOR"];
                    $data["DIUBAH_OLEH"] = $this->user;
                    $result = parent::update($data["NOMOR"], $data);
                    return $result;
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
        if(isset($params['NOT'])) {
            $nots = (array) json_decode($params["NOT"]);
            foreach($nots as $key => $val) {
                $params[] = new \Laminas\Db\Sql\Predicate\NotIn("pembayaran_tagihan.".$key, $val);
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
