<?php

namespace Penjualan\V1\Rest\PenjualanDetil;

class PenjualanDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjualanDetilResource($services);
        $obj->setServiceManager($services);
        return $obj;
    }
}
