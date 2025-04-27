<?php

namespace Layanan\V1\Rest\OrderDetilRad;

class OrderDetilRadResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderDetilRadResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
