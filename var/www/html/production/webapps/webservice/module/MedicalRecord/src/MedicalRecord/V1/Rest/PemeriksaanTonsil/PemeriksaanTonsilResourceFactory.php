<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTonsil;

class PemeriksaanTonsilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanTonsilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
