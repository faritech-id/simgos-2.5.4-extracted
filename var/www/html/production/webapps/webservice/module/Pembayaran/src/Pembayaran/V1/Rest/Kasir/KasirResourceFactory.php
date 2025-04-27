<?php

namespace Pembayaran\V1\Rest\Kasir;

class KasirResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KasirResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
