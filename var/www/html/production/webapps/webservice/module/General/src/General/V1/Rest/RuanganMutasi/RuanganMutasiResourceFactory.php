<?php

namespace General\V1\Rest\RuanganMutasi;

class RuanganMutasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganMutasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
