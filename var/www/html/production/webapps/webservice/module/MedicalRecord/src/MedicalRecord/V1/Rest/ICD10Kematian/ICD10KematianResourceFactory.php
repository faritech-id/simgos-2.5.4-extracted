<?php
namespace MedicalRecord\V1\Rest\ICD10Kematian;

class ICD10KematianResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ICD10KematianResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
