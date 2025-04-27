<?php
namespace MedicalRecord\V1\Rest\ResumeHasilRad;

class ResumeHasilRadResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ResumeHasilRadResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
