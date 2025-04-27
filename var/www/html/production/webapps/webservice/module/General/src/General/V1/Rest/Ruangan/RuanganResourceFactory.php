<?php
namespace General\V1\Rest\Ruangan;

class RuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
