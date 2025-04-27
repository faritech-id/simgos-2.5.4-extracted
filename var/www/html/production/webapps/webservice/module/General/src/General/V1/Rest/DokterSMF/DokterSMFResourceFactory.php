<?php
namespace General\V1\Rest\DokterSMF;

class DokterSMFResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DokterSMFResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
