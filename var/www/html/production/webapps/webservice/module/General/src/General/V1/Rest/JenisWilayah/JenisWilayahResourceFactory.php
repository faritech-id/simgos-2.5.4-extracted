<?php
namespace General\V1\Rest\JenisWilayah;

class JenisWilayahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisWilayahResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
