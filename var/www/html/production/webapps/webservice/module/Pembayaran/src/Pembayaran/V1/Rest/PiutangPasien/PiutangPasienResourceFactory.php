<?php
namespace Pembayaran\V1\Rest\PiutangPasien;

class PiutangPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PiutangPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
