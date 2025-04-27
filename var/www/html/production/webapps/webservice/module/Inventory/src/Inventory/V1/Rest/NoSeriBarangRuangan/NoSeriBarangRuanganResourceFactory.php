<?php

namespace Inventory\V1\Rest\NoSeriBarangRuangan;

class NoSeriBarangRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new NoSeriBarangRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
