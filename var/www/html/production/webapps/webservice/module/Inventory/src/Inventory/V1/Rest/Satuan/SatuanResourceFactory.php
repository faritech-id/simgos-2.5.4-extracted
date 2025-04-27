<?php

namespace Inventory\V1\Rest\Satuan;

class SatuanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SatuanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
