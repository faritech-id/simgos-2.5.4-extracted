<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPunggung;

class PemeriksaanPunggungResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanPunggungResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
