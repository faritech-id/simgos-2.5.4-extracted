<?php
namespace Layanan\V1\Rest\TelaahAwalResep;

class TelaahAwalResepResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TelaahAwalResepResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
