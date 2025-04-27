<?php
namespace MedicalRecord\V1\Rest\RiwayatAlergi;

class RiwayatAlergiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RiwayatAlergiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
