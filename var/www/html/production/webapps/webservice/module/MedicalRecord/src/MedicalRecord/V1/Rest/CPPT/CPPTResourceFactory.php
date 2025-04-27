<?php
namespace MedicalRecord\V1\Rest\CPPT;

class CPPTResourceFactory
{
    public function __invoke($services)
    {
		$obj = new CPPTResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
