<?php
namespace MedicalRecord\V1\Rest\Batuk;

class BatukResourceFactory
{
    public function __invoke($services)
    {
        $obj = new BatukResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
