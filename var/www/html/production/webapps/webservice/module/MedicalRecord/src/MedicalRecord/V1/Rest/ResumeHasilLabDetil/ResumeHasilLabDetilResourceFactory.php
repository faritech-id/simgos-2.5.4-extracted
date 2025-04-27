<?php
namespace MedicalRecord\V1\Rest\ResumeHasilLabDetil;

class ResumeHasilLabDetilResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ResumeHasilLabDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
