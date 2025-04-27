<?php
namespace MedicalRecord\V1\Rest\PemeriksaanGenital;

class PemeriksaanGenitalResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanGenitalResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
