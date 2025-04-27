<?php
namespace BerkasKlaim\V1\Rest\LabKlinikDetil;

class LabKlinikDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new LabKlinikDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
