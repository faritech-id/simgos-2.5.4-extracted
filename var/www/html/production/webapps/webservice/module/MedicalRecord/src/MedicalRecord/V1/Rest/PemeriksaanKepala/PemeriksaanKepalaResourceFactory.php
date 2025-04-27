<?php
namespace MedicalRecord\V1\Rest\PemeriksaanKepala;

class PemeriksaanKepalaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanKepalaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
