<?php

namespace Pembayaran\V1\Rest\TransaksiKasir;

class TransaksiKasirResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TransaksiKasirResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
