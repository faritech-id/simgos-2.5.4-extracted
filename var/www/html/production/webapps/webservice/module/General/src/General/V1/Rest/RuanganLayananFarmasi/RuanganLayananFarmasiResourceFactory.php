<?php

namespace General\V1\Rest\RuanganLayananFarmasi;

class RuanganLayananFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganLayananFarmasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
