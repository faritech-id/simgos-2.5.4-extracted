<?php

namespace Pembayaran\V1\Rest\Transfer;

class TransferResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TransferResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
