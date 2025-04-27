<?php
namespace MedicalRecord\V1\Rest\PemeriksaanKukuKaki;

class PemeriksaanKukuKakiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanKukuKakiResource();        
        $obj->setServiceManager($services);
        return $obj;
    }
}
