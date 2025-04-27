<?php

namespace Pendaftaran\V1\Rest\PengantarPasien;

class PengantarPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengantarPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
