<?php

namespace MedicalRecord\V1\Rest\MappingIndikatorDiagnosa;

class MappingIndikatorDiagnosaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MappingIndikatorDiagnosaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
