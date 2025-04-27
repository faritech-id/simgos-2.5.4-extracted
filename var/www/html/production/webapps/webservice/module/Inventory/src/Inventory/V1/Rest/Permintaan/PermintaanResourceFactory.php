<?php

namespace Inventory\V1\Rest\Permintaan;

class PermintaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PermintaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
