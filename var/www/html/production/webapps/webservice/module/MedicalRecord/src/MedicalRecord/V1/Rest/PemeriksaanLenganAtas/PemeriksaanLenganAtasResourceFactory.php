<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLenganAtas;

class PemeriksaanLenganAtasResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanLenganAtasResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
