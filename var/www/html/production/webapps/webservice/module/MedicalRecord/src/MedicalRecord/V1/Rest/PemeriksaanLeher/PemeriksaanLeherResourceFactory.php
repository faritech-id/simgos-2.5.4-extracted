<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLeher;

class PemeriksaanLeherResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanLeherResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
