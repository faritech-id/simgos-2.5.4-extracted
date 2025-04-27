<?php
namespace MedicalRecord\V1\Rest\PelaksanaOperasi;

class PelaksanaOperasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PelaksanaOperasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
