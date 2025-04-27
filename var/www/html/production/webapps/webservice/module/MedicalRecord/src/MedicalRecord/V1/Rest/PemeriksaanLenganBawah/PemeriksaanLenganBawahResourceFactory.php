<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLenganBawah;

class PemeriksaanLenganBawahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanLenganBawahResource();
		$obj->setServiceManager($services);
        return $obj;
    }
}
