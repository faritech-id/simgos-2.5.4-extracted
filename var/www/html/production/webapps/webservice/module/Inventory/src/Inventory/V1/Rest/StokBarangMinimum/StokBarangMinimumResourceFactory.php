<?php

namespace Inventory\V1\Rest\StokBarangMinimum;

class StokBarangMinimumResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StokBarangMinimumResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
