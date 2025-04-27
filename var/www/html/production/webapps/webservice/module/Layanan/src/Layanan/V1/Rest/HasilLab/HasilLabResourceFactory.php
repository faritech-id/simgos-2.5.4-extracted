<?php
namespace Layanan\V1\Rest\HasilLab;

class HasilLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
