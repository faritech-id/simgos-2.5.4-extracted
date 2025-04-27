<?php
namespace MedicalRecord\V1\Rest\PemeriksaanJariTangan;

class PemeriksaanJariTanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanJariTanganResource();
		$obj->setServiceManager($services);
        return $obj;
    }
}
