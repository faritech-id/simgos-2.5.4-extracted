<?php
namespace MedicalRecord\V1\Rest\Resume;

class ResumeResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ResumeResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
