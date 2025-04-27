<?php

namespace Pendaftaran\V1\Rest\PanggilanAntrianRuangan;

class PanggilanAntrianRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PanggilanAntrianRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
