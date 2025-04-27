<?php
namespace Aplikasi\V1\Rest\Petunjuk;

class PetunjukResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PetunjukResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
