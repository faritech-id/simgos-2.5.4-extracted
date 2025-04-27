<?php

namespace Pembayaran\V1\Rest\PelunasanPiutangPerusahaan;

class PelunasanPiutangPerusahaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PelunasanPiutangPerusahaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
