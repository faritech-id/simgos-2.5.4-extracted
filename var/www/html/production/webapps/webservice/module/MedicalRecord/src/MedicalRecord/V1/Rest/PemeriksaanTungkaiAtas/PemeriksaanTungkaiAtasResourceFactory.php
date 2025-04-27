<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTungkaiAtas;

class PemeriksaanTungkaiAtasResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanTungkaiAtasResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
