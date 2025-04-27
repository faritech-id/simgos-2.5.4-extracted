<?php

namespace Pembayaran\V1\Rest\DiskonDokter;

class DiskonDokterResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiskonDokterResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
