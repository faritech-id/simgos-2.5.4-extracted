<?php
namespace LISService\V1\Rest\MappingHasil;

class MappingHasilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MappingHasilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
