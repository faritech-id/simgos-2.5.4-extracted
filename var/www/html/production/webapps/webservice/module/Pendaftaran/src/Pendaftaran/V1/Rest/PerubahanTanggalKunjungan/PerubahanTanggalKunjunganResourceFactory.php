<?php

namespace Pendaftaran\V1\Rest\PerubahanTanggalKunjungan;

class PerubahanTanggalKunjunganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PerubahanTanggalKunjunganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
