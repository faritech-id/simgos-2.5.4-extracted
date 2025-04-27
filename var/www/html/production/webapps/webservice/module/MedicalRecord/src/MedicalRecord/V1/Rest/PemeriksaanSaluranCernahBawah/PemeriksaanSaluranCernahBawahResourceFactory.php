<?php
namespace MedicalRecord\V1\Rest\PemeriksaanSaluranCernahBawah;

class PemeriksaanSaluranCernahBawahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanSaluranCernahBawahResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
