<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPayudara;

class PemeriksaanPayudaraResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanPayudaraResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
