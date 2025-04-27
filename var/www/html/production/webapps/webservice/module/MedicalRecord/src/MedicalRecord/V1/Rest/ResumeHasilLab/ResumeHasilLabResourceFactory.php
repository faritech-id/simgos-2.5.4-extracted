<?php
namespace MedicalRecord\V1\Rest\ResumeHasilLab;

class ResumeHasilLabResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ResumeHasilLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
