<?php
namespace General\V1\Rest\DepoLayananFarmasi;

class DepoLayananFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DepoLayananFarmasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
