<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasiDetil;

class ObatFarmasiDetilResourceFactory
{
    public function __invoke($services)
    {
		$obj = new ObatFarmasiDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
