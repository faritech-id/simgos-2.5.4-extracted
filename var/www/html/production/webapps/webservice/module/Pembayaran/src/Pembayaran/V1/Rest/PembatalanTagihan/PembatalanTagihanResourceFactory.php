<?php
namespace Pembayaran\V1\Rest\PembatalanTagihan;

class PembatalanTagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PembatalanTagihanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
