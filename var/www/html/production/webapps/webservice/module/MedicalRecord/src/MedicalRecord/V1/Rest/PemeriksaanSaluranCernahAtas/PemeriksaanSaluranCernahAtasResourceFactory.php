<?php
namespace MedicalRecord\V1\Rest\PemeriksaanSaluranCernahAtas;

class PemeriksaanSaluranCernahAtasResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanSaluranCernahAtasResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
