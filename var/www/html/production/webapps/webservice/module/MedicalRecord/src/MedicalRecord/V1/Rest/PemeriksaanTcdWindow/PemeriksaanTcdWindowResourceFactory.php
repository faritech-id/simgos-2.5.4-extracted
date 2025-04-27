<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTcdWindow;

class PemeriksaanTcdWindowResourceFactory
{
    public function __invoke($services)
    {
        return new PemeriksaanTcdWindowResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
