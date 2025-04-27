<?php

namespace Inventory\V1\Rest\PembatalanPenerimaanBarang;

class PembatalanPenerimaanBarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PembatalanPenerimaanBarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
