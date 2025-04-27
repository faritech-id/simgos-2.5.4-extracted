<?php
namespace BerkasKlaim\V1\Rest\LabKlinik;

class LabKlinikResourceFactory
{
    public function __invoke($services)
    {
        $obj = new LabKlinikResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
