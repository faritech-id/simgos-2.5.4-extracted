<?php
namespace Layanan\V1\Rest\ReturFarmasi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class ReturFarmasiResource extends Resource
{
	public function __construct(){
		parent::__construct();
		$this->service = new ReturFarmasiService();
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $isKunjungan = $this->service->getKunjungan($data->ID_FARMASI);
        if(!$isKunjungan){
            return new ApiProblem(405, 'Kesalahan data kunjungan');
        }

        $noKunjungan = $isKunjungan[0]['NOMOR'];
        $ruangan = $isKunjungan[0]['RUANGAN'];

        /* Validasi Stok Opname */
        $isValidSo = $this->service->isValidasiTransaksiStokOpname($ruangan,$data->TANGGAL);
        if(!$isValidSo){
            return new ApiProblem(405, 'Periode Stok Opname sudah tutup');
        }
        $kunjungan = $this->service->getDataKunjungan();
        $kjgns = $kunjungan->load(array('NOMOR' => $noKunjungan));
		if(count($kjgns) > 0) {
			$kjgn = $kjgns[0];
			/* get pendaftaran */
			$ref = $kjgn['REFERENSI'];
			$pdftrn = $ref['PENDAFTARAN'];
			/* jika status pendaftaran selesai(sudah bayar) = 2 maka tolak */
			if($pdftrn['STATUS'] == 2) {
				return new ApiProblem(405, 'Pendaftaran untuk kunjungan ini sudah selesai / sudah bayar');
			}
		}
        $isCek = $this->service->getJumlahRetur($data->ID_FARMASI);
        
        if($isCek){
            if($data->JUMLAH > $data->JUMLAH_LAYANAN){
                return new ApiProblem(405, 'Jumlah tidak boleh lebih besar dari jumlah yang dilayani');
            }
            $sisa = $data->JUMLAH_LAYANAN - $isCek;
            if($data->JUMLAH > $sisa){
                return new ApiProblem(405, 'Jumlah retur sudah melebihi jumlah yang dilayani');
            }
            $data->OLEH = $this->user;
            $this->service->simpan($data);
        } else {
            if($data->JUMLAH > $data->JUMLAH_LAYANAN){
                return new ApiProblem(405, 'Jumlah tidak boleh lebih besar dari jumlah yang dilayani');
            }
            $data->OLEH = $this->user;
            $this->service->simpan($data);
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
		$data = $this->service->load($params);	
		
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
