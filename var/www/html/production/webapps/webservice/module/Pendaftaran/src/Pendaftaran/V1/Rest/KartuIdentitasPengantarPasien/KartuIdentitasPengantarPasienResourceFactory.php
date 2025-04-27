<?php
namespace Pendaftaran\V1\Rest\KartuIdentitasPengantarPasien;

class KartuIdentitasPengantarPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KartuIdentitasPengantarPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
