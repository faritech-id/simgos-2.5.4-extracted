<?php
namespace Pembatalan\V1\Rest\FinalHasil;

class FinalHasilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new FinalHasilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
