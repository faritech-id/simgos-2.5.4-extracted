<?php
namespace Pembayaran\V1\Rest\PenjaminTagihan;

class PenjaminTagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjaminTagihanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
