<?php
namespace MedicalRecord\V1\Rest\ICD9CM;

class ICD9CMResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ICD9CMResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
