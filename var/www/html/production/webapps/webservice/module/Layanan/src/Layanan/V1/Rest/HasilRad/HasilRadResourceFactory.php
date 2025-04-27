<?php
namespace Layanan\V1\Rest\HasilRad;

class HasilRadResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilRadResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
