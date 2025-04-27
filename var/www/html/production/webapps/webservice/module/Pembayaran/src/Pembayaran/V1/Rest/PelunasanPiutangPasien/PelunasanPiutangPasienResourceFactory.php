<?php

namespace Pembayaran\V1\Rest\PelunasanPiutangPasien;

class PelunasanPiutangPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PelunasanPiutangPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
