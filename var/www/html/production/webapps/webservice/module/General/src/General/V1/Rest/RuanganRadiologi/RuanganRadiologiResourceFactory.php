<?php

namespace General\V1\Rest\RuanganRadiologi;

class RuanganRadiologiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganRadiologiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
