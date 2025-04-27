<?php

namespace General\V1\Rest\RuanganOperasi;

class RuanganOperasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganOperasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
