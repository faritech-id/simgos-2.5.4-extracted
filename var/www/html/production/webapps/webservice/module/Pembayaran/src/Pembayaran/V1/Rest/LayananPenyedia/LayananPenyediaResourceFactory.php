<?php
namespace Pembayaran\V1\Rest\LayananPenyedia;

class LayananPenyediaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new LayananPenyediaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
