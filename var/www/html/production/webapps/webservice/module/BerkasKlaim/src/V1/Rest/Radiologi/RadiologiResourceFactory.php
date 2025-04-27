<?php
namespace BerkasKlaim\V1\Rest\Radiologi;

class RadiologiResourceFactory
{
    public function __invoke($services)
    {
		$obj = new RadiologiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
