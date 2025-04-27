<?php
namespace MedicalRecord\V1\Rest\PenilaianSkalaHumptyDumpty;

class PenilaianSkalaHumptyDumptyResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianSkalaHumptyDumptyResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
