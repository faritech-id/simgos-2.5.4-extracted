<?php
namespace Layanan\V1\Rest\PemakaianBhp;

class PemakaianBhpResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemakaianBhpResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
