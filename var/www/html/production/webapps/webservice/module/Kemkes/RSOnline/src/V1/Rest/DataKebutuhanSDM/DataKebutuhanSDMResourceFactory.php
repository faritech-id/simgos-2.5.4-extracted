<?php
namespace Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM;

class DataKebutuhanSDMResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DataKebutuhanSDMResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
