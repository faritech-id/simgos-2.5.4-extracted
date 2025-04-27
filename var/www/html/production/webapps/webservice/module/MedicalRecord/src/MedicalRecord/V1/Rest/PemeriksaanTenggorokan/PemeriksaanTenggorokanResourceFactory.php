<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTenggorokan;

class PemeriksaanTenggorokanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanTenggorokanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
