<?php

namespace Pembayaran\V1\Rest\RincianTagihan;

class RincianTagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RincianTagihanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
