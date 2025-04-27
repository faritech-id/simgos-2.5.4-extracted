<?php
namespace MedicalRecord\V1\Rest\SuratSakit;

class SuratSakitResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SuratSakitResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
