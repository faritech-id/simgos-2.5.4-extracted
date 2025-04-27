<?php
namespace MedicalRecord\V1\Rest\AnamnesisDiPeroleh;

class AnamnesisDiPerolehResourceFactory
{
    public function __invoke($services)
    {
		$obj = new AnamnesisDiPerolehResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
