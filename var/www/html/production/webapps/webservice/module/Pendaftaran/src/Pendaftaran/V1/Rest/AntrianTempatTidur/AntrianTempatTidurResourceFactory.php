<?php
namespace Pendaftaran\V1\Rest\AntrianTempatTidur;

class AntrianTempatTidurResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AntrianTempatTidurResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
