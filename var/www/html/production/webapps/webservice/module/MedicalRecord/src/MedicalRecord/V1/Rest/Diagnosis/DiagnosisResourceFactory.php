<?php
namespace MedicalRecord\V1\Rest\Diagnosis;

class DiagnosisResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiagnosisResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
