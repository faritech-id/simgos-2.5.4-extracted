<?php
namespace MedicalRecord\V1\Rest\PemeriksaanPersendianKaki;

class PemeriksaanPersendianKakiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanPersendianKakiResource();
		$obj->setServiceManager($services);
        return $obj;
    }
}
