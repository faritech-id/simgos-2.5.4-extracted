<?php
namespace BerkasKlaim\V1\Rest\PatologiAnatomi;

class PatologiAnatomiResourceFactory
{
    public function __invoke($services)
    {
		$obj = new PatologiAnatomiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
