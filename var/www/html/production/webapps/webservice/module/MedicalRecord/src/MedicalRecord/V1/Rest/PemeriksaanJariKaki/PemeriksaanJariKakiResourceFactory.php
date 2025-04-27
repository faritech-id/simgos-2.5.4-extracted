<?php
namespace MedicalRecord\V1\Rest\PemeriksaanJariKaki;

class PemeriksaanJariKakiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanJariKakiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
