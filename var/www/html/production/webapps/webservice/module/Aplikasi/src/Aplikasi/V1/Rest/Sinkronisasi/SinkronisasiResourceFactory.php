<?php

namespace Aplikasi\V1\Rest\Sinkronisasi;

class SinkronisasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SinkronisasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
