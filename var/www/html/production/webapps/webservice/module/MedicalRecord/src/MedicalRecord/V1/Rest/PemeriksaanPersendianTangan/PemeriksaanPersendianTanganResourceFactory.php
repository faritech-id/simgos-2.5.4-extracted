<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPersendianTangan;

class PemeriksaanPersendianTanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanPersendianTanganResource();
		$obj->setServiceManager($services);
        return $obj;
    }
}
