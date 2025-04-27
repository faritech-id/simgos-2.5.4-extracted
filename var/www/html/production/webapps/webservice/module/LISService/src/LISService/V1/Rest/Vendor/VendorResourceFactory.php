<?php
namespace LISService\V1\Rest\Vendor;

class VendorResourceFactory
{
    public function __invoke($services)
    {
        $obj = new VendorResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
