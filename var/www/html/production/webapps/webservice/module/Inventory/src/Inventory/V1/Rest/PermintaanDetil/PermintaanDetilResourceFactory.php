<?php

namespace Inventory\V1\Rest\PermintaanDetil;

class PermintaanDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PermintaanDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
