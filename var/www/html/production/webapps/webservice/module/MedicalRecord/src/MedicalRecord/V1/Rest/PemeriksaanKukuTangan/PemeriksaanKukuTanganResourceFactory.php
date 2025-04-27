<?php
namespace MedicalRecord\V1\Rest\PemeriksaanKukuTangan;

class PemeriksaanKukuTanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanKukuTanganResource();
		$obj->setServiceManager($services);
        return $obj;
    }
}
