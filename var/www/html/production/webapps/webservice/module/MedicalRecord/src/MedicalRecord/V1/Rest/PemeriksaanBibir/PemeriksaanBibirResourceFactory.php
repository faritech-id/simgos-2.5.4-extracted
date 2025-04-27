<?php
namespace MedicalRecord\V1\Rest\PemeriksaanBibir;

class PemeriksaanBibirResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanBibirResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
