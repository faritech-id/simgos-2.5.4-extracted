<?php
namespace MedicalRecord\V1\Rest\PemeriksaanDada;

class PemeriksaanDadaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanDadaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
