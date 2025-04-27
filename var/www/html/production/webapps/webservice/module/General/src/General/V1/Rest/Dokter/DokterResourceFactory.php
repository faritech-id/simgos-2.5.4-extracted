<?php
namespace General\V1\Rest\Dokter;

class DokterResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DokterResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
