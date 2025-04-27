<?php
namespace MedicalRecord\V1\Rest\StatusFungsional;

class StatusFungsionalResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StatusFungsionalResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
