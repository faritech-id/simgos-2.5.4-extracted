<?php

namespace Inventory\V1\Rest\HargaBarang;

class HargaBarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HargaBarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
