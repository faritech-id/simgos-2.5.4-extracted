<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLidah;

class PemeriksaanLidahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanLidahResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
