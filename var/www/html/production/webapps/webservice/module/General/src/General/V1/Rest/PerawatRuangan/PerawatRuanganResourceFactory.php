<?php
namespace General\V1\Rest\PerawatRuangan;

class PerawatRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PerawatRuanganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
