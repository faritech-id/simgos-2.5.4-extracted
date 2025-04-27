<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTungkaiBawah;

class PemeriksaanTungkaiBawahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanTungkaiBawahResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
