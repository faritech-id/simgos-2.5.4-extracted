<?php
namespace Layanan\V1\Rest\BonSisa;

class BonSisaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new BonSisaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
