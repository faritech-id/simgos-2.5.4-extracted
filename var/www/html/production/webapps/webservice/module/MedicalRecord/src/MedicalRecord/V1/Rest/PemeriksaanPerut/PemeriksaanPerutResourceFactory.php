<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPerut;

class PemeriksaanPerutResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanPerutResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
