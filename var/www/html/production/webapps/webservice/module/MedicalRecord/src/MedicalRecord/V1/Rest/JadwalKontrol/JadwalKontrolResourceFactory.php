<?php
namespace MedicalRecord\V1\Rest\JadwalKontrol;

class JadwalKontrolResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JadwalKontrolResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
