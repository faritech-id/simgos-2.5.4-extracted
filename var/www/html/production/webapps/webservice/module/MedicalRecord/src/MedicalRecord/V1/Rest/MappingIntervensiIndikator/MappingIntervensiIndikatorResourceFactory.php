<?php

namespace MedicalRecord\V1\Rest\MappingIntervensiIndikator;

class MappingIntervensiIndikatorResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MappingIntervensiIndikatorResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
