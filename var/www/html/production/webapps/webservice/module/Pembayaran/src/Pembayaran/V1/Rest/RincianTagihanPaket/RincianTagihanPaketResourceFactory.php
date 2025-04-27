<?php

namespace Pembayaran\V1\Rest\RincianTagihanPaket;

class RincianTagihanPaketResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RincianTagihanPaketResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
