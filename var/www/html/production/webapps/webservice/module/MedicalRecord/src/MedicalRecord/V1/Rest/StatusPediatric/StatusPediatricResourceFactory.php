<?php
namespace MedicalRecord\V1\Rest\StatusPediatric;

class StatusPediatricResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StatusPediatricResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
