<?php
namespace General\V1\Rest\RuanganFarmasi;

class RuanganFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganFarmasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
