<?php

namespace MedicalRecord\V1\Rest\PemeriksaanEkg;

class PemeriksaanEkgResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanEkgResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
