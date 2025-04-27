<?php
namespace MedicalRecord\V1\Rest\PerencanaanRawatInap;

class PerencanaanRawatInapResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PerencanaanRawatInapResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
