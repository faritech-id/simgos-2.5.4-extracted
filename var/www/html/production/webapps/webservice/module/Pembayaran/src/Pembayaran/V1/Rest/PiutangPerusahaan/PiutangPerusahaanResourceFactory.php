<?php
namespace Pembayaran\V1\Rest\PiutangPerusahaan;

class PiutangPerusahaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PiutangPerusahaanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
