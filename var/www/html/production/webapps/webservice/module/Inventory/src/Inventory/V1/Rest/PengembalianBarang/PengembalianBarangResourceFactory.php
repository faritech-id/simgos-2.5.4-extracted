<?php

namespace Inventory\V1\Rest\PengembalianBarang;

class PengembalianBarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengembalianBarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
