<?php

namespace Inventory\V1\Rest\PaketFarmasi;

class PaketFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PaketFarmasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
