<?php
namespace MedicalRecord\V1\Rest\DiagnosaFarmasi;

class DiagnosaFarmasiResourceFactory
{
    public function __invoke($services)
    {
		$obj = new DiagnosaFarmasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
