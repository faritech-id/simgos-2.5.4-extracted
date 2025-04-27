<?php

namespace Layanan\V1\Rest\O2;

class O2ResourceFactory
{
    public function __invoke($services)
    {
        $obj = new O2Resource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
