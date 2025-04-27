<?php

namespace Inventory\V1\Rest\PenerimaanBarang;

class PenerimaanBarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenerimaanBarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
