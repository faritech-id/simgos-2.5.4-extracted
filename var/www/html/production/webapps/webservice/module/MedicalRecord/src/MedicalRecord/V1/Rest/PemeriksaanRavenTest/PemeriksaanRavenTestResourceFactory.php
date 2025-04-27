<?php

namespace MedicalRecord\V1\Rest\PemeriksaanRavenTest;

class PemeriksaanRavenTestResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanRavenTestResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
