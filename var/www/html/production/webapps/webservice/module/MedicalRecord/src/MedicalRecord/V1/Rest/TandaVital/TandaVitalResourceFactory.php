<?php
namespace MedicalRecord\V1\Rest\TandaVital;

class TandaVitalResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TandaVitalResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
