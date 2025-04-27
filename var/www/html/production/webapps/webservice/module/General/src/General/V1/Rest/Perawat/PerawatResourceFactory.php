<?php
namespace General\V1\Rest\Perawat;

class PerawatResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PerawatResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
