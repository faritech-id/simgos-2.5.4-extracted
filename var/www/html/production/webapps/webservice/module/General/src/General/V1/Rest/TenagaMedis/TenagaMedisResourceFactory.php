<?php

namespace General\V1\Rest\TenagaMedis;

class TenagaMedisResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TenagaMedisResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
