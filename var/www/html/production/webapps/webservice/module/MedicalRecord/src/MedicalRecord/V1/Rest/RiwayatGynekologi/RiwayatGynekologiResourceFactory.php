<?php
namespace MedicalRecord\V1\Rest\RiwayatGynekologi;

class RiwayatGynekologiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RiwayatGynekologiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
