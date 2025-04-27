<?php
namespace LISService\V1\Rest\StatusHasil;

class StatusHasilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StatusHasilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
