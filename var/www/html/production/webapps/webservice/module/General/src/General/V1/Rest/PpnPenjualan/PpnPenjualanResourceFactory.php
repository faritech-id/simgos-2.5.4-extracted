<?php
namespace General\V1\Rest\PpnPenjualan;

class PpnPenjualanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PpnPenjualanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
