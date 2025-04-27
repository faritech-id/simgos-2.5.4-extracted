<?php

namespace Layanan\V1\Rest\ReturFarmasi;

class ReturFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReturFarmasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
