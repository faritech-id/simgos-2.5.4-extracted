<?php
namespace MedicalRecord\V1\Rest\DischargePlanningFaktorRisiko;

class DischargePlanningFaktorRisikoResourceFactory
{
    public function __invoke($services)
    {
		$obj = new DischargePlanningFaktorRisikoResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
