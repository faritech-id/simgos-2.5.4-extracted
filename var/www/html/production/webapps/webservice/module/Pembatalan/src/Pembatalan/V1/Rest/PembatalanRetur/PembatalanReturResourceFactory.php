<?php

namespace Pembatalan\V1\Rest\PembatalanRetur;

class PembatalanReturResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PembatalanReturResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
