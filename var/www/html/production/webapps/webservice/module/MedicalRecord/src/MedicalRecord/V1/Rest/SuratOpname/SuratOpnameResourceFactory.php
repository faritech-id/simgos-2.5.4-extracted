<?php
namespace MedicalRecord\V1\Rest\SuratOpname;

class SuratOpnameResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SuratOpnameResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
