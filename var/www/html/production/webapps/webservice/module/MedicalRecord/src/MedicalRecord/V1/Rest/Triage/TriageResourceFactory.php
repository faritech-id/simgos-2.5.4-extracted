<?php
namespace MedicalRecord\V1\Rest\Triage;

class TriageResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TriageResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
