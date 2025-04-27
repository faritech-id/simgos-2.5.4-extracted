<?php
namespace MedicalRecord\V1\Rest\RencanaDanTerapi;

class RencanaDanTerapiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RencanaDanTerapiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
