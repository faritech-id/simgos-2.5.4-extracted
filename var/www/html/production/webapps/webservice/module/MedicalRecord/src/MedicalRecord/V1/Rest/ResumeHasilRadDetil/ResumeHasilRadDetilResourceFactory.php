<?php
namespace MedicalRecord\V1\Rest\ResumeHasilRadDetil;

class ResumeHasilRadDetilResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ResumeHasilRadDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
