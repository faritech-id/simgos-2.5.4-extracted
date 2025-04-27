<?php
namespace MedicalRecord\V1\Rest\PemeriksaanUmum;

class PemeriksaanUmumResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanUmumResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
