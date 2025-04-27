<?php

namespace Pembayaran\V1\Rest\PengembalianDeposit;

class PengembalianDepositResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengembalianDepositResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
