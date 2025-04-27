<?php
namespace Pembatalan\V1\Rest\PembatalanKunjungan;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use Layanan\V1\Rest\PasienPulang\PasienPulangService;
use Pendaftaran\V1\Rest\Mutasi\MutasiService;

class PembatalanKunjunganResource extends Resource
{
    private $pasienpulang;
    private $mutasi;
	public function __construct() {
		parent::__construct();
		$this->service = new PembatalanKunjunganService();
        $this->pasienpulang = new PasienPulangService(false);
        $this->mutasi = new MutasiService(false);
	}
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
		if(!$this->isAllowPrivilage('110804')) {
			return new ApiProblem(405, 'Anda tidak memiliki akses untuk melakukan pembatalan final kunjungan');
		}
				
		$kunjungan = $this->service->getKunjungan();
		/* get kunjungan untuk mengambil nopen */
		$kjgns = $kunjungan->load(array('NOMOR' => $data->KUNJUNGAN));

        /* Validasi Stok Opname Jika Jenis Kunjungan Farmasi */
        $refs = isset($kjgns[0]['REFERENSI']) ? $kjgns[0]['REFERENSI'] : null;
        $jenisRuanganKunjungan = isset($refs['RUANGAN']) ? $refs['RUANGAN'] : null;
        if($jenisRuanganKunjungan['JENIS_KUNJUNGAN'] == 11){
            $isValidSo = $this->service->isValidasiTransaksiStokOpname($kjgns[0]['RUANGAN'],$kjgns[0]['KELUAR']);
            if(!$isValidSo){
                return new ApiProblem(405, 'Periode Stok Opname sudah tutup');
            }
            $isFoundRetur = $this->service->isFoundRetur($kjgns[0]['NOMOR']);
            if($isFoundRetur){
                return new ApiProblem(405, 'Kunjungan tidak dapat di finalkan, sudah ada retur pelayanan');
            }
        }

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

        $properticonf = $this->getPropertyConfig(62);
        if($properticonf){
            if($properticonf == "TRUE"){
                if(!$this->isAllowPrivilage('11080401')){
                    /**  validasi pembatalan final kunjungan 
                     * jika kunjungan telah mengimputkan pasien pulang maka tidak dapat melakukan pembatalan final kunjungan 
                    */
                    $pulang =  $this->pasienpulang->load(["KUNJUNGAN" => $data->KUNJUNGAN, "STATUS" => 1]);
                    if(count($pulang) > 0) return new ApiProblem(405, 'Kunjungan tidak dapat dibatal finalkan karena pasien telah di pulangkan');

                    /**  validasi pembatalan final kunjungan jika jenis pembatalan adalah 2
                     * Jika jenis pembatalan adalah 2 atau ubah tanggal registrasi keluar maka 
                     * jika memiliki mutasi, final kunjungan tidak dapat dibatalkan
                     * harus memilih pembatalan jenis 1 atau kelalaian pengimputan 
                    */
                    if($data->JENIS == 2){
                        $mutasi =  $this->mutasi->load(["KUNJUNGAN" => $data->KUNJUNGAN, "start" => 0, "limit" => 1], ['*'], ['STATUS DESC']);
                        if(count($mutasi) > 0) {
                            $recmutasi = $mutasi[0];
                            if($recmutasi["STATUS"] != 0) return new ApiProblem(405, 'Kunjungan tidak dapat dibatal finalkan karena memiliki mutasi <br> silahkan pilih jenis pembatalan "<b>Kesalahan / Kelalaian / Kelupaan Penginputan</b>"');
                        }
                    }
                }else{
                    /**  validasi pembatalan final kunjungan jika jenis pembatalan adalah 2
                     * Jika jenis pembatalan adalah 2 atau ubah tanggal registrasi keluar 
                     * jika kunjungan tujuan mutasi masih aktif maka tidak bisa dibatalkan
                     * harus membatalkan kunjungan tujuan mutasi terlebih dahulu 
                    */
                    if($data->JENIS == 2){
                        $mutasi =  $this->mutasi->load(["KUNJUNGAN" => $data->KUNJUNGAN, "start" => 0, "limit" => 1], ['*'], ['STATUS DESC']);
                        if(count($mutasi) > 0) {
                            $recmutasi = $mutasi[0];
                            if($recmutasi["STATUS"] > 0) return new ApiProblem(405, 'Kunjungan tidak dapat dibatal finalkan karena memiliki mutasi <br><b>"silahkan membatalkan kunjungan tujuan mutasi terlebih dahulu</b>"');
                        }
                    }
                }
            }
        }

        $cekbonsisa = $this->service->isFoundLynBonSisa($kjgns[0]['NOMOR']);
		if($cekbonsisa){
            return new ApiProblem(405, 'Kunjungan tidak dapat dibatal finalkan karena telah dilakukan pelayanan bon sisa');
        }

		$data->OLEH = $this->user;
		return $this->service->simpan($data);
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
		$prms = array_merge(array(), (array) $params);
        $total = $this->service->getRowCount($params);		
		$data = $this->service->load($prms);	
		
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
