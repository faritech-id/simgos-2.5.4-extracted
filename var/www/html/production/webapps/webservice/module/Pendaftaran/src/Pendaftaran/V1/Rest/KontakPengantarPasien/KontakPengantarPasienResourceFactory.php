<?php
namespace Pendaftaran\V1\Rest\KontakPengantarPasien;

class KontakPengantarPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KontakPengantarPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
