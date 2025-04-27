<?php

namespace Layanan\V1\Rest\PasienPulang;

class PasienPulangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PasienPulangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
