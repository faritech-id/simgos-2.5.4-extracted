<?php

namespace Pendaftaran\V1\Rest\SuratRujukanPasien;

class SuratRujukanPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SuratRujukanPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
