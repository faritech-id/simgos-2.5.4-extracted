<?php
namespace MedicalRecord\V1\Rest\DischargePlanningSkrining;

class DischargePlanningSkriningResourceFactory
{
    public function __invoke($services)
    {
		$obj = new DischargePlanningSkriningResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
