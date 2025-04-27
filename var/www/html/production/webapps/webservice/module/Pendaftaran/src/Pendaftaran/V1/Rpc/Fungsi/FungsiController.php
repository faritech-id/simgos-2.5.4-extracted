<?php
namespace Pendaftaran\V1\Rpc\Fungsi;

use DBService\RPCResource;
use Laminas\ApiTools\ApiProblem\ApiProblem;
use Pendaftaran\V1\Rest\Pendaftaran\PendaftaranService;

class FungsiController extends RPCResource
{
    protected $authType = self::AUTH_TYPE_LOGIN;
    
    public function __construct($controller) {
        $this->service = new PendaftaranService();
    }

    public function getPendaftaranAsalAction() {
        $query = (array) $this->getRequest()->getQuery();
        $result = $this->service->getPendaftaranAsal($query["KUNJUNGAN_NOMOR"], $query["PENJAMIN_ID"], $query["RUANGAN_ID"]);
        $data = [];
        if(count($result) > 0) $data = (array) json_decode($result[0]["DATA"]);
        return $data;
    }
}
