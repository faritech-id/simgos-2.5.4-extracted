<?php
namespace MedicalRecord\V1\Rest\PenilaianSkalaMorse;

class PenilaianSkalaMorseResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianSkalaMorseResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
