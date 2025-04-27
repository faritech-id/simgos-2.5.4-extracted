<?php
namespace MedicalRecord\V1\Rest\PemeriksaanLangitLangit;

class PemeriksaanLangitLangitResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanLangitLangitResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
