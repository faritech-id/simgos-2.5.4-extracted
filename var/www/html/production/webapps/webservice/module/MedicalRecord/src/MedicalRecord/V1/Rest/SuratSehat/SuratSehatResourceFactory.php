<?php
namespace MedicalRecord\V1\Rest\SuratSehat;

class SuratSehatResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SuratSehatResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
