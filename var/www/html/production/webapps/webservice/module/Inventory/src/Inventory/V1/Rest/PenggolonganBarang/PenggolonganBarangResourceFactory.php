<?php

namespace Inventory\V1\Rest\PenggolonganBarang;

class PenggolonganBarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenggolonganBarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
