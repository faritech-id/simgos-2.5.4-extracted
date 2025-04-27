<?php

namespace Layanan\V1\Rest\HasilEvaluasiSST;

class HasilEvaluasiSSTResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilEvaluasiSSTResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
