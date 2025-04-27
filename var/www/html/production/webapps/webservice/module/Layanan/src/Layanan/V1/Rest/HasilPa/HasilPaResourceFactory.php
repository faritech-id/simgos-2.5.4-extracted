<?php

namespace Layanan\V1\Rest\HasilPa;

class HasilPaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilPaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
