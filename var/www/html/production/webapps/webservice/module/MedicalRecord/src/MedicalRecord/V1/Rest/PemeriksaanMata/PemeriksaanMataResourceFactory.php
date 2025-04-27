<?php
namespace MedicalRecord\V1\Rest\PemeriksaanMata;

class PemeriksaanMataResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanMataResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
