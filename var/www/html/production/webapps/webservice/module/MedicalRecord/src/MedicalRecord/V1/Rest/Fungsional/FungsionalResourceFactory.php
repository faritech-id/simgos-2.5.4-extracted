<?php
namespace MedicalRecord\V1\Rest\Fungsional;

class FungsionalResourceFactory
{
    public function __invoke($services)
    {
        $obj = new FungsionalResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
