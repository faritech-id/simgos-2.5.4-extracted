<?php

namespace Pendaftaran\V1\Rest\AntrianRuangan;

class AntrianRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AntrianRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
