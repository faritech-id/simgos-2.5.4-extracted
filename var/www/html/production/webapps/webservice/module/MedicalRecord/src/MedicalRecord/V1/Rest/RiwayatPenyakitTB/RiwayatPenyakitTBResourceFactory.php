<?php
namespace MedicalRecord\V1\Rest\RiwayatPenyakitTB;

class RiwayatPenyakitTBResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RiwayatPenyakitTBResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
