<?php

namespace Penjualan\V1\Rest\Penjualan;

class PenjualanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjualanResource($services);
        $obj->setServiceManager($services);
        return $obj;
    }
}
