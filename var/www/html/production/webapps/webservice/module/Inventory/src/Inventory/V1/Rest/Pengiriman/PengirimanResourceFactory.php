<?php

namespace Inventory\V1\Rest\Pengiriman;

class PengirimanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengirimanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
