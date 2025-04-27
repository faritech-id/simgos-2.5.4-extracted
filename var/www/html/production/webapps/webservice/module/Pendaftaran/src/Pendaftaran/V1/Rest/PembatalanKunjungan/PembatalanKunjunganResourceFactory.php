<?php

namespace Pendaftaran\V1\Rest\PembatalanKunjungan;

class PembatalanKunjunganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PembatalanKunjunganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
