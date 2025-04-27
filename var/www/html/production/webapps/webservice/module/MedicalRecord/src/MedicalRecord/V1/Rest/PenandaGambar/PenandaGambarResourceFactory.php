<?php
namespace MedicalRecord\V1\Rest\PenandaGambar;

class PenandaGambarResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenandaGambarResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
