<?php

namespace Pembayaran\V1\Rest\EDC;

class EDCResourceFactory
{
    public function __invoke($services)
    {
        $obj = new EDCResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
