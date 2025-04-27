<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTcd;

class PemeriksaanTcdResourceFactory
{
    public function __invoke($services)
    {
        return new PemeriksaanTcdResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
