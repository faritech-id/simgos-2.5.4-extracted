<?php
namespace MedicalRecord\V1\Rest\PenandaGambarDetail;

class PenandaGambarDetailResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenandaGambarDetailResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
