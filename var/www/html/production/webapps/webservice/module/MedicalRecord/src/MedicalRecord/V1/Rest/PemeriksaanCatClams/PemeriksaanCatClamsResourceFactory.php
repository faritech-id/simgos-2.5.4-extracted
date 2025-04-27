<?php
namespace MedicalRecord\V1\Rest\PemeriksaanCatClams;

class PemeriksaanCatClamsResourceFactory
{
    public function __invoke($services)
    {
        return new PemeriksaanCatClamsResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
