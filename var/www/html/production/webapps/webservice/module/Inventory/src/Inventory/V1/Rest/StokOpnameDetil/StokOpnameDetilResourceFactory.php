<?php

namespace Inventory\V1\Rest\StokOpnameDetil;

class StokOpnameDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StokOpnameDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
