<?php
namespace BerkasKlaim\V1\Rest\RadiologiDetil;

class RadiologiDetilResourceFactory
{
    public function __invoke($services)
    {
		$obj = new RadiologiDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
