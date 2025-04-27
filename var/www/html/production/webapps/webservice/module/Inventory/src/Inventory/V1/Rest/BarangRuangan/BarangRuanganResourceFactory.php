<?php

namespace Inventory\V1\Rest\BarangRuangan;

class BarangRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new BarangRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
