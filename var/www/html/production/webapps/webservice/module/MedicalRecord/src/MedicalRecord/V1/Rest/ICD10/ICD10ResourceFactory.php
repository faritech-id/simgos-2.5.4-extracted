<?php
namespace MedicalRecord\V1\Rest\ICD10;

class ICD10ResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ICD10Resource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
