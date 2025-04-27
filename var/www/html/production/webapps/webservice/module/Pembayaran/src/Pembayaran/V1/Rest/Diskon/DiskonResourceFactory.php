<?php

namespace Pembayaran\V1\Rest\Diskon;

class DiskonResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiskonResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
