<?php
namespace MedicalRecord\V1\Rest\PemeriksaanTelinga;

class PemeriksaanTelingaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanTelingaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
