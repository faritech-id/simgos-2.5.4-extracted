<?php
namespace Pembayaran\V1\Rest\GabungTagihan;

class GabungTagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GabungTagihanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
