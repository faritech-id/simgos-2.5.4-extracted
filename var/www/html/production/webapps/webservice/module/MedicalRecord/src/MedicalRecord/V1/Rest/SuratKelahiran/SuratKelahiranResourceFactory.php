<?php

namespace MedicalRecord\V1\Rest\SuratKelahiran;

class SuratKelahiranResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SuratKelahiranResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
