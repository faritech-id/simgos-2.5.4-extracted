<?php
namespace MedicalRecord\V1\Rest\KeluhanUtama;

class KeluhanUtamaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KeluhanUtamaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
