<?php

namespace Pembayaran\V1\Rest\SubsidiTagihan;

class SubsidiTagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SubsidiTagihanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
