<?php

namespace MedicalRecord\V1\Rest\PemeriksaanEmg;

class PemeriksaanEmgResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanEmgResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
