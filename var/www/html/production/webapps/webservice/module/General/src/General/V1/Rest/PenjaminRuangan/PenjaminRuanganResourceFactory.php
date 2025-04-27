<?php
namespace General\V1\Rest\PenjaminRuangan;

class PenjaminRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjaminRuanganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
