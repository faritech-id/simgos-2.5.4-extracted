<?php
namespace General\V1\Rest\DokterRuangan;

class DokterRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DokterRuanganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
