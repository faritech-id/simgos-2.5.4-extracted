<?php
namespace MedicalRecord\V1\Rest\PemeriksaanHidung;

class PemeriksaanHidungResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanHidungResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
