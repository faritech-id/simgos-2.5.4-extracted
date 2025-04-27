<?php
namespace MedicalRecord\V1\Rest\PemeriksaanFaring;

class PemeriksaanFaringResourceFactory
{
    public function __invoke($services)
    {
		$obj = new PemeriksaanFaringResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
