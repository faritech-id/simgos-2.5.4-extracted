<?php
namespace MedicalRecord\V1\Rest\PemeriksaanRambut;

class PemeriksaanRambutResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanRambutResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
