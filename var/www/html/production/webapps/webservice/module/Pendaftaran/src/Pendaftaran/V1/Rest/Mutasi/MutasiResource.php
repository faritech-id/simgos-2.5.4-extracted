<?php

namespace Pendaftaran\V1\Rest\Mutasi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Layanan\V1\Rest\OrderLab\OrderLabService;
use Layanan\V1\Rest\OrderRad\OrderRadService;
use Layanan\V1\Rest\OrderResep\OrderResepService;

class MutasiResource extends Resource
{
    protected $title = "Kunjungan";
    private $orderlab;
    private $orderrad;
    private $orderresep;

    public function __construct()
    {
        parent::__construct();
        $this->service = new MutasiService();
        $this->orderlab = new OrderLabService();
        $this->orderrad = new OrderRadService();
        $this->orderresep = new OrderResepService();

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
        if ($this->isAllowPrivilage('110302')) {
            $data->OLEH = $this->user;
            // check if mutasi is exists
            $finds = $this->service->load([
                "KUNJUNGAN" => $data->KUNJUNGAN
            ], ['*'], ['TANGGAL DESC']);

            if(count($finds) > 0) {
                if($finds[0]["STATUS"] != 0){
                    return new ApiProblem(406, 'Pasien telah dilakukan mutasi sebelumnya');
                }
            }

            $orderlab = $this->orderlab->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
            if(count($orderlab) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order laboratorium yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

            $orderrad = $this->orderrad->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
            if(count($orderrad) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order radiologi yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

            $orderresep = $this->orderresep->load(["KUNJUNGAN" => $data->KUNJUNGAN, 'STATUS' => 1]);
            if(count($orderresep) > 0) return new ApiProblem(406, 'Kunjungan ini memiliki order resep yang belum diterima <br>Silahkan konfirmasi ke ruangan tujuan order atau batalkan order yang belum diterima');

            return parent::create($data);
        } else return new ApiProblem(405, 'Anda tidak memiliki akses layanan mutasi');
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
        parent::fetchAll($params);
        $order = ["mutasi.TANGGAL ASC"];
        if (isset($params->sort)) {
            $orders = json_decode($params->sort);
            if (is_array($orders)) {
            } else {
                $orders->direction = strtoupper($orders->direction);
                $orders->property = $orders->property == "TANGGAL" ? "mutasi.TANGGAL" : $orders->property;
                $order = [$orders->property . " " . ($orders->direction == "ASC" || $orders->direction == "DESC" ? $orders->direction : "")];
            }
            unset($params->sort);
        }
        $this->service->setUser($this->user);
        $total = $this->service->getRowCount($params);
        $data = [];
        if ($total > 0) $data = $this->service->load($params, ['*'], $order);

        return [
            /*"success" => $total > 0 ? true : false,
            "total" => $total,
            "data" => $data*/
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
        $status = isset($data->STATUS) ? $data->STATUS : 1;
        if ($status == 0) {
            if (!$this->isAllowPrivilage('11080103')) return new ApiProblem(405, 'Anda tidak memiliki akses pembatalan mutasi');
            $cek = $this->service->load(["NOMOR" => $data->NOMOR]);
            if(count($cek) > 0){
                if($cek[0]["STATUS"] == '2') return new ApiProblem(405, 'Mutasi tidak dapat dibatalkan karena mutasi telah diterima oleh ruangan tujuan');
            }
        } else {
            if (!$this->isAllowPrivilage('110302')) return new ApiProblem(405, 'Anda tidak memiliki akses layanan mutasi');
        }
        $data->OLEH = $this->user;
        return parent::update($id, $data);
    }
}
