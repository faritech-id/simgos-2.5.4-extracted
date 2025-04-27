<?php
namespace MedicalRecord\V1\Rest\RiwayatLainnya;

class RiwayatLainnyaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RiwayatLainnyaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
