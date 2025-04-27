<?php
namespace MedicalRecord\V1\Rest\PemeriksaanAnus;

class PemeriksaanAnusResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanAnusResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
