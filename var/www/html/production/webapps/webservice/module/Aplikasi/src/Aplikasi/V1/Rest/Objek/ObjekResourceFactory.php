<?php
namespace Aplikasi\V1\Rest\Objek;

class ObjekResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ObjekResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
