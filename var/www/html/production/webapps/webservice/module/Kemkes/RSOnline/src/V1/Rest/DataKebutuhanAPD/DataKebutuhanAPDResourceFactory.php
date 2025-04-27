<?php
namespace Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD;

class DataKebutuhanAPDResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DataKebutuhanAPDResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
