<?php

namespace Penjualan\V1\Rest\ReturPenjualan;

class ReturPenjualanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReturPenjualanResource($services);
        $obj->setServiceManager($services);
        return $obj;
    }
}
