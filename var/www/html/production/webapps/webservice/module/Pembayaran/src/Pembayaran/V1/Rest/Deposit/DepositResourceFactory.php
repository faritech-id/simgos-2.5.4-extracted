<?php

namespace Pembayaran\V1\Rest\Deposit;

class DepositResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DepositResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
