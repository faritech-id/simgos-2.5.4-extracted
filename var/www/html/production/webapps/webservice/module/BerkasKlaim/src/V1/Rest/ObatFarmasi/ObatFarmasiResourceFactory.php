<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasi;

class ObatFarmasiResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ObatFarmasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
