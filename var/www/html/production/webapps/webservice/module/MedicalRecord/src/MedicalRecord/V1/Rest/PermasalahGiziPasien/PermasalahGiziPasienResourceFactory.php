<?php
namespace MedicalRecord\V1\Rest\PermasalahGiziPasien;

class PermasalahGiziPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PermasalahGiziPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
