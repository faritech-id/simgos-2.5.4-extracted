<?php
namespace MedicalRecord\V1\Rest\FaktorRisiko;

class FaktorRisikoResourceFactory
{
    public function __invoke($services)
    {
		$obj = new FaktorRisikoResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
