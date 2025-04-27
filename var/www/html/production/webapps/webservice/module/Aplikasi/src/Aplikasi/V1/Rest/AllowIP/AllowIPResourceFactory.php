<?php
namespace Aplikasi\V1\Rest\AllowIP;

class AllowIPResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AllowIPResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
