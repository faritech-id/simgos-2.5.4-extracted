<?php
namespace Cetakan\V1\Rest\KwitansiPembayaran;

class KwitansiPembayaranResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KwitansiPembayaranResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
