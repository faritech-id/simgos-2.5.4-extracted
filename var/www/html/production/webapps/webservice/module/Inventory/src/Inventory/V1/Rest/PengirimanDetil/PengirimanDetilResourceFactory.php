<?php

namespace Inventory\V1\Rest\PengirimanDetil;

class PengirimanDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengirimanDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
