<?php
namespace MedicalRecord\V1\Rest\PemeriksaanEeg;

class PemeriksaanEegResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanEegResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
