<?php
namespace MedicalRecord\V1\Rest\RiwayatPemberianObat;

class RiwayatPemberianObatResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RiwayatPemberianObatResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
