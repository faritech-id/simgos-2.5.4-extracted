<?php
namespace MedicalRecord\V1\Rest\PemeriksaanGigiGeligi;

class PemeriksaanGigiGeligiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanGigiGeligiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
