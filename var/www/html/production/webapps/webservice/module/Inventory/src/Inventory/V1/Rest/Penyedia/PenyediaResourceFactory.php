<?php

namespace Inventory\V1\Rest\Penyedia;

class PenyediaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenyediaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
