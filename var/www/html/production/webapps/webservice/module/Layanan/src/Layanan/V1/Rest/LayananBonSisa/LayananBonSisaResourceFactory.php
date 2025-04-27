<?php
namespace Layanan\V1\Rest\LayananBonSisa;

class LayananBonSisaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new LayananBonSisaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
